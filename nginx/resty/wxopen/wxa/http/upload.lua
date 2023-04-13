
local wxa               = require "resty.wxopen.wxa"
local cjson             = require "cjson.safe"
local _hex              = require "resty.string".to_hex
local _random           = require "resty.random".bytes
local _request          = require "app.utils".request

-- 上传文件
local function upload(req)
-- @req     : { access_token, file_type?, file_name?, file_data }
-- @return  : res?: table, err?: string

    local access_token  = req.access_token
    local file_type     = req.file_type or "image"
    local file_name     = req.file_name or "file.jpg"
    local file_data     = req.file_data

    if type(file_data) ~= "string" or #file_data == 0 then
        return nil, "file_data 不能为空"
    end

    -- 第三方平台接口是否使用反向代理模式
    local request_proxy = wxa.ctx.get_request_proxy()
    local url = (request_proxy or "https://api.weixin.qq.com/") .. "cgi-bin/media/upload"

    local boundary = _hex(_random(16)) -- 取得随机码

    local headers = {
        ["Content-Type"] = "multipart/form-data;boundary=" .. boundary
    }

    local body = table.concat({
        '--' .. boundary,
        'Content-Disposition: form-data; name="media"; '
             .. 'filename="'   ..  file_name .. '"; '
             .. 'filelength="' .. #file_data .. '"; ',
        'Content-Type: image/jpg',
        '',
        file_data,
        '--' .. boundary .. '--'
    },"\r\n")

    local query = ngx.encode_args {
        access_token = access_token,
        type         = file_type,
    }

    local res, err = _request(url, {
        query   = query,
        body    = body,
        method  = "POST",
        headers = headers,
    })

    if not res then return nil, err end

    if res.status ~= 200 then
        return nil, "请求失败 (" .. res.status .. ")"
    end

    local obj = cjson.decode(res.body)
    if not obj then return nil, "json解码失败" end

    local errcode = tonumber(obj.errcode) or 0
    if errcode ~= 0 then
        return nil, obj.errmsg or "未知错误"
    end

    return obj

end

return upload
