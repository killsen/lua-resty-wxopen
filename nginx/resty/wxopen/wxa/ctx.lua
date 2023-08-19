
local wxa               = require "resty.wxopen.wxa"
local cjson             = require "cjson.safe"
local mlcache           = require "app.utils.mlcache"
local request           = require "app.utils.request"
local logs_path         = ngx.config.prefix() .. "/logs/"
local _ssub             = string.sub

local _T = {}
local __ = { types = _T }

local CTX_DEFAULT

-- 初始化多级缓存模块
__.init_mlcache = function(mod)
-- @mod     : table
-- @return  : void
    mlcache = mod
end

-- 读取 ticket
local function ticket_reader(component_appid)
-- @component_appid : string
-- @return          : ticket?: string

    local file = logs_path .. "wxa_ticket_" .. component_appid .. ".txt"

    local  f = io.openx(file, "rb")
    if not f then return end

    local  ticket = f:read("*a"); f:close()
    if not ticket or ticket == "" then return end

    return ticket

end

-- 保存 ticket
local function ticket_writer(component_appid, ticket)
-- @component_appid : string
-- @ticket          : string
-- @return          : ok?: boolean

    if type(component_appid) ~= "string" then return end
    if type(ticket) ~= "string" then return end

    local file = logs_path .. "wxa_ticket_" .. component_appid .. ".txt"

    local  f = io.openx(file, "wb+")
    if not f then return end

    f:write(ticket)
    f:close()

    return true

end

-- 初始化读取 ticket 方法
__.init_ticket_reader = function(reader)
-- @reader : function
    ticket_reader = reader
end

-- 初始化保存 ticket 方法
__.init_ticket_writer = function(writer)
-- @writer : function
    ticket_writer = writer
end


__.set_component__ = {
    "设置第三方平台",
    req = {
        { "appid"           , "第三方平台AppID"         },
        { "secret"          , "第三方平台AppSecret"     },
        { "token"           , "消息校验Token"           },
        { "aeskey"          , "消息加解密AesKey"        },
        { "token_proxy?"    , "获取AccessToken使用代理" },
        { "request_proxy?"  , "请求接口使用代理"        },
        { "is_default?"     , "是否默认",   "boolean"   },
    }
}
__.set_component = function(t)

    local ctx = {}

    ctx.appid  = t.appid
    ctx.secret = t.secret
    ctx.token  = t.token
    ctx.aeskey = ngx.decode_base64(t.aeskey .. "=")

    local token_proxy = t.token_proxy
    if type(token_proxy) ~= "string" or token_proxy == "" then token_proxy = nil end

    local request_proxy = t.request_proxy
    if type(request_proxy) ~= "string" or request_proxy == "" then
        request_proxy = nil
    elseif _ssub(request_proxy, -1) ~= "/" then
        request_proxy = request_proxy .. "/"
    end

    ctx.token_proxy   = token_proxy
    ctx.request_proxy = request_proxy

    ngx.ctx[__] = ctx

    if t.is_default or not CTX_DEFAULT then
        CTX_DEFAULT = ctx  -- 默认
    end

end

local function get_ctx_val(key)
    local  ctx = ngx.ctx[__] or CTX_DEFAULT
    return ctx and ctx[key] or nil
end

-- 第三方平台AppID
__.get_component_appid = function()
    return get_ctx_val("appid")
end

-- 第三方平台AppSecret
__.get_component_secret = function()
    return get_ctx_val("secret")
end

-- 消息校验Token
__.get_component_token = function()
    return get_ctx_val("token")
end

-- 消息加解密AesKey
__.get_component_aeskey = function()
    return get_ctx_val("aeskey")
end

-- 获取AccessToken使用代理
__.get_token_proxy = function()
    return get_ctx_val("token_proxy")
end

-- 请求接口使用代理
__.get_request_proxy = function()
    return get_ctx_val("request_proxy")
end

-- 启动ticket推送服务
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/component_verify_ticket_service.html
__.start_push_ticket = function()

    return wxa.http.request {
        url     = "cgi-bin/component/api_start_push_ticket",
        body    = {
            component_appid     = __.get_component_appid(),
            component_secret    = __.get_component_secret(),
        },
    }

end

-- 保存验证票据
-- 在第三方平台创建审核通过后，微信服务器会向其 “授权事件接收URL” 每隔 10 分钟以 POST 的方式推送 component_verify_ticket
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/component_verify_ticket.html
__.set_component_verify_ticket = function(ticket)
-- @ticket : string
-- @return  : ok?: boolean, err?: string

    if type(ticket) ~= "string" then return end

    local component_appid = __.get_component_appid()

    local key = "component_verify_ticket/" .. component_appid

    local  ok, err = mlcache.set(key, ticket)
    if not ok then return nil, err end

    local  ok, err = ticket_writer(component_appid, ticket)
    if not ok then return nil, err end

    return true

end

-- 取得验证票据
__.get_component_verify_ticket = function(reload)

    local component_appid     = __.get_component_appid()
    local component_appsecret = __.get_component_secret()

    local key  = "component_verify_ticket/" .. component_appid

    if reload then mlcache.del(key) end

    return mlcache.get(key, function()

        local token_proxy = __.get_token_proxy()

        -- 第三方平台接口是否使用反向代理模式
        if token_proxy then
            local url = token_proxy
                     .. "?appid=" .. component_appid
                     .. "&secret=" .. component_appsecret
            local  res, err = request(url)
            if not res then return nil, err end

            local  obj = cjson.decode(res.body)
            if not obj then return nil, "请求失败: JSON解码失败" end

            return obj.component_verify_ticket, nil, 10 * 60
        end

        return ticket_reader(component_appid)

    end)

end

-- 获取第三方平台 component_access_token
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/component_access_token.html
__.get_component_access_token = function(reload)

    local component_appid     = __.get_component_appid()
    local component_appsecret = __.get_component_secret()

    local key = "component_access_token/" .. component_appid

    if reload then mlcache.del(key) end

    return mlcache.get(key, function()

        local token_proxy = __.get_token_proxy()

        -- 第三方平台接口是否使用反向代理模式
        if token_proxy then
            local url = token_proxy
                     .. "?appid=" .. component_appid
                     .. "&secret=" .. component_appsecret
            local  res, err = request(url)
            if not res then return nil, err end

            local  obj = cjson.decode(res.body)
            if not obj then return nil, "请求失败: JSON解码失败" end

            return obj.component_access_token, nil, 10 * 60
        end

        local  ticket = __.get_component_verify_ticket()
        if not ticket then return nil, "ticket is null" end

        local res, err = wxa.http.request {
            url     = "cgi-bin/component/api_component_token",
            body    = {
                component_appid         = component_appid,
                component_appsecret     = component_appsecret,
                component_verify_ticket = ticket
            },
        }
        if not res then return nil, err end

        return res.component_access_token, nil, res.expires_in / 2

    end)

end

-- 取得授权 app 的 authorizer_refresh_token
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/api_get_authorizer_info.html
local function get_authorizer_refresh_token(authorizer_appid)
-- @authorizer_appid    : string  //授权小程序AppID

    local component_appid = __.get_component_appid()

    local res, err = wxa.http.token {
        url     = "cgi-bin/component/api_get_authorizer_info",
        query   = { component_access_token  = true,                 },
        body    = { component_appid         = component_appid,
                    authorizer_appid        = authorizer_appid,     },
    }
    if not res then return nil, err end

    local token = res.authorization_info.authorizer_refresh_token
    if not token or token == "" then return nil, "该帐号已冻结" end

    return token, nil, 7200

end

-- 取得授权 app 的 authorizer_refresh_token
__.get_authorizer_refresh_token = function(authorizer_appid, reload)

    if type(authorizer_appid) ~= "string" or authorizer_appid == "" then
        return nil, "authorizer_appid 不能为空"
    end

    local component_appid = __.get_component_appid()

    local key = "authorizer_refresh_token/" .. component_appid .. "/" .. authorizer_appid

    if reload then mlcache.del(key) end

    return mlcache.get(key, get_authorizer_refresh_token, authorizer_appid)

end

-- 取得授权 app 的 authorizer_access_token
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/api_authorizer_token.html
local function get_authorizer_access_token(authorizer_appid, is_retry)
-- @authorizer_appid    : string  //授权小程序AppID
-- @is_retry          ? : boolean //是否重试
-- @return              : token?: string, err?: string, expires?: number

    local  authorizer_refresh_token, err = __.get_authorizer_refresh_token(authorizer_appid, is_retry)
    if not authorizer_refresh_token then return nil, err end

    local  component_access_token, err = __.get_component_access_token()
    if not component_access_token then return nil, err end

    local component_appid = __.get_component_appid()

    local res, err, code = wxa.http.request {
        url     = "cgi-bin/component/api_authorizer_token",
        query   = { component_access_token  = component_access_token, },
        body    = { component_appid         = component_appid,
                    authorizer_appid        = authorizer_appid,
                    authorizer_refresh_token= authorizer_refresh_token},
    }

    if not res then
        if not is_retry and wxa.http.need_retry(code) then
            return get_authorizer_access_token(authorizer_appid, true)  -- 【重试】
        else
            return nil, err
        end
    end

    return res.authorizer_access_token, nil, res.expires_in / 2

end

-- 取得授权 app 的 authorizer_access_token
__.get_authorizer_access_token = function(authorizer_appid, reload)
-- @authorizer_appid    : string  //授权小程序AppID
-- @reload            ? : boolean //更新缓存
-- @return              : token?: string, err?: string

    if type(authorizer_appid) ~= "string" or authorizer_appid == "" then
        return nil, "authorizer_appid 不能为空"
    end

    local component_appid = __.get_component_appid()

    local key = "authorizer_access_token/" .. component_appid .. "/" .. authorizer_appid

    if reload then mlcache.del(key) end

    return mlcache.get(key, get_authorizer_access_token, authorizer_appid)

end

-- 删除 authorizer_refresh_token 及 authorizer_access_token
__.del_authorizer_token = function(authorizer_appid)
-- @authorizer_appid    : string  //授权小程序AppID
-- @return              : ok?: boolean, err?: string

    if type(authorizer_appid) ~= "string" or authorizer_appid == "" then
        return nil, "authorizer_appid 不能为空"
    end

    local component_appid = __.get_component_appid()

    mlcache.del("authorizer_refresh_token/" .. component_appid .. "/" .. authorizer_appid)
    mlcache.del("authorizer_access_token/"  .. component_appid .. "/" .. authorizer_appid)

    return true

end

-- 使用授权码获取授权信息
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/authorization_info.html
local function query_auth_code(authorization_code)
-- @authorization_code  : string                //授权码
-- @return              : @AuthorizationInfo    //授权信息

    local component_appid = __.get_component_appid()

    local res, err = wxa.http.token {
        url     = "cgi-bin/component/api_query_auth",
        query   = { component_access_token  = true,                 },
        body    = { component_appid         = component_appid,
                    authorization_code      = authorization_code    },
    }
    if not res then return nil, err end

    local info = res.authorization_info  --> @AuthorizationInfo

    local appid          = info.authorizer_appid
    local refresh_token  = info.authorizer_refresh_token
    local access_token   = info.authorizer_access_token
    local expires_in     = info.expires_in

    mlcache.set("authorizer_refresh_token/" .. component_appid .. "/" .. appid, refresh_token, expires_in)
    mlcache.set("authorizer_access_token/"  .. component_appid .. "/" .. appid, access_token , expires_in / 2)

    return info

end

_T.AuthorizationInfo = { "//授权信息",
    authorizer_appid            = "//授权方AppID",
    authorizer_refresh_token    = "//刷新令牌",
    authorizer_access_token     = "//接口调用令牌",
    expires_in                  = "number //有效期，单位：秒",
    func_info                   = "//授权给开发者的权限集列表",
}

-- 使用授权码获取授权信息
__.query_auth_code = function(authorization_code)
-- @authorization_code  : string                //授权码
-- @return              : @AuthorizationInfo    //授权信息

    if type(authorization_code) ~= "string" or authorization_code == "" then
        return nil, "authorization_code 不能为空"
    end

    local component_appid = __.get_component_appid()

    local key = "authorization_info/" .. component_appid .. "/" .. authorization_code

    return mlcache.get(key, query_auth_code, authorization_code)

end

return __
