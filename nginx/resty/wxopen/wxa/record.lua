
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v22.01.19" }

__.types = {
    IllegalRecord = { "//违规处罚记录",
        illegal_record_id   = "string   //违规处罚记录id",
        create_time         = "number   //违规处罚时间",
        illegal_reason      = "string   //违规原因",
        illegal_content     = "string   //违规内容",
        rule_url            = "string   //规则链接",
        rule_name           = "string   //违反的规则名称",
    },
    AppealRecord = { "//申诉记录",
        appeal_record_id    = "number   //申诉单id",
        appeal_time         = "number   //申诉时间",
        appeal_count        = "number   //申诉次数",
        appeal_from         = "number   //申诉来源（0--用户，1--服务商）",
        appeal_status       = "number   //申诉状态",
        audit_time          = "number   //审核时间",
        audit_reason        = "string   //审核结果理由",
        punish_description  = "string   //处罚原因描述",
        materials           = "Material[] //违规材料和申诉材料",
    },
    Material = { "//违规材料和申诉材料",
        illegal_material        = { "//违规材料",
            content             = "违规内容",
            content_url         = "违规链接",
        },
        appeal_material         = { "//申诉材料",
            reason              = "string   //申诉理由",
            proof_material_ids  = "string[] //证明材料列表"  -- 可以通过“获取临时素材”接口下载对应的材料
        }
    },
}

__.get_illegal_records__ = {
    "获取小程序违规处罚记录",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/records/getillegalrecords.html
    req = {
        { "appid"           , "小程序AppID"                     },
        { "start_time?"     , "开始时间"        , "number"      },
        { "end_time?"       , "结束时间"        , "number"      },
    },
    res = {
        { "records" , "违规处罚记录列表" , "IllegalRecord[]" },
    },
}
__.get_illegal_records = function(req)

    return wxa.http.post("wxa/getillegalrecords", {
        appid       = req.appid,
        start_time  = req.start_time,
        end_time    = req.end_time,
    })

end

__.get_appeal_records__ = {
    "获取小程序申诉记录",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/records/getappealrecords.html
    req = {
        { "appid"              , "小程序AppID"      },
        { "illegal_record_id"  , "违规处罚记录id"   },
    },
    res = {
        { "records" , "申诉记录列表" , "AppealRecord[]" },
    },
}
__.get_appeal_records = function(req)

    return wxa.http.post("wxa/getappealrecords", {
        appid               = req.appid,
        illegal_record_id   = req.illegal_record_id,
    })

end

return __
