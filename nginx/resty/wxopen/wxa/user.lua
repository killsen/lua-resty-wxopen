
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.24" }

__.jscode2session__ = {
    "小程序登录",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/others/WeChat_login.html
    req = {
        appid	                = "//小程序的 AppID",
        js_code	                = "//wx.login 获取的 code",
    --  grant_type	            = "//填 authorization_code",
    --  component_appid	        = "//第三方平台 appid",
    --  component_access_token	= "//第三方平台的component_access_token",
    },
    res = {
        openid                  = "//用户唯一标识的 openid",
        session_key             = "//会话密钥",
    }
}
__.jscode2session = function(req)

    return wxa.http.token {
        url     = "sns/component/jscode2session",
        query   = {
            appid                   = req.appid,
            js_code                 = req.js_code,
            grant_type              = "authorization_code",
            component_appid         = wxa.ctx.get_component_appid(),
            component_access_token  = true,
        },
    }

end

__.get_paid_unionid__ = {
    "支付后获取用户 Unionid 接口",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/others/User_Management.html
    req = {
        appid	                = "//小程序的 AppID",
        openid	                = "string  //支付用户唯一标识",
        transaction_id	        = "string ?//微信订单号",
        mch_id	                = "string ?//商户号，和商户订单号配合使用",
        out_trade_no	        = "string ?//商户订单号，和商户号配合使用",
    },
    res = {
        unionid                 = "//用户唯一标识 unionid",
    }
}
__.get_paid_unionid = function(req)
    return wxa.http.get("wxa/getpaidunionid", req)
end

return __
