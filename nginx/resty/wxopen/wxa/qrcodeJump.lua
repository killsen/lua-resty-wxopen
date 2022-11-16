
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.25" }

-- 普通链接二维码与小程序码
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcode.html
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpget.html

-- 扫普通链接二维码打开小程序
-- https://developers.weixin.qq.com/miniprogram/introduction/qrcode.html

__.get__ = {
   "获取已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpget.html
    req = {
        { "appid"                   , "授权方AppID"                     },
    },
    types = {
        rule = {
            { "prefix"              , "二维码规则"                      },
            { "permit_sub_rule"     , "是否独占"        , "number"      },  -- 1 为不占用，2 为占用
            { "path"                , "小程序功能页面"                  },
            { "open_version"        , "测试范围"        , "number"      },  -- 1 开发版, 2 体验版, 3 正式版
            { "debug_url?"          , "测试链接"        , "string[]"    },  -- 至多 5 个用于测试的二维码完整链接
            { "state"               , "发布标志位"      , "number"      },  -- 1 表示未发布，2 表示已发布"
        },
    },
    res = {
        { "qrcodejump_open"         , "是否已经打开二维码跳转链接设置"   , "number"      },
        { "qrcodejump_pub_quota"    , "本月还可发布的次数"              , "number"      },
        { "list_size"               , "二维码规则数量"                  , "number"      },
        { "rule_list"               , "二维码规则详情列表"              , "rule[]"      },
    },
}
__.get = function(req)
    return wxa.http.post("cgi-bin/wxopen/qrcodejumpget", req)
end

__.download__ = {
    "获取校验文件名称及内容",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpdownload.html
    req = {
        { "appid"               , "授权方AppID"                         },
    },
    res = {
        { "file_name"           , "文件名称"                            },
        { "file_content"        , "文件内容"                            },
    },
 }
 __.download = function(req)
    return wxa.http.post("cgi-bin/wxopen/qrcodejumpdownload", req)
end

__.add__ = {
    "增加或修改二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpadd.html
    req = {
        { "appid"               , "授权方AppID"                     },
        { "prefix"              , "二维码规则"                      },
        { "permit_sub_rule?"    , "是否独占"        , "number"      },  -- 1 为不占用，2 为占用
        { "path"                , "小程序功能页面"                  },
        { "open_version"        , "测试范围"        , "number"      },  -- 1 开发版, 2 体验版, 3 正式版
        { "debug_url?"          , "测试链接"        , "string[]"    },  -- 至多 5 个用于测试的二维码完整链接
        { "is_edit?"            , "编辑标志位"      , "number"      },  -- 0 表示新增二维码规则，1 表示修改已有二维码规则
    },
}
__.add = function(req)

    req.is_edit = req.is_edit or 0
    req.permit_sub_rule = req.permit_sub_rule or 1

    return wxa.http.post("cgi-bin/wxopen/qrcodejumpadd", req)

end

__.publish__ = {
    "发布已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumppublish.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "prefix"              , "二维码规则"                          },
    },
}
__.publish = function(req)
    return wxa.http.post("cgi-bin/wxopen/qrcodejumppublish", req)
end

__.delete__ = {
    "删除已设置的二维码规则",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/qrcodejumpdelete.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "prefix"              , "二维码规则"                          },
    },
}
__.delete = function(req)
    return wxa.http.post("cgi-bin/wxopen/qrcodejumpdelete", req)
end

return __
