
local wxa               = require "resty.wxopen.wxa"
local http              = wxa.http
local _encode           = require "cjson.safe".encode

local __ = { _VERSION = "v21.02.22" }

__.getUserRiskRank__ = {
    "根据提交的用户信息数据获取用户的安全等级",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/safety-control-capability/riskControl.getUserRiskRank.html
    req = {
        appid               = "string    //小程序AppID",
        openid              = "string    //用户的OpenID",
        scene               = "number    //场景值: 0 注册, 1 营销作弊",
        mobile_no           = "string   ?//用户手机号",
        client_ip           = "string    //用户访问源IP",
        email_address       = "string   ?//用户邮箱地址",
        extended_info       = "string   ?//额外补充信息",
        is_test             = "boolean  ?//是否测试调用",
    },
    res = {
        unoin_id            = "number    //唯一请求标识",
        risk_rank           = "number    //用户风险等级",
    }
}
__.getUserRiskRank = function(req)

    local  access_token, err = wxa.get_access_token_by_secret(req.appid)
    if not access_token then return nil, err end

    return http {
        url     = "wxa/getuserriskrank",
        query   = { access_token = access_token },
        body    = _encode(req),
    }

end

return __
