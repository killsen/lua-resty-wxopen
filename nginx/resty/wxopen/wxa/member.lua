
local wxa = require "resty.wxopen.wxa"

local __ = { _VERSION = "v21.02.22" }

-- 小程序成员管理
-- https://kf.qq.com/faq/170302zeQryI170302beuEVn.html
-- 项目成员：表示参与小程序开发、运营的成员，可登陆小程序管理后台，包括运营者、开发者及数据分析者。
--          管理员可在“成员管理”中添加、删除项目成员，并设置项目成员的角色。
-- 体验成员：表示参与小程序内测体验的成员，可使用体验版小程序，但不属于项目成员。
--          管理员及项目成员均可添加、删除体验成员。
-- 管理员及其他项目成员绑定帐号数不占用公众号绑定数量限制。
--          每个微信号可以成为50个小程序的项目成员。
--          每个微信号可以成为50个小程序的体验成员。

__.bind_tester__ = {
    "绑定微信用户为体验者",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_AdminManagement/Admin.html
    req  = {
        { "appid"       , "授权方AppID"             },
        { "wechatid"    , "微信号"                  },
    },
    res  = {
        { "userstr"     , "人员对应的唯一字符串"     },
    }
}
__.bind_tester = function(req)
    return wxa.http.post("wxa/bind_tester", req)
end

__.unbind_tester__ = {
    "解除绑定体验者",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_AdminManagement/unbind_tester.html
    req  = {
        { "appid"       , "授权方AppID"             },
        { "wechatid?"   , "微信号"                  },  -- userstr 和 wechatid
        { "userstr?"    , "人员对应的唯一字符串"     },  -- 填写其中一个即可
    },
}
__.unbind_tester = function(req)
    return wxa.http.post("wxa/unbind_tester", req)
end

__.get_experiencer__ = {
    "获取体验者列表",
--  https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/2.0/api/Mini_Program_AdminManagement/memberauth.html
    req  = {
        { "appid"       , "授权方AppID"             },
    },
    types = {
        member = {
            userstr     = "//人员对应的唯一字符串"
        }
    },
    res  = {
        members         = "member[] //人员信息"
    }
}
__.get_experiencer = function(req)
    return wxa.http.post("wxa/memberauth", {
        appid   = req.appid,
        action  = "get_experiencer",
    })
end

return __
