
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

__.long2short__ = {
    "将二维码长链接转成短链接",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/qrcode/shorturl.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "long_url"            , "长链接"                              },
    },
    res = {
        { "short_url"           , "短链接"                              },
    }
}
__.long2short = function(req)

    return wxa.http.post("cgi-bin/shorturl", {
        appid       = req.appid,
        long_url    = req.long_url,
        action      = "long2short",
    })

end

return __
