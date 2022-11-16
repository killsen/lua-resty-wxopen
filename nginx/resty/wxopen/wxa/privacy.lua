
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v22.01.13" }

__.types = {

    PrivacyInfo = {
        code_exist	    = "number           //代码是否存在: 0 不存在, 1 存在",
        privacy_list    = "string[]         //代码检测出来的用户信息类型（privacy_key）",
        setting_list    = "PrivacySetting[] //要收集的用户信息配置",
        update_time     = "number           //更新时间",
        owner_setting   = "OwnerSetting     //收集方（开发者）信息配置",
        privacy_desc_list = "PrivacySetting[] //用户信息类型对应的中英文描述",
    },

    PrivacySetting      = {
        privacy_key     = "string   //用户信息类型的英文名称",
        privacy_text    = "string   //该用户信息类型的用途",
    --  privacy_label   = "string?  //用户信息类型的中文名称",
        privacy_desc    = "string?  //用户信息类型的中文名称",
        privacy_demo    = "string?  //用途示例",
    },

    OwnerSetting = {
        contact_email           = "string?  //信息收集方（开发者）的邮箱",
        contact_phone           = "string?  //信息收集方（开发者）的手机号",
        contact_qq              = "string?  //信息收集方（开发者）的qq",
        contact_weixin          = "string?  //信息收集方（开发者）的微信号",
        notice_method           = "string?  //通知方式: 指的是当开发者收集信息有变动时，通过该方式通知用户",
        store_expire_timestamp  = "string?  //存储期限:指的是开发者收集用户信息存储多久",
        ext_file_media_id       = "string?  //自定义用户隐私保护指引文件的media_id",
    }
}

-- 用途示例
local PrivacyDemo = {
    UserInfo	            = "分辨用户"	                            -- 用户信息（微信昵称、头像）
,	Location	            = "显示距离"	                            -- 位置信息
,	Address	                = "位置信息"	                            -- 地址
,	Invoice	                = "维护消费功能"	                        -- 发票信息
,	RunData	                = "用户互动"	                            -- 微信运动数据
,	Record	                = "通过语音与其他用户交流互动"              -- 麦克风
,	Album	                = "提前上传减少上传时间"	                -- 选中的照片或视频信息
,	Camera	                = "上传图片或者视频"	                    -- 摄像头
,	PhoneNumber	            = "登录或者注册"	                        -- 手机号
,	Contact	                = "方便用户联系信息"	                    -- 通讯录（仅写入）权限
,	DeviceInfo	            = "保障你正常使用网络服务"	                -- 设备信息
,	EXIDNumber	            = "实名认证后才能继续使用的相关网络服务"	 -- 身份证号码
,	EXOrderInfo	            = "方便获取订单信息"	                    -- 订单信息
,	EXUserPublishContent    = "用户互动"	                            -- 发布内容
,	EXUserFollowAcct	    = "用户互动"	                            -- 所关注账号
,	EXUserOpLog	            = "运营维护"	                            -- 操作日志
,	AlbumWriteOnly	        = "保存图片或者上传图片"	                -- 相册（仅写入）权限
,	LicensePlate	        = "用户互动"	                            -- 车牌号
,	BlueTooth	            = "设备连接"	                            -- 蓝牙
,	CalendarWriteOnly	    = "用户日历日程提醒"	                    -- 日历（仅写入）权限
,	Email	                = "在必要时和用户联系"	                    -- 邮箱
,	MessageFile	            = "提前上传减少上传时间"	                -- 选中的文件
}

__.get_privacy_setting__ = {
    "查询小程序用户隐私保护指引",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/privacy_config/get_privacy_setting.html
    req = {
        appid           = "string           //小程序AppID",
        privacy_ver     = "number?          //1表示现网版本, 2表示开发版",
    },
    res = "PrivacyInfo"
}
__.get_privacy_setting = function(req)

    local res, err, code = wxa.http.post("cgi-bin/component/getprivacysetting", {
        appid           = req.appid,
        privacy_ver     = tonumber(req.privacy_ver) or 2,
    })
    if not res then return nil, err, code end

    local map = {}
    local list = res.privacy_desc.privacy_desc_list

    res.privacy_desc = nil
    res.privacy_desc_list = list

    for _, d in ipairs(list) do
        d.privacy_demo  = PrivacyDemo[d.privacy_key] or "请填写用途"
        d.privacy_text  = d.privacy_demo
        map[d.privacy_key] = d.privacy_desc
    end

    for _, d in ipairs(res.setting_list) do
        d.privacy_demo  = PrivacyDemo[d.privacy_key] or "请填写用途"
        d.privacy_desc  = map[d.privacy_key] or ""
        d.privacy_label = nil
    end

    return res

end

__.set_privacy_setting__ = {
    "设置小程序用户隐私保护指引",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/privacy_config/set_privacy_setting.html
    req = {
        appid           = "string           //小程序AppID",
        privacy_ver     = "number?          //1表示现网版本, 2表示开发版",
        owner_setting   = "OwnerSetting     //收集方（开发者）信息配置",
        setting_list    = "PrivacySetting[] //要收集的用户信息配置",
    },
    res = "PrivacyInfo"
}
__.set_privacy_setting = function(req)

    local privacy_ver = tonumber(req.privacy_ver) or 2
    local setting_list = privacy_ver == 2 and req.setting_list or nil

    local res, err, code = wxa.http.post("cgi-bin/component/setprivacysetting", {
        appid           = req.appid,
        privacy_ver     = privacy_ver,
        owner_setting   = req.owner_setting,
        setting_list    = setting_list,
    })
    if not res then return nil, err, code end

    return __.get_privacy_setting { appid = req.appid, privacy_ver = req.privacy_ver }

end

return __
