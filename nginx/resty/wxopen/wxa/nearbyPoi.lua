
local wxa               = require "resty.wxopen.wxa"
local _encode           = require "cjson.safe".encode
local _decode           = require "cjson.safe".decode

local __ = { _VERSION = "v21.02.22" }

-- 附近的小程序
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/nearby_poi.html

__.types = {
    service_info = {          "//服务标签",
        id                     = "number  //服务标签编号",
        type                   = "number  //服务类型",
        name                   = "string  //服务名称",
        appid                  = "string  //小程序AppID",
        path                   = "string  //小程序页面路径",
        desc                   = "string ?//服务描述: 10个字符以内"
    },
    kf_info = {               "//客服信息",
        open_kf                = "boolean //是否开启",
        kf_headimg             = "string  //客服头像",
        kf_name                = "string  //客服昵称",
    },
    poi_info = {               "//地点信息",
        poi_id                  = "string  //附近地点ID",
        qualification_address   = "string  //资质证件地址",
        qualification_num       = "string  //资质证件证件号",
        display_status          = "number  //地点展示在附近状态: 0 未展示, 1 展示中",
        audit_status            = "number  //地点审核状态: 3 审核中, 4 审核失败, 5 审核通过",
        refuse_reason           = "string  //审核失败原因: audit_status=4 时返回",
    }
}

__.add__ = {
    "添加地点",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/nearby-poi/nearbyPoi.add.html
    req = {
        appid               = "string    //小程序AppID",

        -- 如果创建新的门店，poi_id字段为空；如果更新门店，必填
        poi_id              = "string  ?//附近地点ID",
        map_poi_id          = "string   //腾讯地图地点ID",

        -- 需按照所选地理位置自动拉取腾讯地图门店名称，不可修改，
        -- 如需修改请重现选择地图地点或重新创建地点。
        store_name          = "string   //门店名字",

        address             = "string   //门店地址",
        hour                = "string   //营业时间: 格式00:00-23:59",
        contract_phone      = "string   //门店电话",

        company_name        = "string   //主体名字",
        credential          = "string   //资质号: 15位营业执照注册号或9位组织机构代码",

        -- 如果主体名字和该小程序主体不一致，需要填证明材料
        -- http://kf.qq.com/faq/170401MbUnim17040122m2qY.html
        qualification_list  = "string  ?//证明材料",

        -- 上传门店图片如门店外景、环境设施、商品服务等，图片将展示在微信客户端的门店页。
        -- https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1444738729
        pic_list            = "string[]  //门店图片: 最多9张，最少1张",

        service_infos       = "service_info[]  //服务标签列表",
        kf_info             = "kf_info        ?//客服信息: 可自定义服务头像与昵称",
    },
    res = {
        data = {
            audit_id            = "string   //审核单ID",
            poi_id              = "string   //附近地点ID",
            related_credential  = "string  ?//经营资质证件号",
        }
    }
}
__.add = function(req)

    --  id  |  type |  name
    --------|-------|-------------------------------------
    --   0  |   2   |  自定义服务，可自定义名称（10个字符以内）
    --   1  |   1   |  外送
    --   2  |   1   |  快递
    --   3  |   1   |  充电
    --   4  |   1   |  预约
    --   5  |   1   |  挂号
    --   6  |   1   |  点餐
    --   7  |   1   |  优惠
    --   8  |   1   |  乘车
    --   9  |   1   |  会员
    --  10  |   1   |  买单
    --  11  |   1   |  排队
    --  12  |   1   |  缴费
    --  13  |   1   |  购票
    --  14  |   1   |  到店自提
    --  15  |   1   |  预订

    return wxa.http.post("wxa/addnearbypoi", {
        appid               = req.appid,

        is_comm_nearby      = "1",  -- 必填,写死为"1"

        poi_id              = req.poi_id or "",
        map_poi_id          = req.map_poi_id,

        store_name          = req.store_name,
        address             = req.address,
        hour                = req.hour,
        contract_phone      = req.contract_phone,

        company_name        = req.company_name,
        credential          = req.credential,
        qualification_list  = req.qualification_list or "",

        -- 以下内容需转成 json 字符串:
        pic_list            = _encode { list = req.pic_list },
        service_infos       = _encode { service_infos = req.service_infos },
        kf_info             = req.kf_info and _encode(req.kf_info) or nil,
    })

end

__.delete__ = {
    "删除地点",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/nearby-poi/nearbyPoi.delete.html
    req = {
        appid               = "string    //小程序AppID",
        poi_id              = "string    //附近地点ID",
    },
}
__.delete = function(req)
    return wxa.http.post("wxa/delnearbypoi", req)
end

__.getList__ = {
    "查看地点列表",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/nearby-poi/nearbyPoi.getList.html
    req = {
        appid               = "string     //小程序AppID",
        page                = "number    ?//起始页码: 从1开始计数",
        page_rows           = "number    ?//每页个数: 最多1000个",
    },
    res = {
        left_apply_num      = "number     //剩余可添加地点个数",
        max_apply_num       = "number     //最大可添加地点个数",
        poi_list            = "poi_info[] //地址列表",
    }
}
__.getList = function(req)

    req.page        = req.page      or 1
    req.page_rows   = req.page_rows or 1000

    local  res, err = wxa.http.get("wxa/getnearbypoilist", req)
    if not res then return nil, err end

    local data = res.data or {}
    local left_apply_num = data.left_apply_num or 0
    local max_apply_num  = data.max_apply_num  or 0

    local obj = _decode(data.data) or {}
    local poi_list = obj.poi_list  or {}

    return {
        left_apply_num  = left_apply_num,
        max_apply_num   = max_apply_num,
        poi_list        = poi_list,
    }

end

__.setShowStatus__ = {
    "展示/取消展示附近小程序",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/nearby-poi/nearbyPoi.setShowStatus.html
    req = {
        appid               = "string    //小程序AppID",
        poi_id              = "string    //附近地点ID",
        status              = "number    //是否展示: 0 不展示, 1 展示",
    },
}
__.setShowStatus = function(req)
    return wxa.http.post("wxa/setnearbypoishowstatus", req)
end

return __
