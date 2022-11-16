
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

__.get_account_basic_info__ = {
    "获取基本信息",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/Mini_Program_Information_Settings.html
    req = {
        appid                           = "//小程序AppID",
    },
    res = {
        appid                           = "string  //帐号 appid",
        nickname                        = "string  //小程序名称",
        account_type                    = "number  //帐号类型: 1 订阅号, 2 服务号, 3 小程序",
        principal_type                  = "number  //主体类型: 0 个人, 1 企业, 2 媒体, 3 政府, 4 其他组织",
        principal_name                  = "string  //主体名称",
        credential                      = "string  //主体标识",
        realname_status                 = "number  //实名验证状态: 1 实名验证成功, 2 实名验证中, 3 实名验证失败",
        registered_country              = "number  //注册国家: 1017 中国",

        wx_verify_info = { "//微信认证信息",
            qualification_verify	    = "boolean //是否资质认证，若是，拥有微信认证相关的权限。",
            naming_verify	            = "boolean //是否名称认证",
            annual_review	            = "boolean //是否需要年审:（qualification_verify == true 时才有该字段）",
            annual_review_begin_time	= "number  //年审开始时间: 时间戳（qualification_verify == true 时才有该字段）",
            annual_review_end_time	    = "number  //年审截止时间: 时间戳（qualification_verify == true 时才有该字段）",
        },

        signature_info = { "//功能介绍信息",
            signature	                = "string  //功能介绍",
            modify_used_count           = "number  //功能介绍已使用修改次数（本月）",
            modify_quota                = "number  //功能介绍修改次数总额度（本月）",
        },

        head_image_info = { "//头像信息",
            head_image_url              = "string  //头像 url",
            modify_used_count           = "number  //头像已使用修改次数（本年）",
            modify_quota                = "number  //头像修改次数总额度（本年）",
        },

        nickname_info = { "//名称信息",
            nickname                    = "string  //小程序名称",
            modify_used_count           = "number  //小程序名称已使用修改次数（本年）",
            modify_quota                = "number  //小程序名称修改次数总额度（本年）",
        },
    }
}
__.get_account_basic_info = function(req)
    return wxa.http.get("cgi-bin/account/getaccountbasicinfo", req)
end

__.modify_domain__ = {
    "设置服务器域名",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/Server_Address_Configuration.html
    req = {
        appid           = "//小程序AppID",
        action          = "string    //操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        requestdomain   = "string[] ?//request 合法域名",       -- 当 action 是 get 时不需要以下字段
        wsrequestdomain = "string[] ?//socket 合法域名",
        uploaddomain    = "string[] ?//uploadFile 合法域名",
        downloaddomain  = "string[] ?//downloadFile 合法域名",
        udpdomain       = "string[] ?//upd 合法域名",
        tcpdomain       = "string[] ?//tcp 合法域名",
    },
    res = {
        requestdomain   = "string[]  //request 合法域名",
        wsrequestdomain = "string[]  //socket 合法域名",
        uploaddomain    = "string[]  //uploadFile 合法域名",
        downloaddomain  = "string[]  //downloadFile 合法域名",
        udpdomain       = "string[]  //upd 合法域名",
        tcpdomain       = "string[]  //tcp 合法域名",
    }
}
__.modify_domain = function(req)
    return wxa.http.post("wxa/modify_domain", req)
end

__.set_webview_domain__ = {
    "设置业务域名",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/setwebviewdomain.html
    req = {
        appid           = "//小程序AppID",
        -- 如果没有指定 action，则默认将第三方平台登记的小程序业务域名全部添加到该小程序
        action          = "string   ?//操作类型: add 添加, delete 删除, set 覆盖, get 获取",
        webviewdomain   = "string[] ?//小程序业务域名",  -- 当 action 是 get 时不需要此字段
    },
    res = {
        webviewdomain   = "string[] ?//小程序业务域名",
    }
}
__.set_webview_domain = function(req)
    return wxa.http.post("wxa/setwebviewdomain", req)
end

wxa.http.errcode.set {
    [91001] = [[不是公众号快速创建的小程序]],
    [91002] = [[小程序发布后不可改名]],
    [91003] = [[改名状态不合法，小程序发布前可改名的次数为2次，请确认改名次数是否已达上限]],
    [91004] = [[昵称不合法]],
    [91005] = [[昵称 15 天主体保护]],
    [91006] = [[昵称命中微信号]],
    [91007] = [[昵称已被占用]],
    [91008] = [[昵称命中 7 天侵权保护期]],
    [91009] = [[需要提交材料]],
    [91010] = [[其他错误]],
    [91011] = [[查不到昵称修改审核单信息]],
    [91012] = [[其他错误]],
    [91013] = [[占用名字过多]],
    [91014] = [[+号规则 同一类型关联名主体不一致]],
    [91015] = [[指的是已经有同名的公众号，但是那个公众号的主体和当前小程序主体不一致]],
    [91016] = [[名称占用者 ≥2]],
    [91017] = [[+号规则 不同类型关联名主体不一致]],
}

__.set_nickname__ = {
    "设置名称",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/setnickname.html
    req = {
        appid                   = "  //小程序AppID",
        nick_name	            = "  //昵称",                               -- 不支持包含“小程序”关键字的昵称
        id_card		            = "? //身份证照片 mediaid",                  -- 个人号必填
        license		            = "? //组织机构代码证或营业执照 mediaid",     -- 组织号必填
        naming_other_stuff_1	= "? //其他证明材料 mediaid",
        naming_other_stuff_2	= "? //其他证明材料 mediaid",
        naming_other_stuff_3	= "? //其他证明材料 mediaid",
        naming_other_stuff_4	= "? //其他证明材料 mediaid",
        naming_other_stuff_5	= "? //其他证明材料 mediaid",
    },
    res = {
        wording	                = "string  //材料说明",
        -- 若接口未返回 audit_id，说明名称已直接设置成功，无需审核
        audit_id	            = "number ?//审核单id",  -- 通过用于查询改名审核状态
    }
}
__.set_nickname = function(req)
    return wxa.http.post("wxa/setnickname", req)
end

__.query_nickname__ = {
    "查询改名审核状态",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/api_wxa_querynickname.html
    req = {
        appid                   = "  //小程序AppID",
        audit_id	            = "string ?//审核单id",  -- 由设置名称接口返回
    },
    res = {
        nickname	            = "string  //审核昵称",
        audit_stat	            = "number  //审核状态，1：审核中，2：审核失败，3：审核成功",
        fail_reason	            = "string  //失败原因",
        create_time	            = "number  //审核提交时间",
        audit_time	            = "number  //审核完成时间",
    }
}
__.query_nickname = function(req)
    return wxa.http.post("wxa/api_wxa_querynickname", req)
end

wxa.http.errcode.set {
    [53010] = [[名称格式不合法]],
    [53011] = [[名称检测命中频率限制]],
    [53012] = [[禁止使用该名称]],
    [53013] = [[公众号：名称与已有公众号名称重复;小程序：该名称与已有小程序名称重复]],
    [53014] = [[公众号：公众号已有{名称 A+}时，需与该帐号相同主体才可申请{名称 A};小程序：小程序已有{名称 A+}时，需与该帐号相同主体才可申请{名称 A}]],
    [53015] = [[公众号：该名称与已有小程序名称重复，需与该小程序帐号相同主体才可申请;小程序：该名称与已有公众号名称重复，需与该公众号帐号相同主体才可申请]],
    [53016] = [[公众号：该名称与已有多个小程序名称重复，暂不支持申请;小程序：该名称与已有多个公众号名称重复，暂不支持申请]],
    [53017] = [[公众号：小程序已有{名称 A+}时，需与该帐号相同主体才可申请{名称 A};小程序：公众号已有{名称 A+}时，需与该帐号相同主体才可申请{名称 A}]],
    [53018] = [[名称命中微信号]],
    [53019] = [[名称在保护期内]],
}

__.check_wxverify_nickname__ = {
    "微信认证名称检测",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/wxverify_checknickname.html
    req = {
        appid                   = "  //小程序AppID",
        nick_name	            = "  //昵称",  -- 不支持包含“小程序”关键字的昵称
    },
    res = {
        hit_condition           = "boolean //是否命中关键字策略",
        wording	                = "string  //材料说明",
    }
}
__.check_wxverify_nickname = function(req)
    return wxa.http.post("cgi-bin/wxverify/checkwxverifynickname", req)
end

-- 名称审核结果事件推送
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/wxa_nickname_audit.html
-- 小程序改名的审核结果会向消息与事件接收 URL 推送相关通知。
-- <xml>
-- 	<ToUserName><![CDATA[gh_fxxxxxxxa4b2]]></ToUserName>
-- 	<FromUserName><![CDATA[odxxxxM-xxxxxxxx-trm4a7apsU8]]></FromUserName>
-- 	<CreateTime>1488800000</CreateTime>
-- 	<MsgType><![CDATA[event]]></MsgType>
-- 	<Event><![CDATA[wxa_nickname_audit]]></Event>
-- 	<ret>2</ret>  -- 审核结果 2：失败，3：成功
-- 	<nickname>需要更改的昵称</nickname>
-- 	<reason>审核失败的驳回原因</reason>
-- </xml>

__.modify_head_image__ = {
    "修改头像",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/modifyheadimage.html
    req = {
        appid               = "//小程序AppID",
        head_img_media_id   = "//头像素材 media_id",
        x1                  = "?//裁剪框左上角 x 坐标（取值范围：[0, 1]）",
        y1                  = "?//裁剪框左上角 y 坐标（取值范围：[0, 1]）",
        x2                  = "?//裁剪框右下角 x 坐标（取值范围：[0, 1]）",
        y2                  = "?//裁剪框右下角 y 坐标（取值范围：[0, 1]）",
    },
}
__.modify_head_image = function(req)

    req.x1 = req.x1 or "0"
    req.y1 = req.y1 or "0"
    req.x2 = req.x2 or "1"
    req.y2 = req.y2 or "1"

    return wxa.http.post("cgi-bin/account/modifyheadimage", req)

end

__.modify_signature__ = {
    "修改功能介绍",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/modifysignature.html
    req = {
        appid               = "//小程序AppID",
        signature           = "//功能介绍",
    },
}
__.modify_signature = function(req)
    return wxa.http.post("cgi-bin/account/modifysignature", req)
end

__.get_search_status__ = {
    "查询隐私设置",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/getwxasearchstatus.html
    req = {
        appid               = "//小程序AppID",
    },
    res = {
        status	            = "number  //隐私设置",  -- 1 表示不可搜索，0 表示可搜索
    }
}
__.get_search_status = function(req)
    return wxa.http.get("wxa/getwxasearchstatus", req)
end

__.change_search_status__ = {
    "修改隐私设置",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_Basic_Info/changewxasearchstatus.html
    req = {
        appid               = "//小程序AppID",
        status	            = "number  //隐私设置",  -- 1 表示不可搜索，0 表示可搜索
    },
}
__.change_search_status = function(req)
    return wxa.http.post("wxa/changewxasearchstatus", req)
end

return __
