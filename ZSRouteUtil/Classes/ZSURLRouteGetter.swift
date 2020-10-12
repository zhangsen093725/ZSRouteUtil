//
//  ZSURLRouteGetter.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/12.
//

import Foundation

@objc extension ZSURLRoute {
    
    /// 当前的 navigation controller
    @objc open class var zs_currentNavigation: UINavigationController? {
        
        return zs_presentedController as? UINavigationController
    }
    
    /// 当前的 presented controller
    @objc open class var zs_presentedController: UIViewController? {
        
        var currentController: UIViewController?
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let tabBarController = rootViewController as? UITabBarController
        {
            currentController = tabBarController.selectedViewController
        }
        
        while (currentController?.presentedViewController != nil)
        {
            currentController = currentController?.presentedViewController!
        }
        
        return currentController ?? rootViewController
    }
    
    /// 根据类获取当前 tabbar controller 的 subcontroller
    /// - Parameter targetClass: 类
    /// - Returns: 返回 subcontroller，未找到为 nil
    @discardableResult
    open class func zs_tabbarTargetController(_ targetClass: UIViewController.Type) -> UIViewController? {
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        let tabbarController = rootViewController as? UITabBarController
        
        for controller in (tabbarController?.viewControllers ?? [])
        {
            if let navigation = controller as? UINavigationController
            {
                let subController = navigation.viewControllers.first
                
                if subController?.isMember(of: targetClass) ?? false
                {
                    return subController
                }
            }
            
            if controller.isMember(of: targetClass)
            {
                return controller
            }
        }
        
        return nil
    }
    
    /// URL路由解析，返回可用的target controller
    /// - Parameter route: 路由
    @discardableResult
    open class func zs_routeResolution(_ route: String?) -> ZSURLRouteResult? {
        
        guard let _route_ = zs_removeWhitespacesAndNewlinesLink(replace: route) else
        {
            let error = NSError(domain: "route is empty", code: 400, userInfo: [NSLocalizedDescriptionKey : "路由地址为空"])
            zs_didRouteFail(route: route ?? "", error: error)
            return nil
        }
        
        var params: [String : String] = zs_parmasFromRoute(_route_)
        
        var removeQueryLink = _route_
        
        if let index = _route_.firstIndex(of: "?")
        {
            removeQueryLink = String(_route_[..<index])
        }
        
        params = zs_replace(params: params)
        
        // 需要忽略的参数query
        var ignoreQuery: String = ""
        // 过滤特殊参数
        var ignoreParams: [String : String] = [:]
        
        zs_ignoreQueryKey.forEach { (key) in
            
            ignoreParams[key] = params[key]
            params[key] = nil
        }
        
        ignoreQuery = ignoreParams.zs_queryURLEncodedString
        
        let normalRoute = removeQueryLink.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? removeQueryLink
        
        guard let normalURL = URL(string: normalRoute) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route ?? "", error: error)
            return nil
        }
        
        let result = ZSURLRouteResult()
        
        result.originRoute = _route_
        result.route = normalRoute + "?" + ignoreQuery
        result.ignoreQuery = ignoreQuery
        result.params = params
        
        let scheme = normalURL.scheme ?? ""
        result.originScheme = scheme
        result.scheme = zs_schemeMap[(zs_ignoreCase ? scheme.lowercased() : scheme)] ?? scheme
        
        let host = (normalURL.host) ?? ""
        result.host = host
        result.moudle = zs_hostMap[(zs_ignoreCase ? host.lowercased() : host)] ?? host
        
        let path = normalURL.path
        result.path = path
        result.submoudle = zs_pathMap[(zs_ignoreCase ? path.lowercased() : path)] ?? path
        
        return result
    }
    
    /// 获取路由的参数
    /// - Parameter link: URL
    open class func zs_parmasFromRoute(_ route: String) -> [String: String] {
        
        guard let _link_ = zs_removeWhitespacesAndNewlinesLink(replace: route) else { return [:] }
        
        guard let index = _link_.firstIndex(of: "?") else { return [:] }
        
        // 参数
        let queryIndex = _link_.index(index, offsetBy: 1)
        let query = String(_link_[queryIndex..<_link_.endIndex])
        
        let querys = query.components(separatedBy: "&")
        
        var params: [String: String] = [:]
        
        for element in querys
        {
            guard let elementIndx = element.firstIndex(of: "=") else { continue }
            
            let key = String(element[..<elementIndx])
            
            let valIndex = element.index(elementIndx, offsetBy: 1)
            let val = String(element[valIndex..<element.endIndex]) .removingPercentEncoding ?? ""
            
            params[key] = val
        }
        
        return params
    }
    
    /// 获取 target controller
    /// - Parameter route: 指定目标 route
    /// - Parameter isCheckTabbar: 是否验证是 tabbar controller
    @discardableResult
    open class func zs_targetController(from route: String,
                                        isCheckTabbar: Bool = true) -> UIViewController? {
        
        guard let result = zs_routeResolution(route) else
        {
            let error = NSError(domain: "Bad Gateway", code: 502, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let targetClass = zs_routeTarget(result: result) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let _targetClass_ = targetClass as? UIViewController.Type else
        {
            let error = NSError(domain: "target 不是 UIViewController 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_didFinishRoute 中返回 UIViewController 及其子类"])
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        var targetController: UIViewController?
        
        if isCheckTabbar
        {
            targetController = zs_tabbarTargetController(_targetClass_)
        }
        
        targetController = targetController == nil ? _targetClass_.init() : targetController
        
        (targetController as? ZSURLRouteOutput)?.zs_didFinishRoute(result: result)
        
        return targetController
    }
    
    /// 获取 target view
    /// - Parameter route: 指定目标 route
    @discardableResult
    open class func zs_targetView(from route: String) -> UIView? {
        
        guard let result = zs_routeResolution(route) else
        {
            let error = NSError(domain: "Bad Gateway", code: 502, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let targetClass = zs_routeTarget(result: result) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let _targetClass_ = targetClass as? UIView.Type else
        {
            let error = NSError(domain: "target 不是 UIView 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_didFinishRoute 中返回 UIView 及其子类"])
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        let targetView = _targetClass_.init()
        
        (targetView as? ZSURLRouteOutput)?.zs_didFinishRoute(result: result)
        
        return targetView
    }
}


fileprivate extension Dictionary {
    
    var zs_queryURLEncodedString: String {
        
        var querys: [String] = []
        
        for (key, value) in self
        {
            if let val = value as? String
            {
                querys.append("\(key)=\(val.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? val)")
                continue
            }
            
            querys.append("\(key)=\(value)")
        }
        return querys.map{ String($0) }.joined(separator: "&")
    }
}
