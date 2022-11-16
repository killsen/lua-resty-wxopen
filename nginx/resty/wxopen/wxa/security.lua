
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.25" }

-- 内容安全接口
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/security.html

__.imgSecCheck__ = {
    "图片内容安全识别",
--  调用本 API 可以校验一张图片是否含有违法违规内容。 频率限制：单个 appId 调用上限为 2000 次/分钟，200,000 次/天（图片大小限制：1M）
--  格式支持PNG、JPEG、JPG、GIF，图片尺寸不超过 750px x 1334px
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.imgSecCheck.html
    req = {
        appid       = "string   //小程序AppID",
        file_name   = "string ? //文件名",
        file_data   = "string   //文件内容",
    },
}
__.imgSecCheck = function(req)

    return wxa.http_form("wxa/img_sec_check", {
        appid       = req.appid,

        media       = {
            data            = req.file_data,
            content_type    = "application/octet-stream",
            attr            = {
                filename    = req.file_name or "file.jpg",
                filelength  = #req.file_data,
            },
        }
    })

end

__.msgSecCheck__ = {
    "文本内容安全识别",
--  调用本 API 可以检查一段文本是否含有违法违规内容。 频率限制：单个 appId 调用上限为 4000 次/分钟，2,000,000 次/天
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
    req = {
        appid       = "string   //小程序AppID",
        content     = "string   //要检测的文本内容",  -- 长度不超过 500KB
    },
}
__.msgSecCheck = function(req)
    return wxa.http.post("wxa/msg_sec_check", req)
end

__.mediaCheckAsync__ = {
    "异步内容安全识别",
--  调用本 API 可以异步校验图片/音频是否含有违法违规内容。
--  频率限制：单个 appId 调用上限为 2000 次/分钟，200,000 次/天；文件大小限制：单个文件大小不超过10M 异步检测结果在 30 分钟内会推送到你的消息接收服务器
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.mediaCheckAsync.html
    req = {
        appid       = "string   //小程序AppID",
        media_url   = "string   //要检测的多媒体url",
        media_type  = "number   //多媒体类型",  -- 1:音频;2:图片
    },
    res = {
        trace_id	= "string //任务id: 用于匹配异步推送结果"
    }
}
__.mediaCheckAsync = function(req)
    return wxa.http.post("wxa/media_check_async", req)
end

return __
