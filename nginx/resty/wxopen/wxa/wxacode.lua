
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

wxa.http.errcode.set {
    [45009] = "调用分钟频率受限(目前5000次/分钟，会调整)，如需大量小程序码，建议预生成。",
    [41030] = "所传page页面不存在，或者小程序没有发布",
    [45029] = "生成码个数总和到达最大个数限制",
}

__.types = {
    rgb_color = {
        { "r"               , "红色"                , "number"      },
        { "g"               , "绿色"                , "number"      },
        { "b"               , "蓝色"                , "number"      },
    },
}

__.getUnlimited__ = {
    "获取小程序码（永久有效，数量暂无限制）",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/getwxacodeunlimit.html
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.getUnlimited.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "scene"               , "场景参数"                            },  -- 最大32个可见字符，只支持数字，大小写英文以及部分特殊字符：!#$&'()*+,/:;=?@-._~
        { "page?"               , "小程序页面"                          },  -- 默认 主页
        { "width?"              , "二维码的宽度"        , "number"      },  -- 默认 430px, 最小 280px, 最大 1280px
        { "auto_color?"         , "自动配置线条颜色"    , "boolean"     },  -- 默认 false
        { "line_color?"         , "二维码颜色"          , "rgb_color"   },  -- auto_color 为 false 时生效，使用 rgb 设置颜色
        { "is_hyaline?"         , "是否需要透明底色"    , "boolean"     },  -- 默认 false
    },
}
__.getUnlimited = function(req)
    return wxa.http.post("wxa/getwxacodeunlimit", req)
end

__.get__ = {
    "获取小程序码（永久有效，有数量限制）",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/getwxacode.html
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.get.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "path"                , "小程序页面路径"                      },  -- 最大长度 128 字节，不能为空
        { "width?"              , "二维码的宽度"        , "number"      },  -- 默认 430px, 最小 280px, 最大 1280px
        { "auto_color?"         , "自动配置线条颜色"    , "boolean"     },  -- 默认 false
        { "line_color?"         , "二维码颜色"          , "rgb_color"   },  -- auto_color 为 false 时生效，使用 rgb 设置颜色
        { "is_hyaline?"         , "是否需要透明底色"    , "boolean"     },  -- 默认 false
    },
}
__.get = function(req)
    return wxa.http.post("wxa/getwxacode", req)
end

__.createQRCode__ = {
    "获取小程序二维码（永久有效，有数量限制）",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/createwxaqrcode.html
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/qr-code/wxacode.createQRCode.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "path"                , "小程序页面路径"                      },  -- 最大长度 128 字节，不能为空
        { "width?"              , "二维码的宽度"        , "number"      },  -- 默认 430px, 最小 280px, 最大 1280px
    },
}
__.createQRCode = function(req)
    return wxa.http.post("cgi-bin/wxaapp/createwxaqrcode", req)
end

return __
