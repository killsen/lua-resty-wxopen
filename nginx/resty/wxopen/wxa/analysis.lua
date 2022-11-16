
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

-- 数据分析接口
-- https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Business/data_analysis.html

__.getDailyRetain__ = {
    "获取用户访问小程序日留存",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getDailyRetain.html
    req = {
        appid               = "string  //小程序AppID",
        begin_date          = "string  //开始日期: 格式为 yyyymmdd",
        end_date            = "string  //结束日期: 格式为 yyyymmdd，限定查询1天数据，允许设置的最大值为昨日。",
    },
    types = {
        duv = {
            key             = "number  //标识，0开始，表示当天，1表示1天后。依此类推，key取值分别是：0,1,2,3,4,5,6,7,14,30",
            value           = "number  //key对应日期的新增用户数/活跃用户数（key=0时）或留存用户数（k>0时）",
        }
    },
    res = {
        ref_date            = "string  //日期",
        visit_uv_new        = "duv[]   //新增用户留存",
        visit_uv            = "duv[]   //活跃用户留存",
    }
}
__.getDailyRetain = function(req)
    return wxa.http.post("datacube/getweanalysisappiddailyretaininfo", req)
end

__.getMonthlyRetain__ = {
    "获取用户访问小程序日留存",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getMonthlyRetain.html
    req = {
        appid               = "string  //小程序AppID",
        begin_date          = "string  //开始日期: 格式为 yyyymmdd，为自然月第一天",
        end_date            = "string  //结束日期: 格式为 yyyymmdd，为自然月最后一天，限定查询一个月数据。",
    },
    types = {
        muv = {
            key             = "number  //标识，0开始，表示当月，1表示1月后。key取值分别是：0,1",
            value           = "number  //key对应日期的新增用户数/活跃用户数（key=0时）或留存用户数（k>0时）",
        }
    },
    res = {
        ref_date            = "string  //日期",
        visit_uv_new        = "muv[]   //新增用户留存",
        visit_uv            = "muv[]   //活跃用户留存",
    }
}
__.getMonthlyRetain = function(req)
    return wxa.http.post("datacube/getweanalysisappidmonthlyretaininfo", req)
end

__.getWeeklyRetain__ = {
    "获取用户访问小程序日留存",
--  https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/data-analysis/visit-retain/analysis.getWeeklyRetain.html
    req = {
        appid               = "string  //小程序AppID",
        begin_date          = "string  //开始日期: 格式为 yyyymmdd，为周一日期",
        end_date            = "string  //结束日期: 格式为 yyyymmdd，为周日日期，限定查询一周数据。",
    },
    types = {
        wuv = {
            key             = "number  //标识，0开始，表示当周，1表示1周后。依此类推，取值分别是：0,1,2,3,4",
            value           = "number  //key对应日期的新增用户数/活跃用户数（key=0时）或留存用户数（k>0时）",
        }
    },
    res = {
        ref_date            = "string  //时间，如：20170306-20170312",
        visit_uv_new        = "wuv[]   //新增用户留存",
        visit_uv            = "wuv[]   //活跃用户留存",
    }
}
__.getWeeklyRetain = function(req)
    return wxa.http.post("datacube/getweanalysisappidweeklyretaininfo", req)
end


return __
