
local wxa               = require "resty.wxopen.wxa"
local from_xml          = require "app.utils.xml".from_xml
local to_xml            = require "app.utils.xml".to_xml
local aes               = require "resty.aes"
local str               = require "resty.string"
local sha1              = require "resty.sha1"

local __ = { _VERSION = "v22.01.07" }

-- 加密解密技术方案
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Before_Develop/Technical_Plan.html
-- 开放平台的消息加密解密技术方案基于 AES 加解密算法来实现，具体如下：

-- EncodingAESKey： 即消息加解密 Key，长度固定为 43 个字符，从 a-z,A-Z,0-9 共 62 个字符中选取。
-- 由开发者在创建公众号插件时填写，后也可申请修改。

-- AESKey： AESKey=Base64_Decode(EncodingAESKey + "=")，
-- EncodingAESKey 尾部填充一个字符的 "=", 用 Base64_Decode 生成 32 个字节的 AESKey；

-- AES 采用 CBC 模式，秘钥长度为 32 个字节（256 位），数据采用 PKCS#7 填充；
-- PKCS#7：K 为秘钥字节数（采用 32），Buf 为待加密的内容，N 为其字节数。
-- Buf 需要被填充为 K 的整数倍。在 Buf 的尾部填充(K - N%K)个字节，每个字节的内容 是(K - N%K)。

-- 签名
local function _signature(data)
-- @data    : string[]
-- @return  : string

    local token = wxa.ctx.get_component_token()

    local t = { token }

    for _, v in ipairs(data) do
        table.insert(t, v)
    end

    table.sort(t)

    local sha = sha1:new()

    for _, s in ipairs(t) do
        sha:update(s)
    end

    return str.to_hex( sha:final() )

end

-- 解密
local function _decrypt(msg_encrypt)
-- @msg_encrypt : string
-- @return      : res?: string, err?: string

    local hash = { iv = "aaaabbbbccccdddd" }
    local cipher = aes.cipher(256,"cbc")

    local aesKey = wxa.ctx.get_component_aeskey()
    local aes_256_cbc, err = aes:new(aesKey, nil, cipher, hash)
    if not aes_256_cbc then return nil, err end

    local  s = ngx.decode_base64(msg_encrypt)
           s = aes_256_cbc:decrypt(s)
    if not s then return nil, "decrypt fail" end

    -- random(16B)为 16 字节的随机字符串
    -- local random  = string.sub(s, 1, 16)

    local n1 = string.byte(s, 17, 17)
    local n2 = string.byte(s, 18, 18)
    local n3 = string.byte(s, 19, 19)
    local n4 = string.byte(s, 20, 20)

    -- msg_len 为 msg 长度，占 4 个字节
    local len = wxa.notify.utils.bufToInt32(n1, n2, n3, n4)

    local msg = string.sub(s, 21, 21+len-1)

    return msg

end

-- 加密
local function _encrypt(msg)
-- @msg     : string
-- @return  : res?: string, err?: string

    local hash = { iv = "aaaabbbbccccdddd" }
    local cipher = aes.cipher(256,"cbc")

    local aesKey = wxa.ctx.get_component_aeskey()
    local aes_256_cbc, err = aes:new(aesKey, nil, cipher, hash)
    if not aes_256_cbc then return nil, err end

    local random = "1234567890123456"
    local msg_len = wxa.notify.utils.int32ToBufStr(#msg)

    local appId = wxa.ctx.get_component_appid()

    local s = random .. msg_len .. msg .. appId

    -- AES 采用 CBC 模式，秘钥长度为 32 个字节（256 位），数据采用 PKCS#7 填充；
    -- PKCS#7：K 为秘钥字节数（采用 32），Buf 为待加密的内容，N 为其字节数。
    -- Buf 需要被填充为 K 的整数倍。
    -- 在 Buf 的尾部填充(K - N%K)个字节，每个字节的内容 是(K - N%K)。

    local p = 32 - #s % 32
    s = s .. string.rep(string.char(p), p)

    s = aes_256_cbc:encrypt(s)

    return ngx.encode_base64(s)

end

-- 消息解码
__.decode = function()
-- @return  : res?: table, err?: string

    local args = ngx.req.get_uri_args()
    local timestamp     = args.timestamp        -- 时间戳
    local nonce         = args.nonce            -- 随机数
    local encrypt_type  = args.encrypt_type     -- 加密类型: aes
    local msg_signature = args.msg_signature    -- 消息体签名

    if encrypt_type ~= "aes" then return nil, "加密类型必须是aes" end

                 ngx.req.read_body()
    local  xml = ngx.req.get_body_data()
    if not xml or xml == "" then return nil, "请求数据不能为空" end

    local  data = from_xml(xml)
    if not data then return nil, "XML解码失败" end

    local msg_encrypt = data["Encrypt"]
    local dev_msg_signature = _signature { timestamp, nonce, msg_encrypt }
    if msg_signature ~= dev_msg_signature then return nil, "签名错误" end

    local  msg_xml = _decrypt(msg_encrypt)
    if not msg_xml then return nil, "解码失败" end

    local  obj = from_xml(msg_xml)
    if not obj then return nil, "XML解码失败" end

    return obj

end

-- 消息编码
__.encode = function(obj)
-- @obj     : table
-- @return  : string

    local msg_xml       = to_xml(obj)
    local msg_encrypt   = _encrypt(msg_xml)
    local timestamp     = "" .. ngx.time()
    local nonce         = "" .. ngx.now() * 1000

    return to_xml {
        Encrypt         = msg_encrypt,
        MsgSignature    = _signature { timestamp, nonce, msg_encrypt },
        TimeStamp       = timestamp,
        Nonce           = nonce,
    }

end

-- 发送文本消息
__.send_text = function(access_token, touser, content)
-- @access_token    : string
-- @touser          : string
-- @content         : string
-- @return          : res?: any, err?: string, errcode?: number

    return wxa.http.request {
        url     = "cgi-bin/message/custom/send",
        query   = {
            access_token = access_token,
        },
        body    = {
            touser      = touser,
            msgtype     = "text",
            text        = {
                content = content,
            }
        }
    }

end

return __
