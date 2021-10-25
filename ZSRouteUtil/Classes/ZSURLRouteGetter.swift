//
//  ZSURLRouteGetter.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/12.
//

import Foundation

@objc extension ZSURLRoute {
    
    /// 当前的 navigation controller
    @objc open class var zs_navigationController: UINavigationController? {
        
        return zs_presentedController as? UINavigationController
    }
    
    /// 当前的 presented controller
    @objc open class var zs_presentedController: UIViewController? {
        
        var controller: UIViewController?
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        if let tabBarController = rootViewController as? UITabBarController
        {
            controller = tabBarController.selectedViewController
        }
        
        while (controller?.presentedViewController != nil)
        {
            controller = controller?.presentedViewController!
        }
        
        return controller ?? rootViewController
    }
    
    /// 根据类获取当前 tabbar controller 的 subcontroller
    /// - Parameter controllerClass: 类
    /// - Returns: 返回 subcontroller，未找到为 nil
    @discardableResult
    open class func zs_targetController(from controllerClass: UIViewController.Type) -> UIViewController? {
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        let tabbarController = rootViewController as? UITabBarController
        
        for controller in (tabbarController?.viewControllers ?? [])
        {
            if let navigation = controller as? UINavigationController
            {
                let subController = navigation.viewControllers.first
                
                if subController?.isMember(of: controllerClass) ?? false
                {
                    return subController
                }
            }
            
            if controller.isMember(of: controllerClass)
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
        
        guard let _route_ = zs_filterWhitespacesEnable ? zs_removeWhitespacesAndNewlinesLink(replace: route) : route else {
         
            let error = NSError(domain: "route is empty", code: 400, userInfo: [NSLocalizedDescriptionKey : "路由地址为空"])
            zs_route("", didFail: error)
            return nil
        }
        
        var params: [String : String] = zs_parmas(form: _route_)
        
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
        
        ignoreQuery = ignoreParams.zs_queryURLEncodedStringForURLRoute
        
        let removeQueryRoute = removeQueryLink.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed) ?? removeQueryLink
        
        guard let removeQueryURL = URL(string: removeQueryRoute) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_route(route ?? "", didFail: error)
            return nil
        }
        
        let result = ZSURLRouteResult()
        
        result.originRoute = _route_
        result.route = removeQueryRoute
        
        if ignoreQuery.count > 0
        {
            result.route = removeQueryRoute + "?" + ignoreQuery
        }
            
        result.ignoreQuery = ignoreQuery
        result.params = params
        
        result.originScheme = removeQueryURL.scheme ?? ""
        let scheme = (zs_ignoreCaseEnable ? result.originScheme.lowercased() : result.originScheme)
        result.scheme = zs_schemeMap[scheme] ?? result.originScheme

        zs_schemeMap.forEach { (key, value) in
            
            let schemeRule = key.replacingOccurrences(of: "*", with: ".*")
            let predcate = NSPredicate(format: "SELF MATCHES%@", schemeRule)
            
            if predcate.evaluate(with: scheme)
            {
                result.scheme = value
            }
        }
        
        result.originHost = (removeQueryURL.host) ?? ""
        let host = (zs_ignoreCaseEnable ? result.originHost.lowercased() : result.originHost)
        result.host = zs_hostMap[host] ?? result.originHost
        
        zs_hostMap.forEach { (key, value) in
            
            var hostRule = key.replacingOccurrences(of: ".", with: "[.]")
            hostRule = hostRule.replacingOccurrences(of: "*", with: ".*")
            
            let predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", hostRule)
            
            if predcate.evaluate(with: host)
            {
                result.host = value
            }
        }
        
        result.originPath = removeQueryURL.path
        let path = zs_ignoreCaseEnable ? result.originPath.lowercased() : result.originPath
        result.path = zs_pathMap[path] ?? result.originPath
        
        zs_pathMap.forEach { (key, value) in
            
            let pathRule = key.replacingOccurrences(of: "*", with: ".*")
            let predcate = NSPredicate(format: "SELF MATCHES%@", pathRule)
            
            if predcate.evaluate(with: path)
            {
                result.path = value
            }
        }
        
        return result
    }
    
    /// 获取路由的参数
    /// - Parameter route: 路由
    open class func zs_parmas(form route: String) -> [String: String] {
        
        guard let _route_ = zs_filterWhitespacesEnable ? zs_removeWhitespacesAndNewlinesLink(replace: route) : route else { return [:] }
        
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
        
        zs_forwardList.forEach { (forward) in
            
            // 正则转换www[.].*[.]com
            var hostRule = (zs_ignoreCaseEnable ? forward.host.lowercased() : forward.host).replacingOccurrences(of: ".", with: "[.]")
            hostRule = hostRule.replacingOccurrences(of: "*", with: ".*")

            var predcate: NSPredicate = NSPredicate(format: "SELF MATCHES%@", hostRule)
            var isForward = predcate.evaluate(with: (zs_ignoreCaseEnable ? result.host.lowercased() : result.host))
            
            if forward.path.count > 0 && isForward
            {
                // 正则转换
                let pathRule = (zs_ignoreCaseEnable ? forward.path.lowercased() : forward.path).replacingOccurrences(of: "*", with: ".*")
                
                predcate = NSPredicate(format: "SELF MATCHES%@", pathRule)
                isForward = predcate.evaluate(with: (zs_ignoreCaseEnable ? result.path.lowercased() : result.path))
            }
            
            if isForward
            {
                _forward = forward
                return
            }
        }
        
        return _forward?.target
    }
    
    /// 获取 target controller
    /// - Parameter route: 路由
    /// - Parameter isCheckTabbar: 是否检索是 tabbar controller
    @discardableResult
    open class func zs_targetController(from route: String,
                                        isCheckTabbar: Bool = true) -> UIViewController? {
        
        guard let result = zs_routeResolution(route) else
        {
            let error = NSError(domain: "Bad Gateway", code: 502, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_route(route, didFail: error)
            
            return nil
        }

        if let forwardTarget = zs_forwardTarget(from: result)
        {
            return forwardTarget.zs_targetController(from: route, isCheckTabbar: isCheckTabbar)
        }
        
        guard let targetClass = zs_routeTarget(from: result) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_route(route, didFail: error)
            
            return nil
        }
        
        guard let _targetClass_ = targetClass as? UIViewController.Type else
        {
            let error = NSError(domain: "target 不是 UIViewController.class 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_routeTarget 中返回 UIViewController.class 及其子类"])
            
            zs_route(route, didFail: error)
            
            return nil
        }
        
        var targetController: UIViewController?
        
        if isCheckTabbar
        {
            targetController = zs_targetController(from: _targetClass_)
        }
        
        if targetController == nil
        {
            guard let routeOutput = (_targetClass_ as? ZSURLRouteOutput.Type) else
            {
                let error = NSError(domain: "target 没有遵循 ZSURLRouteOutput 协议", code: 501, userInfo:nil)
                
                zs_route(route, didFail: error)
                
                return nil
            }
            
            let _targetController_ = routeOutput.zs_didFinishRoute(result: result)
            
            targetController = _targetController_ as? UIViewController
            
            if targetController == nil
            {
                let error = NSError(domain: "zs_didFinishRoute 返回对象类型错误", code: 502, userInfo: [NSLocalizedDescriptionKey : "请在 \(_targetClass_)->zs_didFinishRoute 中返回 UIViewController 及其子类"])
                
                zs_route(route, didFail: error)
                
                return nil
            }
        }
        
        return targetController
    }
    
    /// 获取 target view
    /// - Parameter route: 路由
    @discardableResult
    open class func zs_targetView(from route: String) -> UIView? {
        
        guard let result = zs_routeResolution(route) else
        {
            let error = NSError(domain: "Bad Gateway", code: 502, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_route(route, didFail: error)
            
            return nil
        }
        
        if let forwardTarget = zs_forwardTarget(from: result)
        {
            return forwardTarget.zs_targetView(from: route)
        }
        
        guard let targetClass = zs_routeTarget(from: result) else
        {
            let error = NSError(domain: "Not Found", code: 404, userInfo: [NSLocalizedDescriptionKey : "路由地址不正确"])
            zs_route(route, didFail: error)
            
            return nil
        }
        
        guard let _targetClass_ = targetClass as? UIView.Type else
        {
            let error = NSError(domain: "target 不是 UIView.class 及其子类", code: 500, userInfo: [NSLocalizedDescriptionKey : "请在 zs_routeTarget 中返回 UIView.class 及其子类"])
            
            zs_route(route, didFail: error)
            
            return nil
        }
        
        guard let routeOutput = (_targetClass_ as? ZSURLRouteOutput.Type) else
        {
            let error = NSError(domain: "target 没有遵循 ZSURLRouteOutput 协议", code: 501, userInfo:nil)
            
            zs_route(route, didFail: error)
            
            return nil
        }
        
        guard let targetView = routeOutput.zs_didFinishRoute(result: result) as? UIView else
        {
            let error = NSError(domain: "zs_didFinishRoute 返回错误", code: 502, userInfo: [NSLocalizedDescriptionKey : "请在 \(_targetClass_)->zs_didFinishRoute 中返回 UIView 及其子类"])
            
            zs_route(route, didFail: error)
            
            return nil
        }
        
        return targetView
    }
}


public extension Dictionary {
    
    var zs_queryURLEncodedStringForURLRoute: String {
        
        var querys: [String] = []
        
        for (key, value) in self
        {
            if let val = value as? String
            {
                let characteSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
                querys.append("\(key)=\(val.addingPercentEncoding(withAllowedCharacters: characteSet) ?? val)")
                continue
            }
            
            querys.append("\(key)=\(value)")
        }
        return querys.map{ String($0) }.joined(separator: "&")
    }
}
