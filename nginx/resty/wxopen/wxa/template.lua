
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.24" }

-- 小程序模板库管理
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/operation/thirdparty/template.html
-- ​第三方平台可以通过接口，可便捷管理模板库，添加或删除小程序代码模板。

__.types = {
    draft = {
        draft_id	                = "number  //草稿 id",
        user_version	            = "string  //版本号: 开发者自定义字段",
        user_desc	                = "string  //版本描述: 开发者自定义字段",
        developer                   = "string  //开发者",
        source_miniprogram_appid    = "string  //小程序AppID",
        source_miniprogram          = "string  //来源小程序",
        create_time	                = "number  //开发者上传草稿时间戳",
    },
    template = {
        template_id                 = "number  //模板 id",
        template_type               = "number  //模板类型: 0普通模板, 1标准模板",
        user_version	            = "string  //版本号: 开发者自定义字段",
        user_desc	                = "string  //版本描述: 开发者自定义字段",
        developer                   = "string  //开发者",
        source_miniprogram_appid    = "string  //小程序AppID",
        source_miniprogram          = "string  //来源小程序",
        create_time	                = "number  //被添加为模板的时间",

        category_list	            = "category[] ? //标准模板的类目信息",
        audit_scene	                = "number? //标准模板的场景标签",
        audit_status	            = "number? //标准模板的审核状态",
        reason	                    = "string? //标准模板的审核驳回的原因",
    },
    category = {
        first_class	                = "string  //一级类目",
        first_id	                = "number  //一级类目id",
        second_class                = "string  //二级类目",
        second_id	                = "number  //二级类目id",
    }
}

__.get_template_draft_list__ = {
    "1. 获取代码草稿列表",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/code_template/gettemplatedraftlist.html
    res = {
        draft_list      = "draft[] //草稿信息列表"
    }
}
__.get_template_draft_list = function()

    local res, err, code = wxa.http.token {
        url     = "wxa/gettemplatedraftlist",
        query   = { access_token = true },
    }
    if not res then return nil, err, code end

    table.sort(res.draft_list, function(t1, t2)
        return t1.draft_id > t2.draft_id
    end)

    return res

end

__.add_to_template__ = {
    "2. 将草稿箱的草稿选为代码模板",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/code_template/addtotemplate.html
    req = {
        draft_id	    = "number   //草稿 id",
        template_type   = "number?  //模板类型: 0普通模板, 1标准模板",
    },
}
__.add_to_template = function(req)

    return wxa.http.token {
        url     = "wxa/addtotemplate",
        query   = { access_token = true },
        body    = req,
    }

end

__.get_template_list__ = {
    "3. 获取代码模版库中的代码模板",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/code_template/gettemplatelist.html
    req = {
        template_type   = "number?  //模板类型: 0普通模板, 1标准模板",
    },
    res = {
        template_list   = "template[] //模板信息列表",
    }
}
__.get_template_list = function(req)

    local res, err, code = wxa.http.token {
        url     = "wxa/gettemplatelist",
        query   = { access_token = true, template_type = req.template_type },
    }

    if not res then return nil, err, code end

    table.sort(res.template_list, function(t1, t2)
        return t1.template_id > t2.template_id
    end)

    return res

end

__.delete_template__ = {
    "4.删除指定代码模板",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/ThirdParty/code_template/deletetemplate.html
    req = {
        template_id     = "number   //要删除的模板 ID",
    },
}
__.delete_template = function(req)

    return wxa.http.token {
        url     = "wxa/deletetemplate",
        query   = { access_token = true },
        body    = req,
    }

end

return __
