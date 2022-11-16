
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v22.01.10" }

-- 小程序插件管理
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/pluginManager.html

wxa.http.errcode.set {
    [89236] = [[该插件不能申请]],
    [89237] = [[已经添加该插件]],
    [89238] = [[申请或使用的插件已经达到上限]],
    [89239] = [[该插件不存在]],
    [89240] = [[无法进行此操作，只有“待确认”的申请可操作通过/拒绝]],
    [89241] = [[无法进行此操作，只有“已拒绝/已超时”的申请可操作删除]],
    [89242] = [[该appid不在申请列表内]],
    [89243] = [[“待确认”的申请不可删除]],
    [89244] = [[该appid不在申请列表内]],   -- 实际测试错误，官方文档未声明
    [89044] = [[不存在该插件appid]],
}

__.types = {
    plugin = {
        appid	    = "string  //插件 appid",
        status	    = "number  //插件申请状态",  -- 1 申请中, 2 申请通过, 3 被拒绝, 4 申请已超时
        nickname	= "string  //插件昵称",
        headimgurl	= "string  //插件头像",
        reason      = "string  //拒绝原因",
    }
}

__.list__ = {
    "查询已添加的插件列表",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/plugin-management/pluginManager.getPluginList.html
    req = {
        appid           = "string  //小程序AppID",
    },
    res = {
        plugin_list     = "plugin[] //插件信息列表"
    }
}
__.list = function(req)

    return wxa.http.post("wxa/plugin", {
        appid           = req.appid,
        action          = "list",
    })

end

__.apply__ = {
    "申请使用插件",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/plugin-management/pluginManager.applyPlugin.html
    req = {
        appid           = "string  //小程序AppID",
        plugin_appid	= "string  //插件的AppID",
    },
}
__.apply = function(req)

    return wxa.http.post("wxa/plugin", {
        appid           = req.appid,
        action          = "apply",
        plugin_appid    = req.plugin_appid,
    })

end

__.unbind__ = {
    "删除已添加的插件",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/plugin-management/pluginManager.unbindPlugin.html
    req = {
        appid           = "string  //小程序AppID",
        plugin_appid	= "string  //插件的AppID",
    },
}
__.unbind = function(req)

    return wxa.http.post("wxa/plugin", {
        appid           = req.appid,
        action          = "unbind",
        plugin_appid    = req.plugin_appid,
    })

end

__.update__ = {
    "快速更新插件版本号",
    req = {
        appid           = "string  //小程序AppID",
        plugin_appid	= "string  //插件的AppID",
        user_version	= "string  //升级至版本号", -- 要求此插件版本支持快速更新
    },
}
__.update = function(req)

    return wxa.http.post("wxa/plugin", {
        appid           = req.appid,
        action          = "update",
        plugin_appid    = req.plugin_appid,
        user_version    = req.user_version,
    })

end

return __
