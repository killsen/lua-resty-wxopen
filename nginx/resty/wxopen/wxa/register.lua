
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.24" }

-- 代注册小程序
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/product/Register_Mini_Programs/Intro.html
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/product/Register_Mini_Programs/Fast_Registration_Interface_document.html

local ERR_CODE = {
    [89249] = "该主体已有任务执行中，距上次任务24小时后再试",
    [89247] = "内部错误",
    [86004] = "无效微信号",
    [61070] = "法人姓名与微信号不一致",
    [89248] = "企业代码类型无效，请选择正确类型填写",
    [89250] = "未找到该任务",
    [89251] = "待法人人脸核身校验",
    [89252] = "法人&企业信息一致性校验中",
    [89253] = "缺少参数",
    [89254] = "第三方权限集不全，请补充权限集后重试",
    [89255] = "企业代码无效",
}

__.fast_register_weapp__ = {
    "快速注册企业小程序",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Register_Mini_Programs/Fast_Registration_Interface_document.html
    req = {
        name	                = "string  //企业名",       -- 需与工商部门登记信息一致
        code	                = "string  //企业代码",
        code_type	            = "number  //企业代码类型", -- 1：统一社会信用代码（18 位） 2：组织机构代码（9 位 xxxxxxxx-x） 3：营业执照注册号(15 位)
        legal_persona_wechat	= "string  //法人微信号",
        legal_persona_name	    = "string  //法人姓名",     -- 绑定银行卡
        component_phone	        = "string ?//第三方联系电话",
    },
}
__.fast_register_weapp = function(req)

    local res, err, code = wxa.http.token {
        url     = "cgi-bin/component/fastregisterweapp",
        query   = { access_token = true, action = "create" },
        body    = req,
    }

    if res then return res end

    err = ERR_CODE[code] or err

    return nil, err, code

end

__.fast_register_weapp_search__ = {
    "快速创建小程序查询",
    --  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Register_Mini_Programs/Fast_Registration_Interface_document.html
    req = {
        name	                = "string  //企业名",       -- 需与工商部门登记信息一致
        legal_persona_wechat	= "string  //法人微信号",
        legal_persona_name	    = "string  //法人姓名",     -- 绑定银行卡
    },
}
__.fast_register_weapp_search = function(req)

    local res, err, code = wxa.http.token {
        url     = "cgi-bin/component/fastregisterweapp",
        query   = { access_token = true, action = "search" },
        body    = req,
    }

    if res then return res end

    err = ERR_CODE[code] or err

    return nil, err, code

end

__.fast_register_beta_weapp__ = {
    "创建试用小程序",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/beta_Mini_Programs/fastregister.html
    req = {
        name            = "//小程序名称",
        openid          = "//微信用户的openid: 不是微信号",
    },
    res = {
        unique_id       = "//该请求的唯一标识符",   -- 用于关联微信用户和后面产生的appid
        authorize_url   = "//用户授权确认url",      -- 需将该url发送给用户，用户进入授权页面完成授权方可创建小程序
    }
}
__.fast_register_beta_weapp = function(req)

    return wxa.http.token {
        url     = "wxa/component/fastregisterbetaweapp",
        query   = { access_token = true },
        body    = req,
    }

end

__.set_beta_weapp_nickname__ = {
    "修改试用小程序名称",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/beta_Mini_Programs/fastmodify.html
    req = {
        appid           = "//小程序AppID",
        name            = "//小程序名称",
    },
}
__.set_beta_weapp_nickname = function(req)
    return wxa.http.post("wxa/setbetaweappnickname", req)
end

__.verify_beta_weapp__ = {
    "试用小程序快速认证",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/beta_Mini_Programs/fastverify.html
    req = {
        appid           = "//小程序AppID",
        verify_info     = {"//企业法人认证需要的信息",
            enterprise_name	        = "string  //企业名",       -- 需与工商部门登记信息一致
            code	                = "string  //企业代码",
            code_type	            = "number  //企业代码类型", -- 1：统一社会信用代码（18 位） 2：组织机构代码（9 位 xxxxxxxx-x） 3：营业执照注册号(15 位)
            legal_persona_wechat	= "string  //法人微信号",
            legal_persona_name	    = "string  //法人姓名",     -- 绑定银行卡
            legal_persona_idcard	= "string  //法人身份证号",
            component_phone	        = "string  //第三方联系电话",
        },
    },
}
__.verify_beta_weapp = function(req)
    return wxa.http.post("wxa/verifybetaweapp", req)
end

return __
