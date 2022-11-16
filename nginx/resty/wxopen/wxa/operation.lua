
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.25" }

-- 运维中心
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/operation.html

__.getFeedback__ = {
    "获取用户反馈列表",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getFeedback.html
    req = {
        appid               = "string  //小程序AppID",
        page                = "number ?//分页页数: 从1开始",
        num                 = "number ?//分页数量: 默认50",
        type                = "number ?//反馈类型: 默认全部",
                            -- 1 无法打开小程序 2 小程序闪退 3 卡顿 4 黑屏白屏
                            -- 5 死机 6 界面错位 7 界面加载慢 8 其他异常
    },
    types = {
        feedback = {
            record_id       = "number   //反馈编码",
            create_time	    = "number   //创建时间",
            content         = "string   //反馈内容",
            phone           = "string   //联系电话",
            openid          = "string   //用户编码",
            nickname        = "string   //用户昵称",
            head_url        = "string   //用户头像",
            type            = "number   //反馈类型",
            systemInfo      = "string   //系统信息",
            mediaIds        = "string[] //图片列表"
        }
    },
    res = {
        list                = "feedback[] //反馈列表",
        total_num           = "number     //总条数",
    }
}
__.getFeedback = function(req)

    req.page = req.page or 1
    req.num  = req.num  or 50

    return wxa.http.get("wxaapi/feedback/list", req)

end


__.getFeedbackmedia__ = {
    "获取 mediaId 图片",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getFeedbackmedia.html
    req = {
        appid               = "string  //小程序AppID",
        record_id           = "number  //反馈编码",
        media_id            = "string  //图片编码",
    },
}
__.getFeedbackmedia = function(req)
    -- 错误返回json，成功返回图片
    return wxa.http.get("cgi-bin/media/getfeedbackmedia", req)
end


__.getJsErrSearch__ = {
    "查询错误信息",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getJsErrSearch.html
    req = {
        appid               = "string  //小程序AppID",
        errmsg_keyword      = "string  //错误关键字",
        type                = "number  //查询类型: 1 为客户端， 2为服务直达",
        client_version      = "string  //客户端版本: 可以通过 getVersionList 接口拉取, 不传或者传空代表所有版本",
        start_time          = "number  //开始时间",
        end_time            = "number  //结束时间",
        start               = "number  //分页起始值",
        limit               = "number  //一次拉取最大值",
    },
}
__.getJsErrSearch = function(req)
    return wxa.http.post("wxaapi/log/jserr_search", req)
end


__.getJsErrList__ = {
    "查询错误信息",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getJsErrList.html
    req = {
        appid               = "string    //小程序AppID",
        appVersion          = "string  ? //小程序版本: 0 全部",
        errType             = "string  ? //错误类型: 0 全部, 1 业务代码错误, 2 插件错误, 3 系统框架错误",
        startTime           = "string  ? //开始时间: 格式 yyyy-MM-dd",
        endTime             = "string  ? //结束时间: 格式 yyyy-MM-dd",
        keyword             = "string  ? //关键词过滤: 从错误中搜索关键词",
        openid              = "string  ? //发生错误的用户 openId",
        orderby             = "string  ? //排序字段: uv 或 pv 二选一",
        desc                = "string  ? //排序规则: 1 orderby字段降序, 2 orderby字段升序",
        offset              = "number  ? //分页起始值",
        limit               = "number  ? //一次拉取最大值: 最大 30",
    },
    res = {
        data                = "//错误列表",
        totalCount          = "number   //总条数",
    }
}
__.getJsErrList = function(req)

    return wxa.http.post("wxaapi/log/jserr_list", {
        appid       = req.appid,

        appVersion  = req.appVersion or "0",
        errType     = req.errType    or "0",
        startTime   = req.startTime  or ngx.today(),
        endTime     = req.endTime    or ngx.today(),
        keyword     = req.keyword    or "",
        openid      = req.openid     or "",
        orderby     = req.orderby    or "uv",
        desc        = req.desc       or "1",
        offset      = req.offset     or 0,
        limit       = req.limit      or 30,
    })

end


__.getVersionList__ = {
    "获取客户端版本",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getVersionList.html
    req = {
        appid               = "string    //小程序AppID",
    },
    types = {
        cv = {
            type                = "number   //查询类型: 1 代表客户端, 2 代表服务直达",
            client_version_list = "string[] //版本列表",
        }
    },
    res = {
        cvlist              = "cv[]      //版本列表",
    }
}
__.getVersionList = function(req)
    return wxa.http.get("wxaapi/log/get_client_version", req)
end


__.getSceneList__ = {
    "获取访问来源",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/operation/operation.getSceneList.html
    req = {
        appid               = "string    //小程序AppID",
    },
    types = {
        scene = {
            name            = "string   //来源名称",
            value           = "number   //来源编码",
        }
    },
    res = {
        scene               = "scene[]  //访问来源",
    }
}
__.getSceneList = function(req)
    return wxa.http.get("wxaapi/log/get_scene", req)
end


return __
