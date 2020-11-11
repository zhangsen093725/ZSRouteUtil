//
//  ZSURLRouteForward.swift
//  ZSRouteUtil
//
//  Created by Josh on 2020/11/11.
//

import UIKit

@objcMembers open class ZSURLRouteForward: NSObject {

    /// 泛解析域名，*为通配符
    @objc public var zs_host: String = ""
    
    /// 泛解析path，*为通配符
    @objc public var zs_path: String = ""
    
    @objc public var zs_forwardTarget: ZSURLRoute.Type = ZSURLRoute.self
}
