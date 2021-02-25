//
//  ZSURLRouteOutput.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/10.
//

import Foundation

@objc public protocol ZSURLRouteOutput {

    /// 路由解析完成
    /// - Parameter result: 路由解析结果
    static func zs_didFinishRoute(result: ZSURLRouteResult) -> ZSURLRouteOutput
}


@objc extension ZSURLRoute {
    
    /// 是否开启日志信息
    @objc open class var zs_logEnable: Bool {
        
        return true
    }
    
    /// 根据路由规则，找到target
    /// - Parameter result: 路由解析结果
    /// - Returns: 返回路由映射后的target
    class open func zs_routeTarget(from result: ZSURLRouteResult) -> ZSURLRouteOutput.Type? {
        
        return nil
    }
    
    /// 路由失败的原因
    /// - Parameter link: 失败的路由地址
    /// - Parameter error: 错误信息
    open class func zs_route(_ route: String, didFail error: Error) {
        
        guard zs_logEnable else { return }
        
        print("------------ZSURLRoute route fail begin------------")
        print("Exception: Router '\(route)' ")
        print("error: \(error)")
        print("------------ZSURLRoute route fail end--------------")
    }
}
