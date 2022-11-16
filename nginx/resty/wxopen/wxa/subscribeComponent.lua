
local wxa   = require "resty.wxopen.wxa"
local cjson = require "cjson.safe"

local __ = { _VERSION = "v21.02.22" }

-- 扫码关注组件
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/subscribe_component/subscribe_component.html

-- 公众号关注组件 official-account
-- https://developers.weixin.qq.com/miniprogram/dev/component/official-account.html


__.get__ = {
   "获取展示的公众号信息接口",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/subscribe_component/getshowwxaitem.html
    req = {
        appid           = "string  //授权方AppID",
    },
    res = {
        can_open	    = "number  //是否可以设置: 1 可以，0，不可以",
        is_open	        = "number  //是否已经设置: 1 已设置，0，未设置",
        appid	        = "string ?//展示的公众号 appid",
        nickname	    = "string ?//展示的公众号 nickname",
        headimg	        = "string ?//展示的公众号头像",
    },
}
__.get = function(req)
    return wxa.http.get("wxa/getshowwxaitem", req)
end


__.getList__ = {
    "获取可以用来设置的公众号列表",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/subscribe_component/getwxamplinkforshow.html
    req = {
        appid           = "string  //授权方AppID",
        page	        = "number ?//页码: 从 0 开始",
        num	            = "number ?//每页记录数: 最大为 20",
    },
    types = {
        biz_info = {
            nickname	= "string  //公众号昵称",
            appid	    = "string  //公众号AppID",
            headimg	    = "string  //公众号头像",
        }
    },
    res = {
        total_num	    = "number     //总记录数",
        biz_info_list	= "biz_info[] //公众号信息列表",
    },
}
__.getList = function(req)

    return wxa.http.get("wxa/getwxamplinkforshow", {
        appid   = req.appid,
        page    = req.page or 0,
        num     = req.num  or 20,
    })

end


__.update__ = {
    "设置展示的公众号信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/subscribe_component/updateshowwxaitem.html
    req = {
        appid           = "string   //授权方AppID",
        biz_flag        = "number   //是否打开扫码关注组件: 0 关闭，1 开启",
        biz_appid	    = "string  ?//公众号AppID: 如果开启需要传递",
    },
}
__.update = function(req)

    return wxa.http.post("wxa/updateshowwxaitem", {
        appid   = req.appid,
        body    = cjson.encode {  -- 参数含有 appid, 传递 json 字符串
            wxa_subscribe_biz_flag  = req.biz_flag,
            appid                   = req.biz_appid,
        }
    })

end


return __
