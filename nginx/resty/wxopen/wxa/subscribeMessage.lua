
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

-- 订阅消息设置
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/SubcribeMessage.html

__.getCategory__ = {
    "获取当前帐号所设置的类目信息",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getCategory.html
    req = {
        appid           = "//小程序AppID",
    },
    types = {
        category = {
            id	        = "number  //类目id",       -- 查询公共库模板时需要
            name	    = "string  //类目名称",
        },
    },
    res = {
        data            = "category[] //类目列表"
    }
}
__.getCategory = function(req)
    return wxa.http.get("wxaapi/newtmpl/getcategory", req)
end


__.getPubTemplateTitleList__ = {
    "获取模板标题列表",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getPubTemplateTitleList.html
    req = {
        appid           = "//小程序AppID",
        ids	            = "string  //类目id",    -- 多个用逗号隔开，可通过接口获取当前帐号所设置的类目信息获取
        start	        = "number  //起始位置",  -- 用于分页，表示从 start 开始。从 0 开始计数。
        limit	        = "number  //分页数量",  -- 用于分页，表示拉取 limit 条记录。最大为 30。用于分页，表示拉取 limit 条记录。最大为 30。
    },
    types = {
        title = {
            tid	        = "number  //模板标题id",
            title	    = "string  //模板标题",
            type	    = "number  //模板类型: 2 为一次性订阅，3 为长期订阅",
            categoryId	= "string  //模板所属类目 id",
        },
    },
    res = {
        count	        = "number  //模板标题列表总数",
        data            = "title[] //模板标题列表",
    }
}
__.getPubTemplateTitleList = function(req)
    return wxa.http.get("wxaapi/newtmpl/getpubtemplatetitles", req)
end


__.getPubTemplateKeyWordsById__ = {
    "获取模板标题下的关键词库",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getPubTemplateKeyWordsById.html
    req = {
        appid           = "//小程序AppID",
        tid	            = "number  //模板标题id",
    },
    types = {
        keyword = {
            kid	        = "number  //关键词id，选用模板时需要",
            name	    = "string  //关键词内容",
            example	    = "string  //关键词内容对应的示例",
            rule	    = "string  //参数类型",
        },
    },
    res = {
        data            = "keyword[] //关键词列表",
    }
}
__.getPubTemplateKeyWordsById = function(req)
    return wxa.http.get("wxaapi/newtmpl/getpubtemplatekeywords", req)
end


__.addTemplate__ = {
    "组合模板并添加到个人模板库",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.addTemplate.html
    req = {
        appid           = "//小程序AppID",
        tid	            = "string    //模板标题id",
        kidList	        = "number[]  //关键词列表",     -- 最多支持5个，最少2个关键词组合
        sceneDesc	    = "string	?//服务场景描述",   -- 15个字以内
    },
    res = {
        priTmplId	    = "string    //添加至帐号下的模板id: 发送小程序订阅消息时所需",
    }
}
__.addTemplate = function(req)
    return wxa.http.post("wxaapi/newtmpl/addtemplate", req)
end


__.getTemplateList__ = {
    "组合模板并添加到个人模板库",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getTemplateList.html
    req = {
        appid           = "//小程序AppID",
    },
    types = {
        template = {
            priTmplId	= "string  //添加至帐号下的模板id: 发送小程序订阅消息时所需",
            title	    = "string  //模板标题",
            content	    = "string  //模板内容",
            example	    = "string  //模板内容示例",
            type	    = "number  //模板类型: 2 代表一次性订阅，3 代表长期订阅",
        },
    },
    res = {
        data	        = "template[] //个人模板列表",
    }
}
__.getTemplateList = function(req)
    return wxa.http.get("wxaapi/newtmpl/gettemplate", req)
end


__.deleteTemplate__ = {
    "删除帐号下的某个模板",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.deleteTemplate.html
    req = {
        appid           = "//小程序AppID",
        priTmplId	    = "//要删除的模板id",
    },
}
__.deleteTemplate = function(req)
    return wxa.http.post("wxaapi/newtmpl/deltemplate", req)
end


__.send__ = {
    "发送订阅消息",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
    req = {
        appid               = "//小程序AppID",
        touser	            = "string   //接收者的 openid",
        template_id	        = "string   //所需下发的订阅模板id",
        page	            = "string  ?//点击模板卡片后的跳转页面", -- 仅限本小程序内的页面。支持带参数,（示例index?foo=bar）。该字段不填则模板无跳转。
        data	            = "object   //模板内容",
        miniprogram_state	= "string  ?//跳转小程序类型",  -- developer为开发版, trial为体验版, formal为正式版, 默认为正式版
        lang	            = "string  ?//语言类型",        -- 支持zh_CN(简体中文), en_US(英文), zh_HK(繁体中文), zh_TW(繁体中文), 默认为zh_CN
    },
}
__.send = function(req)

    local data = {}
    for k, v in pairs(req.data) do
        data[k] = { value = v }
    end

    return wxa.http.post("cgi-bin/message/subscribe/send", {
        appid               = req.appid,
        touser              = req.touser,
        template_id         = req.template_id,
        page                = req.page,
        data                = data,
        miniprogram_state   = req.miniprogram_state,
        lang                = req.lang,
    })

end

return __
