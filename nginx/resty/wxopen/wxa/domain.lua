
local wxa = require "resty.wxopen.wxa"
local _insert   = table.insert

local __ = { _VERSION = "v24.09.23" }

__.modify_domain__ = {
    "设置服务器域名",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/domain-management/modifyServerDomain.html
    req = {
        appid           = "//小程序AppID",
        action          = "string    //操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        requestdomain   = "string[] ?//request 合法域名",       -- 当 action 是 get 时不需要以下字段
        wsrequestdomain = "string[] ?//socket 合法域名",
        uploaddomain    = "string[] ?//uploadFile 合法域名",
        downloaddomain  = "string[] ?//downloadFile 合法域名",
        udpdomain       = "string[] ?//upd 合法域名",
        tcpdomain       = "string[] ?//tcp 合法域名",
    },
    res = {
        requestdomain   = "string[]  //request 合法域名",
        wsrequestdomain = "string[]  //socket 合法域名",
        uploaddomain    = "string[]  //uploadFile 合法域名",
        downloaddomain  = "string[]  //downloadFile 合法域名",
        udpdomain       = "string[]  //upd 合法域名",
        tcpdomain       = "string[]  //tcp 合法域名",
    }
}
__.modify_domain = function(req)
    return wxa.http.post("wxa/modify_domain", req)
end

__.set_webview_domain__ = {
    "设置业务域名",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/domain-management/modifyJumpDomain.html
    req = {
        appid           = "//小程序AppID",
        -- 如果没有指定 action，则默认将第三方平台登记的小程序业务域名全部添加到该小程序
        action          = "string   ?//操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        webviewdomain   = "string[] ?//小程序业务域名",  -- 当 action 是 get 时不需要此字段
    },
    res = {
        webviewdomain   = "string[] ?//小程序业务域名",
    }
}
__.set_webview_domain = function(req)
    return wxa.http.post("wxa/setwebviewdomain", req)
end

__.modify_wxa_server_domain__ = {
    "设置第三方平台服务器域名",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/domain/modify_server_domain.html
    req = {
        action                       = "string    //操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        is_modify_published_together = "boolean  ?//是否同时修改全网发布版本",
        wxa_server_domain            = "string   ?//服务器域名",
    },
    res = {
        published_wxa_server_domain  = "string   //发布版服务器域名",
        testing_wxa_server_domain    = "string   //测试版服务器域名",
        invalid_wxa_server_domain    = "string ? //未通过验证的域名",
    }
}
__.modify_wxa_server_domain = function(req)

    return wxa.http.token {
        url  = "cgi-bin/component/modify_wxa_server_domain",
        body = {
            action                       = req.action,
            is_modify_published_together = req.is_modify_published_together,
            wxa_server_domain            = req.wxa_server_domain,
        }
    }

end

__.get_domain_confirmfile__ = {
    "获取第三方业务域名的校验文件",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/domain/get_domain_confirmfile.html
    res = {
        file_name       = "string   //校验文件名称",
        file_content    = "string   //校验文件内容",
    }
}
__.get_domain_confirmfile = function()

    return wxa.http.token {
        url  = "cgi-bin/component/get_domain_confirmfile",
        body = ""
    }

end

__.modify_wxa_jump_domain__ = {
    "设置第三方平台业务域名",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/domain/modify_jump_domain.html
    req = {
        action                       = "string    //操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        is_modify_published_together = "boolean  ?//是否同时修改全网发布版本",
        wxa_jump_h5_domain           = "string   ?//业务域名",
    },
    res = {
        published_wxa_jump_h5_domain = "string   //发布版业务域名",
        testing_wxa_jump_h5_domain   = "string   //测试版业务域名",
        invalid_wxa_jump_h5_domain   = "string ? //未通过验证的域名",
    }
}
__.modify_wxa_jump_domain = function(req)

    return wxa.http.token {
        url  = "cgi-bin/component/modify_wxa_jump_domain",
        body = {
            action                       = req.action,
            is_modify_published_together = req.is_modify_published_together,
            wxa_jump_h5_domain            = req.wxa_jump_h5_domain,
        }
    }

end

__.get_prefetch_dns_domain__ = {
    "获取DNS预解析域名",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/domain-management/getPrefetchDomain.html
    req = {
        appid = "string //小程序AppID",
    },
    types = {
        DnsDomain = {
            url     = "string //域名",
            status  = "number //状态",
        },
    },
    res = {
        prefetch_dns_domain = "@DnsDomain[] //预解析域名列表",
        size_limit          = "number       //总共可配置域名个数",
    },
}
__.get_prefetch_dns_domain = function(req)

    return wxa.http.get("wxa/get_prefetchdnsdomain", {
        appid = req.appid,
    })

end

__.set_prefetch_dns_domain__ = {
    "设置DNS预解析域名",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/domain-management/setPrefetchDomain.html
    req = {
        appid   = "string   //小程序AppID",
        domain  = "string[] //预解析域名列表",
    },
    res = {}
}
__.set_prefetch_dns_domain = function(req)

    local domain = {}  --> { url }[]

    for _, url in ipairs(req.domain) do
        _insert(domain, { url = url })
    end

    return wxa.http.post("wxa/set_prefetchdnsdomain", {
        appid = req.appid,
        body  = {
            prefetch_dns_domain = domain,
        }
    })

end

return __
