
local wxa               = require "resty.wxopen.wxa"
local _clone            = require "table.clone"

local __ = {}

__.use_proxy = true

-- 需要重试的错误码
local RETRY_CODE = {
    [40001] = true, -- invalid credential, access_token is invalid or not latest
    [40014] = true, -- invalid access_token
--  [40091] = true, -- invalid component ticket
    [40094] = true, -- invalid component credential
    [42001] = true, -- access_token expired
    [42002] = true, -- refresh_token expired
    [42006] = true, -- component_access_token expired
    [42007] = true, -- access_token and refresh_token exception
--  [61005]	= true, -- component ticket is expired
--  [61006] = true, -- component ticket is invalid
}

-- 是否需要重试
__.need_retry = function(code)
    return RETRY_CODE[code]
end

-- http get 请求
__.get = function(url, req, is_retry)

    local  access_token, err = wxa.ctx.get_authorizer_access_token(req.appid, is_retry)
    if not access_token then return nil, err end

    local query = _clone(req)
          query.appid = nil
          query.access_token = access_token

    local res, err, code = wxa.http.request { url = url, query = query }

    if not res and not is_retry and RETRY_CODE[code] then
        return __.get(url, req, true)  -- 【重试】
    end

    return res, err, code

end

-- http post 请求
__.post = function(url, req, is_retry)

    local  access_token, err = wxa.ctx.get_authorizer_access_token(req.appid, is_retry)
    if not access_token then return nil, err end

    local query = { access_token = access_token }
    local  body = req.body
    if not body then
        body = _clone(req)
        body.appid = nil
    end

    local res, err, code = wxa.http.request { url = url, query = query, body = body }

    if not res and not is_retry and RETRY_CODE[code] then
        return __.post(url, req, true)  -- 【重试】
    end

    return res, err, code

end

-- http form 请求
__.form = function(url, req, is_retry)

    local  access_token, err = wxa.ctx.get_authorizer_access_token(req.appid, is_retry)
    if not access_token then return nil, err end

    local query = { access_token = access_token }
    local form  = {}

    for k, v in pairs(req) do
        if type(k) == "string" then
            if type(v) == "table" then
                form[k] = v
            elseif type(v) == "string" and k ~= "appid" then
                query[k] = v
            end
        end
    end

    local res, err, code = wxa.http.request { url = url, query = query, form = form }

    if not res and not is_retry and RETRY_CODE[code] then
        return __.form(url, req, true)  -- 【重试】
    end

    return res, err, code

end

-- http token 请求
__.token = function(req, is_retry)

    local url   = req.url
    local body  = req.body
    local query = req.query or {}

    local  component_access_token, err = wxa.ctx.get_component_access_token(is_retry)
    if not component_access_token then return nil, err end

    query.access_token           = component_access_token
    query.component_access_token = component_access_token

    local res, err, code = wxa.http.request { url = url, query = query, body = body }

    if not res and not is_retry and RETRY_CODE[code] then
        return __.token(req, true)  -- 【重试】
    end

    return res, err, code

end

return __
