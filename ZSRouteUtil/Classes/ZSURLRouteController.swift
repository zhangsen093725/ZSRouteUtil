//
//  ZSURLRouteController.swift
//  Pods-ZSRouteUtil_Example
//
//  Created by 张森 on 2019/11/19.
//

import UIKit

public enum ZSURLRouteMode {
    case push
    case present
    case pop
}

open class ZSURLRouteController: UIViewController, ZSURLRoute {
    
    public var zs_params: [String: String] = [:] {
        
        didSet {
            zs_didChangedParams()
        }
    }
    
    open func zs_didChangedParams() {
        
    }
    
    open func zs_route(to controller: UIViewController,
                       mode: ZSURLRouteMode = .push,
                       isAnimation: Bool = true,
                       complete: (() -> Void)? = nil) {
        
        let tabIdx = ZSURLRouteController.zs_indexOfTabbar(currentController: controller.classForCoder)
        
        if tabIdx != NSNotFound {
            controller.dismiss(animated: false, completion: nil)
            controller.navigationController?.popToRootViewController(animated: false)
            controller.tabBarController?.selectedIndex = tabIdx
            return
        }
        
        switch mode {
        case .push:
            
            navigationController?.pushViewController(controller, animated: isAnimation)
            break
        case .pop:
            
            let isContains = navigationController?.viewControllers.contains(controller) ?? false
            guard isContains == true else { return }
            navigationController?.popToViewController(controller, animated: isAnimation)
            break
        case .present:
            
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: isAnimation, completion: complete)
            break
        }
    }
    
    // TODO: ZSURLRoute
    open func zs_routeForCustomRule(_ url: URL) {
        
    }
    
    open func zs_ignoreKeysWithRoute() -> [String] {
    
        return []
    }
    
    open func zs_didFinishRoute(scheme: String?, host: String?, path: String?, query: String, params: [String : String]?) {
        
    }
}
