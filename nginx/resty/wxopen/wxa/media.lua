
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.25" }

-- 1、临时素材media_id是可复用的。
-- 2、媒体文件在微信后台保存时间为3天，即3天后media_id失效。
-- 3、上传临时素材的格式、大小限制与公众平台官网一致。

local FILE_NAME = {
    image   = "file.jpg",   -- 图片   : 10M，支持PNG\JPEG\JPG\GIF格式
    voice   = "file.mp3",   -- 语音   ：2M，播放长度不超过60s，支持AMR\MP3格式
    video   = "file.mp4",   -- 视频   ：10MB，支持MP4格式
    thumb   = "file.jpg",   -- 缩略图 ：64KB，支持JPG格式
}

__.upload_media__ = {
    "新增临时素材",
--  https://developers.weixin.qq.com/doc/offiaccount/Asset_Management/New_temporary_materials.html
    req = {
        appid           = "string   //小程序AppID",
        file_type       = "string ? //媒体文件类型: image 图片, voice 语音, video 视频, thumb 缩略图",
        file_name       = "string ? //文件名",
        file_data       = "string   //文件内容",
    },
    res = {
        type            = "string   //媒体文件类型",
        media_id        = "string   //媒体文件ID",
        created_at      = "string   //上传时间戳",
    },
}
__.upload_media = function(req)

    local file_type = req.file_type or "image"
    local file_name = req.file_name or FILE_NAME[file_type]

    local res, err, code = wxa.http_form("cgi-bin/media/upload", {
        appid       = req.appid,
        type        = file_type,

        media       = {
            data            = req.file_data,
            content_type    = "application/octet-stream",
            attr            = {
                filename    = file_name,
                filelength  = #req.file_data,
            },
        }
    })

    if not res then return nil, err, code end

    return {
        type        = res.type,
        media_id    = res.media_id or res.thumb_media_id,
        created_at = res.created_at,
    }

end

__.get_media__ = {
    "获取临时素材",
--  https://developers.weixin.qq.com/doc/offiaccount/Asset_Management/Get_temporary_materials.html
    req = {
        appid           = "string    //小程序AppID",
        media_id        = "string    //媒体文件ID",
        base64          = "boolean ? //文件内容转base64",
    },
    res = {
        video_url       = "string  ? //视频素材链接",  -- 如果是视频消息素材, 则返回JSON对象, 其它则返回文件内容
        file_data       = "string  ? //媒体文件内容",
    },
}
__.get_media = function(req)

    local  res, err, code = wxa.http.get("cgi-bin/media/get", {
        appid       = req.appid,
        media_id    = req.media_id,
    })
    if not res then return nil, err, code end

    if type(res) == "string" then
        res = { file_data = res }
    end

    -- 文件内容转base64
    if req.base64 and res.file_data then
        res.file_data = ngx.encode_base64(res.file_data)
    end

    return res

end

__.get_material__ = {
    "获取永久素材",
--  https://developers.weixin.qq.com/doc/offiaccount/Asset_Management/Getting_Permanent_Assets.html
    req = {
        appid           = "string    //小程序AppID",
        media_id        = "string    //媒体文件ID",
        base64          = "boolean ? //文件内容转base64",
    },
    res = {
        video_url       = "string  ? //视频素材链接",  -- 如果是视频消息素材, 则返回JSON对象, 其它则返回文件内容
        file_data       = "string  ? //媒体文件内容",
    },
}
__.get_material = function(req)

    local  res, err, code = wxa.http.post("cgi-bin/material/get_material", {
        appid       = req.appid,
        media_id    = req.media_id,
    })
    if not res then return nil, err, code end

    if type(res) == "string" then
        res = { file_data = res }
    end

    -- 视频消息素材
    res.video_url = res.video_url or res.down_url

    -- 文件内容转base64
    if req.base64 and res.file_data then
        res.file_data = ngx.encode_base64(res.file_data)
    end

    return res

end

return __
