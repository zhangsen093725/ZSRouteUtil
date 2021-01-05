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
    
    /// 参数替换的映射
    class func zs_replace(params: [String : String]) -> [String : String] {
        
        var _params_ = params
        
        // 需要替换的参数
        zs_replaceQuery.forEach { (key, val) in
            
            if _params_[key] != nil
            {
                _params_[key] = val
            }
        }
        return _params_
    }
}


