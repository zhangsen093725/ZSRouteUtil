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
    func zs_didFinishRoute(result: ZSURLRouteResult)
}


@objc extension ZSURLRoute {
    
    /// 是否开启日志信息
    @objc open class var zs_logEnable: Bool {
        
        return true
    }
    
    /// 路由失败的原因
    /// - Parameter link: 失败的路由地址
    /// - Parameter error: 错误信息
    open class func zs_didRouteFail(route: String, error: Error) {
        
        guard zs_logEnable else { return }
        
        print("------------ZSURLRoute route fail begin------------")
        print("Exception: Router Error")
        print("code: \(error)")
        print("router: \(route)")
        print("-------------ZSURLRoute route fail end-------------")
    }
}
