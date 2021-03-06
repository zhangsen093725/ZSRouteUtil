//
//  ZSURLRouteResult.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/10.
//

import Foundation

@objcMembers open class ZSURLRouteResult: NSObject {
   
    /// 解析后的 scheme
    @objc public var scheme: String = ""
    
    /// 解析后的 host
    @objc public var host: String = ""
    
    /// 解析后的 path
    @objc public var path: String = ""
    
    /// 解析后的 params
    @objc public var params: Dictionary<String, String> = [:]
    
    /// 解析后被忽略的 query
    @objc public var ignoreQuery: String = ""
    
    /// 解析后的 route
    @objc public var route: String = ""
    
    /// 原始的 scheme
    @objc public var originScheme: String = ""
    
    /// 原始的 host
    @objc public var originHost: String = ""
    
    /// 原始的 path
    @objc public var originPath: String = ""
    
    /// 原始的 query
    @objc public var query: String = ""
    
    /// 原始的 originRoute
    @objc public var originRoute: String = ""
}
