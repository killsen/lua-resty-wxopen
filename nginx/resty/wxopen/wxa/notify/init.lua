
local wxa               = require "resty.wxopen.wxa"
local to_xml            = require "app.utils.xml".to_xml
local dt                = require "app.utils.dt"
local pcall             = pcall
local _insert           = table.insert

local __ = {}
__.ver   = "22.02.17"
__.name  = "第三方平台授权消息"

local NOTIFY = {
    notify_third_fasteregister          = { },  -- 注册审核事件推送
    notify_third_fastregisterbetaapp    = { },  -- 创建试用小程序成功/失败的通知
    notify_third_fastverifybetaapp      = { },  -- 试用小程序快速认证消息推送

    authorized                          = { },  -- 授权成功通知
    unauthorized                        = { },  -- 取消授权通知
    updateauthorized                    = { },  -- 授权更新通知

    -- 代码审核结果推送
    -- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/audit_event.html
    weapp_audit_success                 = { },  -- 代码审核成功推送
    weapp_audit_fail                    = { },  -- 代码审核失败推送
    weapp_audit_delay                   = { },  -- 代码审核延期推送
}

-- 注册消息通知回调函数
local function add_notify_func(info_type, notify_func)
    local funcs = NOTIFY[info_type]
    if funcs then return end
    for _, f in ipairs(funcs) do
        if f == notify_func then return true end
    end
    _insert(funcs, notify_func)
    return true
end

-- 注册审核事件推送
__.notify_third_fasteregister = function(notify_func)
    return add_notify_func("notify_third_fasteregister", notify_func)
end

-- 创建试用小程序成功/失败的通知
__.notify_third_fastregisterbetaapp = function(notify_func)
    return add_notify_func("notify_third_fastregisterbetaapp", notify_func)
end

-- 试用小程序快速认证消息推送
__.notify_third_fastverifybetaapp = function(notify_func)
    return add_notify_func("notify_third_fastverifybetaapp", notify_func)
end


-- 授权成功通知
__.authorized = function(notify_func)
    return add_notify_func("authorized", notify_func)
end

-- 取消授权通知
__.unauthorized = function(notify_func)
    return add_notify_func("unauthorized", notify_func)
end

-- 取消授权通知
__.updateauthorized = function(notify_func)
    return add_notify_func("updateauthorized", notify_func)
end


-- 代码审核成功推送
__.weapp_audit_success = function(notify_func)
    return add_notify_func("weapp_audit_success", notify_func)
end

-- 代码审核失败推送
__.weapp_audit_fail = function(notify_func)
    return add_notify_func("weapp_audit_fail", notify_func)
end

-- 代码审核延期推送
__.weapp_audit_delay = function(notify_func)
    return add_notify_func("weapp_audit_delay", notify_func)
end


-- 消息通知回调
local function _notify(xml)

    local funs = NOTIFY[xml.InfoType] or NOTIFY[xml.Event]
    if not funs then return true end

    for _, fun in ipairs(funs) do
        local pok, res, err = pcall(fun, xml)

        if not pok then
            ngx.log(ngx.ERR, xml.InfoType, res)
            return false, res
        end

        if res == false then
            ngx.log(ngx.ERR, xml.InfoType, err)
            return false, err
        end
    end

    return true

end


-- 保存日志
local function add_log(res)

    local yyyy, mm, dd = dt.yyyymmdd(ngx.today())

    local path = ngx.config.prefix() .. "/temp/wxa_notify_" .. yyyy .. mm .. dd .. ".txt"
    local file = io.openx(path, "ab+" )
    if not file then return end

    file:write(ngx.localtime(), "\n")
    file:write(ngx.var.request_uri, "\n")
    file:write(to_xml(res), "\n\n")
    file:close()

end


local function notify_info(xml)

    -- 验证票据（component_verify_ticket），在第三方平台创建审核通过后，
    -- 微信服务器会向其 “授权事件接收URL” 每隔 10 分钟以 POST 的方式推送 component_verify_ticket
    -- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/component_verify_ticket.html
    if xml.InfoType == "component_verify_ticket" then
        -- <xml>
        --     <InfoType>component_verify_ticket</InfoType>
        --     <ComponentVerifyTicket>ticket@@@3_pQ-eclGgtH5BawtrFoxIeNf3zWwu44vhBpsU0cFIpR5XhrN8hQARvVsVos4TgbhqBHzoTyAph_h0woFPGzSg</ComponentVerifyTicket>
        --     <CreateTime>1612509415</CreateTime>
        --     <AppId>wx60c0586c548fd710</AppId>
        -- </xml>
        local ticket = xml.ComponentVerifyTicket
        wxa.ctx.set_component_verify_ticket(ticket)
    end

    -- 注册审核事件推送
    -- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Register_Mini_Programs/Fast_Registration_Interface_document.html#%E4%B8%89%E3%80%81%E6%B3%A8%E5%86%8C%E5%AE%A1%E6%A0%B8%E4%BA%8B%E4%BB%B6%E6%8E%A8%E9%80%81
    if xml.InfoType == "notify_third_fasteregister" then
        if tonumber(xml.status) == 0 then
            wxa.ctx.query_auth_code(xml.auth_code)
        end
    end

    -- 授权变更通知推送
    -- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/authorize_event.html
    if xml.InfoType == "authorized" then
        -- 授权成功通知
        wxa.ctx.query_auth_code(xml.AuthorizationCode)

    elseif xml.InfoType == "updateauthorized" then
        -- 授权更新通知
        wxa.ctx.query_auth_code(xml.AuthorizationCode)

    elseif xml.InfoType == "unauthorized" then
        -- 取消授权通知
        wxa.ctx.del_authorizer_token(xml.AuthorizerAppid)
    end

    local ok, err = _notify(xml)
    if not ok then return "fail" end

    return "success"

end


local function notify_msg(xml)

    -- 事件消息处理
    if xml.MsgType == "event" then
        local ok = _notify(xml)
        return ok and "success" or "fail"
    end

    if xml.MsgType == "text" then

        -- <xml>
        --     <FromUserName>ozy4qt5QUADNXORxCVipKMV9dss0</FromUserName>
        --     <ToUserName>gh_3c884a361561</ToUserName>
        --     <CreateTime>1612504386</CreateTime>
        --     <MsgId>6925653602934966926</MsgId>
        --     <MsgType>text</MsgType>
        --     <Content>TESTCOMPONENT_MSG_TYPE_TEXT</Content>
        -- </xml>

        if xml.Content == "TESTCOMPONENT_MSG_TYPE_TEXT" then
            return wxa.notify.msg.encode {
                ToUserName      = xml.FromUserName,
                FromUserName    = xml.ToUserName,
                CreateTime      = "" .. ngx.time(),
                MsgType         = "text",
                Content         = "TESTCOMPONENT_MSG_TYPE_TEXT_callback",
            }
        end

        -- <xml>
        --     <FromUserName>ozy4qt5QUADNXORxCVipKMV9dss0</FromUserName>
        --     <ToUserName>gh_3c884a361561</ToUserName>
        --     <CreateTime>1612504386</CreateTime>
        --     <MsgId>6925653602934966925</MsgId>
        --     <MsgType>text</MsgType>
        --     <Content>QUERY_AUTH_CODE:queryauthcode@@@Fue56RSKjEuJNhRU-ZhJbLqYyYT6c2L2aAWoprW_O0WpZcz8l48MuobHKK4g8tASOPi0NB2iOELomvYFQoX1Ew</Content>
        -- </xml>

        local prefix = "QUERY_AUTH_CODE:"
        if string.sub(xml.Content, 1, #prefix) == prefix then

            local touser = xml.FromUserName
            local query_auth_code = string.sub(xml.Content, #prefix+1)

            local res, err = wxa.ctx.query_auth_code(query_auth_code)
            if not res then return end

            local access_token = res.authorizer_access_token
            wxa.notify.msg.send_text(access_token, touser, query_auth_code .. "_from_api")

            return  -- 退出
        end

    end

    -- 转发客服消息
    -- https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/customer-message/trans.html
    -- 文本消息 text 图片消息 image 小程序卡片消息 miniprogrampage
    if xml.MsgType == "text" or xml.MsgType == "image" or xml.MsgType == "miniprogrampage" then
        return wxa.notify.msg.encode {
            ToUserName      = xml.FromUserName,
            FromUserName    = xml.ToUserName,
            CreateTime      = "" .. ngx.time(),
            MsgType         = "transfer_customer_service",
        }
    end

end


__.actx = function()

    local xml, err = wxa.notify.msg.decode()

    if not xml then
        ngx.print("fail")
        return
    end

    add_log(xml)  -- 保存日志

    local res

    if xml.MsgType then
        res = notify_msg(xml)
    elseif xml.InfoType then
        res = notify_info(xml)
    else
        res = "fail"
    end

    if type(res) == "string" then
        ngx.print(res)
    end

end

return __
