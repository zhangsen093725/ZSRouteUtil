//
//  ZSURLRouteUtil.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by 张森 on 2019/11/18.
//

import UIKit

public enum ZSURLRouteError: Error {
    /// 路由解析失败
    case zs_routeResolveFail
    /// 路由参数获取失败
    case zs_routeForParamsFail
    /// 路由链接为nil
    case zs_routeLinkEmpty
    /// 路由链接非法
    case zs_routeLinkError
}

public protocol ZSURLRoute: NSObject {
    
    /// 自定义路由解析规则
    /// - Parameter url: 路由的URL
    func zs_routeForCustomRule(_ url: URL)
    
    /// 路由参数，返回需要忽略的参数key数组
    func zs_ignoreKeysWithRoute() -> [String]
    
    /// 路由解析完成
    /// - Parameter scheme: 路由的scheme
    /// - Parameter host: 路由的host
    /// - Parameter path: 路由的path
    /// - Parameter query: 路由忽略不解析的特殊query，为""时表示没有特殊query
    /// - Parameter params: 路由解析后的params，为nil时表示没有query
    func zs_didFinishRoute(scheme: String?,
                           host: String?,
                           path: String?,
                           query: String,
                           params: [String: String]?)
}

public extension ZSURLRoute {
    
    /// URL路由解析
    /// - Parameter link: 路由链接
    func zs_URLRoute(form link: String?) throws {
        
        guard var _link_ = link else { throw ZSURLRouteError.zs_routeLinkEmpty }
        
        _link_ = _link_.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        _link_ = _link_.replacingOccurrences(of: " ", with: "")
        
        guard let url = URL(string: _link_) else { throw ZSURLRouteError.zs_routeLinkError }
        
        zs_routeForCustomRule(url)
        
        var _normalLink_ = _link_
        
        var query: String = ""
        
        var params: [String : String]?
        
        if let index = _link_.firstIndex(of: "?") {
            
            // 除参数以外的link
            _normalLink_ = String(_link_[..<index])
            
            // 参数
            let normalQueryIndex = _link_.index(index, offsetBy: 1)
            let normalQuery = String(_link_[normalQueryIndex..<_link_.endIndex])
            
            var _params_ = zs_parmasFromRoute(query: normalQuery)
            
            // 过滤特殊参数
            var querys: [String] = []
            
            for ignoreKey in zs_ignoreKeysWithRoute() {
                
                let key = ignoreKey.addingPercentEncoding(withAllowedCharacters:
                    .urlQueryAllowed) ?? ignoreKey
                
                let val = _params_[ignoreKey]? .addingPercentEncoding(withAllowedCharacters:
                    .urlQueryAllowed)
                
                if val != nil {
                    querys.append("\(key)=\(val!)")
                }
                
                _params_[ignoreKey] = nil
            }
            
            params = _params_
            query = querys.map{ String($0) }.joined(separator: "&")
        }
        
        let normalLink = _normalLink_ .addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? _normalLink_
        
        guard let normalURL = URL(string: normalLink) else { throw ZSURLRouteError.zs_routeLinkError }
        
        zs_didFinishRoute(scheme: normalURL.scheme, host: normalURL.host, path: normalURL.path.removingPercentEncoding, query: query, params: params)
    }
    
    func zs_parmasFromRoute(query: String) -> [String: String] {
        
        let querys = query.components(separatedBy: "&")
        
        var params: [String: String] = [:]
        
        for element in querys {
            
            guard let elementIndx = element.firstIndex(of: "=") else { continue }
            
            let key = String(element[..<elementIndx])
            
            let valIndex = element.index(elementIndx, offsetBy: 1)
            let val = String(element[valIndex..<element.endIndex]) .removingPercentEncoding ?? ""
            
            params[key] = val
        }
        
        return params
    }
    
    static func zs_indexOfTabbar(currentController: AnyClass) -> Int {
        
        var index = NSNotFound
        
        guard currentController is UIViewController.Type else { return index }
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        guard let tabbarController = rootViewController as? UITabBarController else { return index }
        
        guard let viewControllers = tabbarController.viewControllers else { return index }
        
        for (idx, controller) in viewControllers.enumerated() {
            
            if let navigation = controller as? UINavigationController {
                
                guard let subController = navigation.viewControllers.first else { return index }
                
                if subController.isKind(of: currentController) {
                    index = idx
                    break
                }
            }
            
            if controller.isKind(of: currentController) {
                index = idx
                break
            }
            
        }
        return index
    }
    
    static var zs_currentNavigation: UINavigationController? {
        
        var currentController: UIViewController?
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let tabBarController = rootViewController as? UITabBarController {
            
            currentController = tabBarController.selectedViewController
        }
        
        while (currentController?.presentedViewController != nil) {
            currentController = currentController?.presentedViewController!
        }
        
        return currentController as? UINavigationController
    }
    
}
