
local wxa   = require "resty.wxopen.wxa"
local cjson = require "cjson.safe"

local __ = { _VERSION = "v25.04.24" }

-- 半屏小程序申请状态
local EmbeddedStatus = {
    [1] = "待验证",
    [2] = "已通过",
    [3] = "已拒绝",
    [4] = "已超时",
    [5] = "已撤销",
    [6] = "已取消授权",
}

__.types = {
    EmbeddedApp = {
        appid       = "string //半屏小程序AppID",
        create_time = "number //添加时间",
        headimg     = "string //头像url",
        nickname    = "string //半屏小程序昵称",
        reason      = "string //申请理由",
        status      = "string //申请状态",
    },
}

__.get_list__ = {
    "获取半屏小程序调用列表",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/embedded-management/getEmbeddedList.html
    req  = {
        { "appid"           , "授权方AppID"                 },
    },
    res  = "@EmbeddedApp[]",
}
__.get_list = function(req)

    local res, err = wxa.http.get("wxaapi/wxaembedded/get_list", { appid = req.appid })
    if not res then return nil, err end

    local list = res.wxa_embedded_list or {} --> @EmbeddedApp[]

    for _, d in ipairs(list) do
        d.status = EmbeddedStatus[d.status] or "未知状态"
        if type(d.headimg) == "string" and d.headimg:sub(-2) ~= "/0" then
            d.headimg = d.headimg .. "/0"  -- 补全头像url
        end
    end

    return list

end

__.add_embedded__ = {
    "添加半屏小程序",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/embedded-management/addEmbedded.html
    req  = {
        { "appid"           , "授权方AppID"                 },
        { "embedded_appid"  , "添加的半屏小程序AppID"       },
        { "apply_reason?"   , "申请理由: 不超过30个字"      },
    },
    res  = {
        { "errcode"         , "错误码"      , "number"      },
        { "errmsg"          , "错误信息"                    },
    }
}
__.add_embedded = function(req)
    return wxa.http.post("wxaapi/wxaembedded/add_embedded", {
        appid   = req.appid,
        body    = cjson.encode {
            appid           = req.embedded_appid,
            apply_reason    = req.apply_reason,
        },
    })
end

__.del_embedded__ = {
    "删除半屏小程序",
--  https://developers.weixin.qq.com/doc/oplatform/openApi/OpenApiDoc/miniprogram-management/embedded-management/deleteEmbedded.html
    req  = {
        { "appid"           , "授权方AppID"                 },
        { "embedded_appid"  , "删除的半屏小程序AppID"       },
    },
    res  = {
        { "errcode"         , "错误码"      , "number"      },
        { "errmsg"          , "错误信息"                    },
    }
}
__.del_embedded = function(req)
    return wxa.http.post("wxaapi/wxaembedded/del_embedded", {
        appid   = req.appid,
        body    = cjson.encode {
            appid = req.embedded_appid,
        },
    })
end

return __
