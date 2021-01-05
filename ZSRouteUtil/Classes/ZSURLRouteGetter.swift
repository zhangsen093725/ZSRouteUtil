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
        
        guard let _route_ = zs_filterWhitespaces ? zs_removeWhitespacesAndNewlinesLink(replace: route) : route else {
         
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
        
        result.originScheme = normalURL.scheme ?? ""
        let scheme = (zs_ignoreCase ? result.originScheme.lowercased() : result.originScheme)
        result.scheme = zs_schemeMap[scheme] ?? result.originScheme

        zs_schemeMap.forEach { (key, value) in
            
            let schemeRule = key.replacingOccurrences(of: "*", with: ".*")
            let predcate = NSPredicate(format: "SELF MATCHES%@", schemeRule)
            
            if predcate.evaluate(with: scheme)
            {
                result.scheme = value
            }
        }
        
        result.host = (normalURL.host) ?? ""
        let host = (zs_ignoreCase ? result.host.lowercased() : result.host)
        result.moudle = zs_hostMap[host] ?? result.host
        
        zs_hostMap.forEach { (key, value) in
            
            var hostRule = key.replacingOccurrences(of: ".", with: "[.]")
            hostRule = hostRule.replacingOccurrences(of: "*", with: ".*")
            
            let predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", hostRule)
            
            if predcate.evaluate(with: host)
            {
                result.moudle = value
            }
        }
        
        result.path = normalURL.path
        let path = zs_ignoreCase ? result.path.lowercased() : result.path
        result.submoudle = zs_pathMap[result.path] ?? result.path
        
        zs_pathMap.forEach { (key, value) in
            
            let pathRule = key.replacingOccurrences(of: "*", with: ".*")
            let predcate = NSPredicate(format: "SELF MATCHES%@", pathRule)
            
            if predcate.evaluate(with: path)
            {
                result.submoudle = value
            }
        }
        
        return result
    }
    
    /// 获取路由的参数
    /// - Parameter link: URL
    open class func zs_parmasFromRoute(_ route: String) -> [String: String] {
        
        guard let _route_ = zs_filterWhitespaces ? zs_removeWhitespacesAndNewlinesLink(replace: route) : route else { return [:] }
        
        guard let index = _route_.firstIndex(of: "?") else { return [:] }
        
        // 参数
        let queryIndex = _route_.index(index, offsetBy: 1)
        let query = String(_route_[queryIndex..<_route_.endIndex])
        
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
    
    /// 获取 forward target
    /// - Parameter result: 路由解析结果
    /// - Returns: target
    @discardableResult
    open class func zs_forwardTarget(from result: ZSURLRouteResult) -> ZSURLRoute.Type? {
        
        guard zs_forwardEnable else { return nil }
        
        var _forward: ZSURLRouteForward?
        
        zs_forward.forEach { (forward) in
            
            // 正则转换www[.].*[.]com
            var hostRule = (zs_ignoreCase ? forward.zs_host.lowercased() : forward.zs_host).replacingOccurrences(of: ".", with: "[.]")
            hostRule = hostRule.replacingOccurrences(of: "*", with: ".*")

            var predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", hostRule)
            var isForward = predcate.evaluate(with: (zs_ignoreCase ? result.moudle.lowercased() : result.moudle))
            
            if forward.zs_path.count > 0 && isForward
            {
                // 正则转换
                let pathRule = (zs_ignoreCase ? forward.zs_path.lowercased() : forward.zs_path).replacingOccurrences(of: "*", with: ".*")
                
                predcate = NSPredicate(format: "SELF MATCHES%@", pathRule)
                isForward = predcate.evaluate(with: (zs_ignoreCase ? result.submoudle.lowercased() : result.submoudle))
            }
            
            if isForward
            {
                _forward = forward
                return
            }
        }
        
        return _forward?.zs_forwardTarget
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

        if let forwardTarget = zs_forwardTarget(from: result)
        {
            return forwardTarget.zs_targetController(from: route, isCheckTabbar: isCheckTabbar)
        }
        
        guard let targetClass = zs_routeTarget(result: result) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let _targetClass_ = targetClass as? UIViewController.Type else
        {
            let error = NSError(domain: "target 不是 UIViewController.class 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_routeTarget 中返回 UIViewController.class 及其子类"])
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        var targetController: UIViewController?
        
        if isCheckTabbar
        {
            targetController = zs_tabbarTargetController(_targetClass_)
        }
        
        if targetController == nil
        {
            guard let routeOutput = (_targetClass_ as? ZSURLRouteOutput.Type) else
            {
                let error = NSError(domain: "target 没有遵循 ZSURLRouteOutput 协议", code: 501, userInfo:nil)
                
                zs_didRouteFail(route: route, error: error)
                
                return nil
            }
            
            let _targetController_ = routeOutput.zs_didFinishRoute(result: result)
            
            targetController = _targetController_ as? UIViewController
            
            if targetController == nil
            {
                let error = NSError(domain: "zs_didFinishRoute 返回错误", code: 502, userInfo: [NSLocalizedDescriptionKey : "请在 \(_targetClass_)->zs_didFinishRoute 中返回 UIViewController 及其子类"])
                
                zs_didRouteFail(route: route, error: error)
                
                return nil
            }
        }
        
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
            let error = NSError(domain: "target 不是 UIView.class 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_routeTarget 中返回 UIView.class 及其子类"])
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let routeOutput = (_targetClass_ as? ZSURLRouteOutput.Type) else
        {
            let error = NSError(domain: "target 没有遵循 ZSURLRouteOutput 协议", code: 501, userInfo:nil)
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
        guard let targetView = routeOutput.zs_didFinishRoute(result: result) as? UIView else
        {
            let error = NSError(domain: "zs_didFinishRoute 返回错误", code: 502, userInfo: [NSLocalizedDescriptionKey : "请在 \(_targetClass_)->zs_didFinishRoute 中返回 UIView 及其子类"])
            
            zs_didRouteFail(route: route, error: error)
            
            return nil
        }
        
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
                let custom = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
                querys.append("\(key)=\(val.addingPercentEncoding(withAllowedCharacters: custom) ?? val)")
                continue
            }
            
            querys.append("\(key)=\(value)")
        }
        return querys.map{ String($0) }.joined(separator: "&")
    }
}
