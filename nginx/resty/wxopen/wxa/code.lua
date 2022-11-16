
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

-- 第三方小程序开发模式说明
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/product/how_to_dev.html
-- 第三方平台在开发者工具上开发完成后，可点击上传，代码将上传到开放平台草稿箱中，
-- 第三方平台可选择将代码添加到模板中，获得代码模板 ID 后，可调用以下接口进行代码管理。

__.commit__ = {
    "1. 上传小程序代码",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/commit.html
    req  = {
        appid           = "string  //小程序AppID",
        template_id     = "number  //代码库中的代码模板 ID",
        ext_json        = "string  //第三方自定义的配置",
        user_version    = "string  //代码版本号: 开发者可自定义（长度不要超过 64 个字符）",
        user_desc       = "string  //代码描述: 开发者可自定义",
    }
}
__.commit = function(req)
    return wxa.http.post("wxa/commit", req)
end

__.get_qrcode__ = {
    "2. 获取小程序的体验版二维码",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/get_qrcode.html
    req  = {
        appid           = "//小程序AppID",
        path            = "?//指定二维码扫码后直接进入指定页面并可同时带上参数）",
    }
}
__.get_qrcode = function(req)

    -- 注意： path 需要进行一次 urlencode，
    -- 如：page/index?action=1，需要填入 page%2Findex%3Faction%3D1

    return wxa.http.get("wxa/get_qrcode", {
        appid = req.appid,
        path  = req.path and ngx.escape_uri(req.path) or nil,
    })

end

__.get_category__ = {
    "3. 获取审核时可填写的类目信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/category/get_category.html
    req  = {
        appid           = "//小程序AppID",
    },
    types = {
        category = {
            first_class	    = "string //一级类目名称",
            second_class	= "string //二级类目名称",
            third_class	    = "string //三级类目名称",
            first_id	    = "number //一级类目的 ID 编号",
            second_id	    = "number //二级类目的 ID 编号",
            third_id	    = "number //三级类目的 ID 编号",
        }
    },
    res = {
        category_list   = "category[] //类目信息列表"
    }
}
__.get_category = function(req)
    return wxa.http.get("wxa/get_category", req)
end

__.get_page__ = {
    "4. 获取已上传的代码的页面列表",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/get_page.html
    req  = {
        appid           = "//小程序AppID",
    },
    res = {
        page_list       = "string[] //页面配置列表"
    }
}
__.get_page = function(req)
    return wxa.http.get("wxa/get_page", req)
end

__.submit_audit__ = {
    "5. 提交审核",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/submit_audit.html
    req  = {
        appid           = "//小程序AppID",
        item_list	    = "audit_item[]	?//审核项列表（选填，至多填写 5 项）",
        preview_info	= "preview_info	?//预览信息（小程序页面截图和操作录屏）",
        version_desc	= "string	    ?//小程序版本说明和功能解释",
        feedback_info	= "string	    ?//反馈内容，至多 200 字",
        feedback_stuff	= "string	    ?//用 | 分割的 media_id 列表，至多 5 张图片, 可以通过新增临时素材接口上传而得到",
        ugc_declare	    = "object	    ?//用户生成内容场景（UGC）信息安全声明",
    },
    types = {
        preview_info = {
            video_id_list   = "string[] ?//录屏mediaid列表，可以通过提审素材上传接口获得",
            pic_id_list     = "string[] ?//截屏mediaid列表，可以通过提审素材上传接口获得",
        },
        audit_item = {
            address	        = "string  ?//小程序的页面，可通过获取小程序的页面列表接口获得",
            tag	            = "string  ?//小程序的标签，用空格分隔，标签至多 10 个，标签长度至多 20",
            first_class	    = "string  ?//一级类目名称",
            second_class	= "string  ?//二级类目名称",
            third_class	    = "string  ?//三级类目名称",
            first_id	    = "number  ?//一级类目的 ID",
            second_id	    = "number  ?//二级类目的 ID",
            third_id	    = "number  ?//三级类目的 ID",
            title	        = "string  ?//小程序页面的标题,标题长度至多 32",
        }
    },
    res = {
        auditid         = "string   //审核编号"
    }
}
__.submit_audit = function(req)

    local res, err, code = wxa.http.post("wxa/submit_audit", req)
    if not res then return nil, err, code end

    res.auditid = tostring(res.auditid)  -- 转字符串

    return res

end

-- 6. 代码审核结果推送
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/audit_event.html

__.get_audit_status__ = {
    "7. 查询指定版本的审核状态",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/get_auditstatus.html
    req  = {
        appid           = "//小程序AppID",
        auditid         = "string   //审核编号"
    },
    res = {
        status	        = "number   //审核状态: 0 审核成功, 1 审核被拒绝, 2 审核中, 3 已撤回, 4 审核延后",
        reason	        = "string   //当 status = 1 时，返回的拒绝原因; status = 4 时，返回的延后原因",
        screenshot	    = "string   //当 status = 1 时，会返回审核失败的小程序截图示例。用 | 分隔的 media_id 的列表，可通过获取永久素材接口拉取截图内容",
    }
}
__.get_audit_status = function(req)

    local  res, err = wxa.http.post("wxa/get_auditstatus", req)
    if not res then return nil, err end

    res.screenshot = res.screenshot or res.ScreenShot
    return res

end

__.get_latest_audit_status__ = {
    "8. 查询最新一次提交的审核状态",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/get_latest_auditstatus.html
    req  = {
        appid           = "//小程序AppID",
    },
    res = {
        auditid	        = "string   //最新的审核 ID",
        status	        = "number   //审核状态: 0 审核成功, 1 审核被拒绝, 2 审核中, 3 已撤回, 4 审核延后",
        reason	        = "string   //当 status = 1 时，返回的拒绝原因; status = 4 时，返回的延后原因",
        screenshot	    = "string   //当 status = 1 时，会返回审核失败的小程序截图示例。用 | 分隔的 media_id 的列表，可通过获取永久素材接口拉取截图内容",
    }
}
__.get_latest_audit_status = function(req)

    local  res, err = wxa.http.get("wxa/get_latest_auditstatus", req)
    if not res then return nil, err end

    res.auditid = tostring(res.auditid)  -- 转字符串

    res.screenshot = res.screenshot or res.ScreenShot

    return res

end

__.undo_code_audit__ = {
    "9. 小程序审核撤回",  -- 单个帐号每天审核撤回次数最多不超过 5 次（每天的额度从0点开始生效），一个月不超过 10 次
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/undocodeaudit.html
    req  = {
        appid           = "//小程序AppID",
    },
}
__.undo_code_audit = function(req)
    return wxa.http.get("wxa/undocodeaudit", req)
end

__.release__ = {
    "10. 发布已通过审核的小程序",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/release.html
    req  = {
        appid           = "//小程序AppID",
    },
}
__.release = function(req)
    return wxa.http.post("wxa/release", req)
end

-- 11. 分阶段发布
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/grayrelease.html


-- 12. 查询分阶段发布详情
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/getgrayreleaseplan.html


-- 13. 取消分阶段发布
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/revertgrayrelease.html


__.revert_code_release__ = {
    "14. 小程序版本回退",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/revertcoderelease.html
    req  = {
        appid           = "//小程序AppID",
        app_version     = "number?  //回滚版本: 默认是回滚到上一个版本, 也可回滚到指定的小程序版本"
    },
}
__.revert_code_release = function(req)

    return wxa.http.get("wxa/revertcoderelease", {
        appid       = req.appid,
        app_version = req.app_version,
    })

end

__.get_history_version__ = {
    "14. 获取可回退的小程序版本",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/get_history_version.html
    req  = {
        appid           = "//小程序AppID",
    },
    types = {
        HistoryVersion = {
            commit_time     = "number //更新时间戳",
            user_version    = "string //模板版本号",
            user_desc       = "string //模板描述",
            app_version     = "number //小程序版本",
        }
    },
    res = {
        version_list    = "HistoryVersion[] //历史版本列表"
    }
}
__.get_history_version = function(req)

    return wxa.http.get("wxa/revertcoderelease", {
        appid   = req.appid,
        action  = "get_history_version",
    })

end


__.change_visit_status__ = {
    "15. 修改小程序线上代码的可见状态",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/change_visitstatus.html
    req  = {
        appid           = "//小程序AppID",
        action          = "//设置可访问状态: 发布后默认可访问，close 为不可见，open 为可见",
    },
}
__.change_visit_status = function(req)
    return wxa.http.post("wxa/change_visitstatus", req)
end

__.get_weapp_support_version__ = {
    "16. 查询当前设置的最低基础库版本及各版本用户占比",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/getweappsupportversion.html
    req  = {
        appid           = "//小程序AppID",
    },
    types = {
        uv_info_item = {
            percentage      = "number  //百分比",
            version         = "string //基础库版本号",
        }
    },
    res = {
        now_version     = "//当前版本",
        uv_info         = {
            items       = "uv_info_item[] //版本的用户占比列表"
        }
    }
}
__.get_weapp_support_version = function(req)
    return wxa.http.post("cgi-bin/wxopen/getweappsupportversion", req)
end

__.set_weapp_support_version__ = {
    "17. 设置最低基础库版本",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/setweappsupportversion.html
    req  = {
        appid           = "//小程序AppID",
        version         = "//基础库版本号",
    },
}
__.set_weapp_support_version = function(req)
    return wxa.http.post("cgi-bin/wxopen/setweappsupportversion", req)
end

__.query_quota__ = {
    "18. 查询服务商的当月提审限额和加急次数（Quota）",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/query_quota.html
    req  = {
        appid           = "//小程序AppID",
    },
    res  = {
        rest	        = "number //quota剩余值",
        limit	        = "number //当月分配quota",
        speedup_rest	= "number //剩余加急次数",
        speedup_limit	= "number //当月分配加急次数",
    }
}
__.query_quota = function(req)
    return wxa.http.get("wxa/queryquota", req)
end

__.speedup_audit__ = {
    "19. 加急审核申请",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/code/speedup_audit.html
    req  = {
        appid           = "//小程序AppID",
        auditid         = "number //审核单ID",
    },
}
__.speedup_audit = function(req)
    return wxa.http.post("wxa/speedupaudit", req)
end

return __
