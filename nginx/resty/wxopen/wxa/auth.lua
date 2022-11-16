
local wxa  = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.25" }

__.types = {

    func = {
        id                          = "number   //权限集编码",
        name                        = "string   //权限集名称",
        desc                        = "string   //权限集描述",
        is_mutex                    = "boolean  //权限集互斥",
        doc_title                   = "string   //服务协议",
        doc_link                    = "string   //服务协议链接",
        already_confirm             = "number   //是否已经确认",
        can_confirm                 = "number   //是否可以确认",
        need_confirm                = "number   //是否需要确认",
    },

    category = {
        first                       = "string   //一级类目",
        second                      = "string   //二级类目",
    },

    app_info = {
        visit_status                = "number       //可否访问",
        categories                  = "category[]   //小程序类目",
        network                     = {
            BizDomain               = "string[]     //业务域名",
            DownloadDomain          = "string[]     //下载域名",
            RequestDomain           = "string[]     //请求域名",
            UDPDomain               = "string[]     //UPP域名",
            TCPDomain               = "string[]     //TCP域名",
            UploadDomain            = "string[]     //上传域名",
            WsRequestDomain         = "string[]     //WS域名",
        },
    },

    authorization_info = {
        authorizer_appid            = "string   //授权方AppID",
        authorizer_refresh_token    = "string   //刷新令牌",
        authorizer_access_token     = "string ? //接口调用令牌",
        expires_in                  = "number ? //有效期，单位：秒",
        func_info                   = "func[]   //授权给开发者的权限集列表",
    },

    authorizer_info = {
        appid                       = "string   //授权方AppID",
        nick_name	                = "string   //昵称",
        head_img	                = "string   //头像",
        user_name	                = "string   //原始ID",
        principal_name	            = "string   //主体名称",
        alias	                    = "string   //公众号所设置的微信号: 可能为空",
        qrcode_url	                = "string   //二维码图片的URL",

        business_info	            = { "//功能的开通状况: 0代表未开通，1代表已开通",
            open_store              = "number   //开通微信门店功能",
            open_scan               = "number   //开通微信扫商品功能",
            open_pay                = "number   //开通微信支付功能",
            open_card               = "number   //开通微信卡券功能",
            open_shake              = "number   //开通微信摇一摇功能",
        },
        service_type_info           = { "//小程序或公众号类型",
            id                      = "number   //类型编码",
            name                    = "string   //类型名称",
        },
        verify_type_info            = { "//认证类型",
            id                      = "number   //认证类型编码",
            name                    = "string   //认证类型名称",
        },

        func_info                   = "func[]       //授权给开发者的权限集列表",
        app_info                    = "app_info   ? //小程序信息",
    },

    authorizer_item = {
        authorizer_appid            = "string   //授权方AppID",
        refresh_token               = "string   //刷新令牌",
        auth_time                   = "number   //授权时间",
    }
}

-- 公众号类型
local service_type = {
    [0 ]  = "订阅号",
    [1 ]  = "由历史老帐号升级后的订阅号",
    [2 ]  = "服务号",
}

-- 小程序类型
local wxapp_type = {
    [0 ]  = "普通小程序",
    [12]  = "试用小程序",
    [4 ]  = "小游戏",
    [10]  = "小商店",
}

-- 认证类型
local verify_type = {
    -- 小程序或公众号认证类型
    [-1] = "未认证",
    [0 ] = "微信认证",

    -- 其它公众号认证类型
    [1 ] = "新浪微博认证",
    [2 ] = "腾讯微博认证",
    [3 ] = "已资质认证通过但还未通过名称认证",
    [4 ] = "已资质认证通过、还未通过名称认证，但通过了新浪微博认证",
    [5 ] = "已资质认证通过、还未通过名称认证，但通过了腾讯微博认证",
}

__.create_pre_auth_code__ = {
    "获取预授权码",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/pre_auth_code.html
    res = {
        pre_auth_code           = "//预授权码",
        expires_in              = "number //有效期，单位：秒",
    }
}
__.create_pre_auth_code = function()

    return wxa.http.token {
        url     = "cgi-bin/component/api_create_preauthcode",
        query   = { component_access_token  = true                          },
        body    = { component_appid         = wxa.ctx.get_component_appid() },
    }

end

__.create_pre_auth_link__ = {
    "获取预授权链接",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Before_Develop/Authorization_Process_Technical_Description.html
    req = {
        redirect_uri	        = "//回调 URI",
        auth_type               = "?//要授权的帐号类型: 1公众号, 2小程序, 3公众号和小程序",
        biz_appid               = "?//指定授权唯一的小程序或公众号"
    },
    res = {
        pre_auth_code           = "//预授权码",
        pre_auth_link           = "//预授权链接",
        expires_in              = "number //有效期，单位：秒",
    }
}
__.create_pre_auth_link = function(req)

    local  res, err = __.create_pre_auth_code()
    if not res then return nil, err end

    local pre_auth_code = res.pre_auth_code
    local expires_in    = res.expires_in

    local pre_auth_link =
        "https://mp.weixin.qq.com/safe/bindcomponent?"
        .. ngx.encode_args {
                action          = "bindcomponent",
                no_scan         = "1",
                component_appid = wxa.ctx.get_component_appid(),
                pre_auth_code   = pre_auth_code,
                redirect_uri    = req.redirect_uri,
                auth_type       = req.auth_type,
                biz_appid       = req.biz_appid,
            }
        .. "#wechat_redirect"

    return {
        pre_auth_code   = pre_auth_code,
        pre_auth_link   = pre_auth_link,
        expires_in      = expires_in,
    }

end

__.get_authorizer_info__ = {
    "获取授权方的帐号基本信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/token/api_get_authorizer_info.html
    req = {
        authorizer_appid            = "//授权方AppID",
    },
    res = "authorizer_info"
}
__.get_authorizer_info = function(req)

    local res, err = wxa.http.token {
        url     = "cgi-bin/component/api_get_authorizer_info",
        query   = {
            component_access_token  = true,
        },
        body    = {
            component_appid         = wxa.ctx.get_component_appid(),
            authorizer_appid        = req.authorizer_appid,
        },
    }
    if not res then return nil, err end

    -- 基本信息
    local info = res.authorizer_info
    info.appid = res.authorization_info.authorizer_appid

    -- 权限集
    info.func_list = res.authorization_info.func_info

    for i, f in ipairs(info.func_list) do
        local conf = f.confirm_info or {}
        info.func_list[i] = wxa.authority.set_authority {  -- 填充权限集
            id              = f.funcscope_category.id,
            already_confirm = conf.already_confirm  or 0,
            can_confirm     = conf.can_confirm      or 0,
            need_confirm    = conf.need_confirm     or 0,
        }
    end

    -- 小程序信息
    info.app_info = info.MiniProgramInfo
    info.MiniProgramInfo = nil

    local service_type_info = info.service_type_info
    if info.app_info then
        -- 小程序类型
        service_type_info.name = wxapp_type[service_type_info.id]
    else
        -- 公众号类型
        service_type_info.name = service_type[service_type_info.id]
    end

    -- 认证类型
    local verify_type_info  = info.verify_type_info
    verify_type_info.name = verify_type[verify_type_info.id]

    return info

end

__.get_authorizer_option__ = {
    "获取授权方选项信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/Account_Authorization/api_get_authorizer_option.html
    req = {
        authorizer_appid            = "//授权方AppID",
        option_name                 = "//选项名称",
    },
    res = {
        authorizer_appid            = "//授权方AppID",
        option_name                 = "//选项名称",
        option_value                = "//选项值",
    }
}
__.get_authorizer_option = function(req)

    return wxa.http.token {
        url     = "cgi-bin/component/api_get_authorizer_option",
        query   = {
            component_access_token  = true,
        },
        body    = {
            component_appid         = wxa.ctx.get_component_appid(),
            authorizer_appid        = req.authorizer_appid,
            option_name             = req.option_name,
        },
    }

end

-- option_name         选项名说明          option_value   选项值说明
-- location_report     地理位置上报选项    0 无上报        1 进入会话时上报    2 每 5s 上报
-- voice_recognize     语音识别开关选项    0 关闭语音识别  1 开启语音识别
-- customer_service    多客服开关选项      0 关闭多客服    1 开启多客服

__.set_authorizer_option__ = {
    "设置授权方选项信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/Account_Authorization/api_set_authorizer_option.html
    req = {
        authorizer_appid            = "//授权方AppID",
        option_name                 = "//选项名称",
        option_value                = "//选项值",
    }
}
__.set_authorizer_option = function(req)

    return wxa.http.token {
        url     = "cgi-bin/component/api_set_authorizer_option",
        query   = {
            component_access_token  = true,
        },
        body    = {
            component_appid         = wxa.ctx.get_component_appid(),
            authorizer_appid        = req.authorizer_appid,
            option_name             = req.option_name,
            option_value            = req.option_value,
        },
    }

end

__.get_authorizer_list__ = {
    "拉取所有已授权的帐号信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/Account_Authorization/api_get_authorizer_list.html
    req = {
        offset          = "number ?//偏移位置",
        count           = "number ?//拉取数量",  -- 最大为 500
    },
    res = {
        total_count     = "number //授权的帐号总数",
        list            = "authorizer_item[] //当前查询的帐号基本信息列表",
    }
}
__.get_authorizer_list = function(req)

    return wxa.http.token {
        url     = "cgi-bin/component/api_get_authorizer_list",
        query   = {
            component_access_token  = true,
        },
        body    = {
            component_appid         = wxa.ctx.get_component_appid(),
            offset                  = req.offset or 0,
            count                   = req.count  or 500,
        },
    }

end

return __
