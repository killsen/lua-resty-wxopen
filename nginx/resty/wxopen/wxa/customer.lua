
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

__.set_typing__ = {
    "对用户下发正在输入状态",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.setTyping.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
    },
}
__.set_typing = function(req)

    return wxa.http.post("cgi-bin/message/custom/typing", {
        appid       = req.appid,
        touser      = req.touser,
        command     = "Typing",
    })

end

__.cancel_typing__ = {
    "取消对用户的正在输入状态",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.setTyping.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
    },
}
__.cancel_typing = function(req)

    return wxa.http.post("cgi-bin/message/custom/typing", {
        appid       = req.appid,
        touser      = req.touser,
        command     = "CancelTyping",
    })

end

__.send_text__ = {
    "发送文本消息给用户",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.send.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
        { "content"             , "文本消息"                            },
    },
}
__.send_text = function(req)

    return wxa.http.post("cgi-bin/message/custom/send", {
        appid       = req.appid,
        touser      = req.touser,
        msgtype     = "text",
        text        = {
            content = req.content,
        },
    })

end

__.send_image__ = {
    "发送图片消息给用户",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.send.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
        { "image"               , "图片消息"                            },
    },
}
__.send_image = function(req)

    local res, err, code = wxa.media.upload_media {
        appid = req.appid,
        file_data = req.image,
    }
    if not res then return nil, err, code end

    local media_id = res.media_id

    return wxa.http.post("cgi-bin/message/custom/send", {
        appid       = req.appid,
        touser      = req.touser,
        msgtype     = "image",
        image       = {
            media_id = media_id,
        },
    })

end

__.send_link__ = {
    "发送图文链接给用户",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.send.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
        { "title"               , "消息标题"                            },
        { "description"         , "链接消息"                            },
        { "url"                 , "跳转链接"                            },
        { "thumb_url"           , "图片链接"                            },
    },
}
__.send_link = function(req)

    return wxa.http.post("cgi-bin/message/custom/send", {
        appid       = req.appid,
        touser      = req.touser,
        msgtype     = "link",
        link        = {
            title       = req.title,
            description = req.description,
            url         = req.url,
            thumb_url   = req.thumb_url,
        },
    })

end

__.send_page__ = {
    "发送小程序卡片给用户",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/customer-message/customerServiceMessage.send.html
    req = {
        { "appid"               , "授权方AppID"                         },
        { "touser"              , "用户的OpenID"                        },
        { "title"               , "消息标题"                            },
        { "page"                , "页面路径"                            },
        { "image"               , "封面图片"                            },
    },
}
__.send_page = function(req)

    local res, err, code = wxa.media.upload_media {
        appid = req.appid,
        file_data = req.image,
    }
    if not res then return nil, err, code end

    local thumb_media_id = res.media_id

    return wxa.http.post("cgi-bin/message/custom/send", {
        appid       = req.appid,
        touser      = req.touser,
        msgtype     = "miniprogrampage",
        miniprogrampage = {
            title           = req.title,
            pagepath        = req.page,
            thumb_media_id  = thumb_media_id,
        },
    })

end

return __
