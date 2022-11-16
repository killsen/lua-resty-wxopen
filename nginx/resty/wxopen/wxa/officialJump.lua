
local wxa       = require "resty.wxopen.wxa"
local _encode   = require "cjson.safe".encode

local __ = { _VERSION = "v21.08.20" }

-- 扫服务号二维码跳小程序
-- 二维码规则，填服务号的带参二维码url ，必须是 http://weixin.qq.com/q/ 开头的 url

__.get__ = {
   "获取已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Official__Accounts/qrcode/qrcodejumpget.html
    req = {
        { "offical_appid"           , "公众号AppID"                     },
        { "appid"                   , "跳转小程序AppID"                 },
    },
    types = {
        rule = {
            { "prefix"              , "二维码规则"                      },
            { "path"                , "小程序功能页面"                  },
            { "state"               , "发布标志位"      , "number"      },  -- 1 表示未发布，2 表示已发布"
        },
    },
    res = {
        { "qrcodejump_open"         , "是否已经打开二维码跳转链接设置"   , "number"      },
        { "list_size"               , "二维码规则数量"                  , "number"      },
        { "rule_list"               , "二维码规则详情列表"              , "rule[]"      },
    },
}
__.get = function(req)

    return wxa.http.post("cgi-bin/wxopen/qrcodejumpget", {
        appid = req.offical_appid,
        body  = _encode {
            appid = req.appid
        }
    })

end

__.add__ = {
    "增加或修改二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Official__Accounts/qrcode/qrcodejumpadd.html
    req = {
        { "offical_appid"           , "公众号AppID"                     },
        { "appid"                   , "跳转小程序AppID"                 },
        { "prefix"                  , "二维码规则"                      },
        { "path?"                   , "小程序功能页面"                  },
        { "is_edit?"                , "编辑标志位"      , "number"      },  -- 0 表示新增二维码规则，1 表示修改已有二维码规则
    },
}
__.add = function(req)

    return wxa.http.post("cgi-bin/wxopen/qrcodejumpadd", {
        appid = req.offical_appid,
        body  = _encode {
            prefix  = req.prefix,
            appid   = req.appid,
            path    = req.path    or "",
            is_edit = req.is_edit or 0
        }
    })

end

__.publish__ = {
    "发布已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumppublish.html
    req = {
        { "offical_appid"           , "公众号AppID"                     },
        { "prefix"                  , "二维码规则"                      },
    },
}
__.publish = function(req)

    return wxa.http.post("cgi-bin/wxopen/qrcodejumppublish", {
        appid = req.offical_appid,
        body  = _encode {
            prefix  = req.prefix,
        }
    })

end

__.delete__ = {
    "删除已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpdelete.html
    req = {
        { "offical_appid"           , "公众号AppID"                     },
        { "prefix"                  , "二维码规则"                      },
    },
}
__.delete = function(req)

    return wxa.http.post("cgi-bin/wxopen/qrcodejumpdelete", {
        appid = req.offical_appid,
        body  = _encode {
            prefix  = req.prefix,
        }
    })

end

return __
