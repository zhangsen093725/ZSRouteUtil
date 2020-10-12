//
//  ZSURLRouteAction.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by Josh on 2020/10/12.
//

import Foundation

@objc extension ZSURLRoute {
    
    /// 切换选中的 tabbar controller
    /// - Parameters:
    ///   - controller: 当前的控制器
    ///   - isCheckTabbar: 是否开启 tabbar 切换
    /// - Returns: 返回切换成功还是失败
    @discardableResult
    open class func zs_selectTabbar(controller: UIViewController, isCheckTabbar: Bool = true) -> Bool {
        
        guard isCheckTabbar else { return false }
        
        guard let tabIdx = controller.tabBarController?.viewControllers?.firstIndex(of: controller) else { return false }
        
        controller.dismiss(animated: false, completion: nil)
        controller.navigationController?.popToRootViewController(animated: false)
        controller.tabBarController?.selectedIndex = tabIdx
        
        return true
    }
    
    /// push 到指定路由
    /// - Parameters:
    ///   - route: 路由地址
    ///   - isCheckTabbar: 是否开启 tabbar 验证
    ///   - animated: 是否开启动画
    /// - Returns: 路由地址对应的目标控制器
    @discardableResult
    open class func zs_push(from route: String, isCheckTabbar: Bool = true, animated: Bool = true) -> UIViewController? {
        
        let controller = zs_targetController(from: route, isCheckTabbar: isCheckTabbar)
        
        if controller == nil { return controller }
        
        if zs_selectTabbar(controller: controller!, isCheckTabbar: isCheckTabbar) { return controller }
        
        zs_currentNavigation?.pushViewController(controller!, animated: animated)
        return controller
    }
    
    /// pop 到指定路由
    /// - Parameters:
    ///   - route: 路由地址
    ///   - isCheckTabbar: 是否开启 tabbar 验证
    ///   - animated: 是否开启动画
    /// - Returns: 路由地址对应的目标控制器
    @discardableResult
    open class func zs_pop(from route: String, isCheckTabbar: Bool = true, animated: Bool = true) -> UIViewController? {
        
        let controller = zs_targetController(from: route, isCheckTabbar: isCheckTabbar)
        
        if controller == nil { return controller }
        
        if zs_selectTabbar(controller: controller!, isCheckTabbar: isCheckTabbar) { return controller }
        
        if zs_currentNavigation?.navigationController?.viewControllers.contains(controller!) ?? false
        {
            zs_currentNavigation?.popToViewController(controller!, animated: animated)
        }
        
        return controller
    }
    
    /// preset 到指定路由
    /// - Parameters:
    ///   - route: 路由地址
    ///   - modalPresentationStyle: preset 的方式
    ///   - isCheckTabbar: 是否开启 tabbar 验证
    ///   - animated: 是否开启动画
    ///   - completion: 动画完成
    /// - Returns: 路由地址对应的目标控制器
    @discardableResult
    open class func zs_present(from route: String,
                               modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
                               isCheckTabbar: Bool = true,
                               animated: Bool = true,
                               completion: (() -> Void)? = nil) -> UIViewController? {
        
        let controller = zs_targetController(from: route, isCheckTabbar: isCheckTabbar)
        
        if controller == nil { return controller }
        
        if zs_selectTabbar(controller: controller!, isCheckTabbar: isCheckTabbar) { return controller }
        
        controller!.modalPresentationStyle = .fullScreen
        zs_presentedController?.present(controller!, animated: animated, completion: completion)
        
        return controller
    }
}
