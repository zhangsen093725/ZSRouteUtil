//
//  ZSURLRoute.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by 张森 on 2019/11/20.
//

import UIKit

@objcMembers open class ZSURLRoute: NSObject {
    
    /// 去除路由中不必要的空格
    class func zs_removeWhitespacesAndNewlinesLink(replace link: String?) -> String? {
        
        guard link != nil else { return nil }
        
        var _link_ = link!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        
        return _link_
    }
}


