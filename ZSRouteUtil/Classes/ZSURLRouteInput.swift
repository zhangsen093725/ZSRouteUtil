//
//  ZSURLRouteInput.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/10.
//

import Foundation

@objc extension ZSURLRoute {
    
    /// scheme 的路由映射
    @objc open class var zs_schemeMap: Dictionary<String, String> {
        
        return [:]
    }
    
    /// host 的路由映射
    @objc open class var zs_hostMap: Dictionary<String, String> {
        
        return [:]
    }
    
    /// path 的路由映射
    @objc open class var zs_pathMap: Dictionary<String, String> {
        
        return [:]
    }
    
    /// 需要替换 query 的键值
    @objc open class var zs_replaceQuery: Dictionary<String, String> {
        
        return [:]
    }
    
    /// 需要忽略解析 query 的键
    @objc open class var zs_ignoreQueryKey: Array<String> {
        
        return []
    }
    
    /// 路由转发策略表
    @objc open class var zs_forwardList: Array<ZSURLRouteForward> {
        
        return []
    }
    
    /// 是否开启路由转发策略
    @objc open class var zs_forwardEnable: Bool {
        
        return false
    }
    
    /// 是否忽略 scheme、host、path 的大小写
    @objc open class var zs_ignoreCaseEnable: Bool {
        
        return false
    }
    
    /// 是否过滤路由中的空格
    @objc open class var zs_filterWhitespacesEnable: Bool {
        
        return true
    }
    
    /// 参数替换的映射
    @objc open class func zs_replace(params: [String : String]) -> [String : String] {
        
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
