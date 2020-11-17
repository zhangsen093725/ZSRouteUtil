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
    @objc open class var zs_forward: Array<ZSURLRouteForward> {
        
        return []
    }
    
    /// 是否开启路由转发策略
    @objc open class var zs_forwardEnable: Bool {
        
        return false
    }
    
    /// 是否忽略 scheme、host、path 的大小写
    @objc open class var zs_ignoreCase: Bool {
        
        return false
    }
    
    /// 是否过滤路由中的空格
    @objc open class var zs_filterWhitespaces: Bool {
        
        return true
    }
    
    /// 根据路由规则，找到target
    /// - Parameter result: 路由解析结果
    /// - Returns: 返回路由映射后的target
    class open func zs_routeTarget(result: ZSURLRouteResult) -> ZSURLRouteOutput.Type? {
        
        return nil
    }
}
