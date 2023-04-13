
local wxa               = require "resty.wxopen.wxa"
local cjson             = require "cjson.safe"
local _clone            = require "table.clone"
local _hex              = require "resty.string".to_hex
local _random           = require "resty.random".bytes
local _request          = require "app.utils".request
local _insert           = table.insert
local _concat           = table.concat
local _ssub             = string.sub

-- 解析 multipart form
local function gen_form(form, headers)
-- @form    : table
-- @headers : map<string>
-- @return  : body: string, headers: map<string>

    local boundary = _hex(_random(16)) -- 取得随机码

    if type(headers) ~= "table" then headers = {} end
    headers["Content-Type"] = "multipart/form-data;boundary=" .. boundary

    local body = {}

    _insert(body, '--' .. boundary)

    for name, f in pairs(form) do
        if type(name) == "string" and type(f) == "table" then

            local data, attr = f.data, f.attr

            if type(attr) == "table" then
                local t = {}
                for k, v in pairs(f.attr) do
                    _insert(t, k .. '="'.. v ..'";')
                end
                attr = _concat(t, "")
            end

            if type(attr) ~= "string" then attr = "" end

            _insert(body, 'Content-Disposition: form-data; '
                        .. 'name="' .. name .. '";' .. attr)

            local content_type = f.content_type or f["Content-Type"]
            if type(content_type) == "string" then
                _insert(body, 'Content-Type: ' .. content_type)
            end

            _insert(body, '')
            _insert(body, data)
        end
    end

    _insert(body, '--' .. boundary .. '--')

    return _concat(body,"\r\n"), headers

end

local MEDIA_URL = {  --> map<boolean>
    ["cgi-bin/media/get"]               = true,
    ["cgi-bin/media/getfeedbackmedia"]  = true,
}

-- http 请求
local function request(req)
-- @req     : { url, query?: string | table, body?: string | table, form?: table, headers?: map<string> }
-- @return  : res?: any, err?: string, errcode?: number

    local url, query, body = req.url, req.query, req.body
    local form, headers = req.form, req.headers

    -- 错误返回json，成功返回图片
    local is_media = MEDIA_URL[url]

    if type(url) ~= "string" then
        return nil, "url不允许为空"
    end

    -- 第三方平台接口是否使用反向代理模式
    local request_proxy = wxa.ctx.get_request_proxy()
    url = (request_proxy or "https://api.weixin.qq.com/") .. url

    if type(form) == "table" then
        body, headers = gen_form(form, headers)
    end

    if type(query) == "table" then
        query = ngx.encode_args(query)
    end

    if type(body) == "table" then
        if body.appid then
            body = _clone(body)
            body.appid = nil  -- 删除多余的 appid 参数
        end
        body = cjson.encode(body)
        if body == "[]" then body = "{}" end

    end

    if body then
        headers = headers or {}
        headers["Content-Type"] = headers["Content-Type"] or "application/json"
    end

    local res, err = _request(url, {
        query   = query,
        body    = body,
        method  = body and "POST" or "GET",
        headers = headers,
    })

    if not res then return nil, err end

    if res.status ~= 200 then
        return nil, "请求失败 (" .. res.status .. ")"
    end

    local content_type = res.headers["Content-Type"]
    if content_type == "image/jpeg" or content_type == "voice/speex" then
        return res.body
    end

    -- Content-Disposition: attachment; filename="1.jpg"
    local content_disposition = res.headers["Content-Disposition"]
    if type(content_disposition) == "string" then
        local pref = "attachment; filename="
        if _ssub(content_disposition, 1, #pref) == pref then
            return res.body
        end
    end

    local obj = cjson.decode(res.body)
    if type(obj) ~= "table" then
        -- 错误返回json，成功返回图片
        if is_media then return res.body end
        return nil, "json解码失败"
    end

    local errcode = tonumber(obj.errcode) or 0

    if errcode ~= 0 then
        local err = wxa.http.errcode.get(errcode) or obj.errmsg or "未知错误"
        return nil, err, errcode
    end

    return obj

end

return request
