
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

__.generate__ = {
    "获取小程序scheme码",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/url_scheme.html
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-scheme/urlscheme.generate.html
--  https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/url-scheme.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "path?"               , "小程序页面路径"                      },
        { "query?"              , "小程序页面参数"                      },
        { "is_expire?"          , "是否到期失效"        , "boolean"     },
        { "expire_time?"        , "失效时间戳"          , "number"      },
    },
    res = {
        { "openlink"            , "生成的小程序scheme码"                },
    }
}
__.generate = function(req)

    local jump_wxa  -- 跳转到的目标小程序信息
    if req.path or req.query then
        jump_wxa = {
            path    = req.path  or "",
            query   = req.query or "",
        }
    end

    return wxa.http.post("wxa/generatescheme", {
        appid       = req.appid,
        is_expire   = req.is_expire,
        expire_time = req.expire_time,
        jump_wxa    = jump_wxa,
    })

end

return __
