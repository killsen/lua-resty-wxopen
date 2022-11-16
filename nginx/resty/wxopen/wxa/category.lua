
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v22.01.12" }

__.types = {

    InnerItem = {
        name	            = "string       //资质文件名称",
        url	                = "string       //资质文件示例",
    },
    ExterItem = {
        inner_list          = "InnerItem[] //资质信息说明"
    },
    Category = {
        id	                = "number       //类目 ID",
        name	            = "string       //类目名称",
        level	            = "number       //类目层级",
        father	            = "number       //类目父级 ID",
        children	        = "number[]     //子级类目 ID",
        sensitive_type	    = "number       //是否为敏感类目",  -- 1 为敏感类目，需要提供相应资质审核；0 为非敏感类目，无需审核
        qualify  = {
            exter_list      = "ExterItem[]  //资质证明",   -- sensitive_type 为 1 的类目需要提供的资质证明
        },
    },

    CertItem = {
        key	                = "string   //资质名称",
        value	            = "string   //资质图片 media_id",
    },
    CateWithCert = {
        first	            = "number   //一级类目 ID",
        second	            = "number   //二级类目 ID",
        certicates	        = "CertItem[]  ?//资质信息列表",
    },

    CateItem = {
        first_class	        = "string  //一级类目名称",
        second_class	    = "string  //二级类目名称",
        third_class	        = "string  //三级类目名称",
        first_id	        = "number  //一级类目的 ID 编号",
        second_id	        = "number  //二级类目的 ID 编号",
        third_id	        = "number  //三级类目的 ID 编号",
    },

    CateAudit = {
        first	            = "number   //一级类目 ID",
        first_name	        = "string   //一级类目名称",
        second	            = "number   //二级类目 ID",
        second_name	        = "string   //二级类目名称",
        audit_status	    = "number   //审核状态（1 审核中 2 审核不通过 3 审核通过）",
        audit_reason	    = "string   //审核不通过的原因",
    },
    CategoryInfo = {
        categories	            = "CateAudit[] //已设置的类目信息列表",
        limit	                = "number   //一个更改周期内可以添加类目的次数",
        quota	                = "number   //本更改周期内还可以添加类目的次数",
        category_limit          = "number   //最多可以设置的类目数量",
    }
}

__.get_all_categories__ = {
    "获取可以设置的所有类目",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/getallcategories.html
    req = {
        appid                   = "//小程序AppID",
    },
    res = {
        categories_list = {
            categories          = "Category[] //类目信息列表"
        },
    }
}
__.get_all_categories = function(req)
    return wxa.http.get("cgi-bin/wxopen/getallcategories", req)
end

__.get_categories_by_type__ = {
    "获取不同主体类型的类目",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/getcategorybytype.html
    req = {
        appid                   = "//小程序AppID",
        verify_type             = "number      ?//类目ID",  -- 个人主体是0；企业主体是1；政府是2；媒体是3；其他组织是4
    },
    res = {
        categories_list = {
            categories          = "Category[] //类目信息列表"
        },
    }
}
__.get_categories_by_type = function(req)
    return wxa.http.post("cgi-bin/wxopen/getcategoriesbytype", req)
end

__.get_category__ = {
    "获取已设置的所有类目",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/getcategory.html
    req = {
        appid                   = "//小程序AppID",
    },
    res = "CategoryInfo"
}
__.get_category = function(req)
    return wxa.http.get("cgi-bin/wxopen/getcategory", req)
end

__.add_category__ = {
    "添加类目",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/addcategory.html
    req = {
        appid                   = "//小程序AppID",
        categories              = "CateWithCert[]  //类目信息列表",
    },
}
__.add_category = function(req)
    return wxa.http.post("cgi-bin/wxopen/addcategory", req)
end

__.delete_category__ = {
    "删除类目",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/deletecategory.html
    req = {
        appid                   = "//小程序AppID",
        first	                = "number   //一级类目 ID",
        second	                = "number   //二级类目 ID",
    },
}
__.delete_category = function(req)
    return wxa.http.post("cgi-bin/wxopen/deletecategory", req)
end

__.modify_category__ = {
    "修改类目资质信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/modifycategory.html
    req = {
        appid                   = "//小程序AppID",
        first	                = "number   //一级类目 ID",
        second	                = "number   //二级类目 ID",
        certicates              = "CertItem[]  //资质信息列表",
    },
}
__.modify_category = function(req)
    return wxa.http.post("cgi-bin/wxopen/modifycategory", req)
end

__.get_category_list__ = {
    "获取审核时可填写的类目信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/get_category.html
    req = {
        appid                   = "//小程序AppID",
    },
    res = {
        category_list	        = "CateItem[]   //类目信息列表",
    }
}
__.get_category_list = function(req)
    return wxa.http.get("wxa/get_category", req)
end

-- 类目审核结果事件推送
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/wxa_category_audit.html
-- <xml>
-- 	<ToUserName><![CDATA[gh_fxxxxxxxa4b2]]></ToUserName>
-- 	<FromUserName><![CDATA[odxxxxM-xxxxxxxx-trm4a7apsU8]]></FromUserName>
-- 	<CreateTime>1488800000</CreateTime>
-- 	<MsgType><![CDATA[event]]></MsgType>
-- 	<Event><![CDATA[wxa_category_audit]]></Event>
-- 	<ret>2</ret>
-- 	<first>一级类目id</nickname>
-- 	<second>二级类目id</reason>
--  <reason>驳回原因</reason>
-- </xml>

return __
