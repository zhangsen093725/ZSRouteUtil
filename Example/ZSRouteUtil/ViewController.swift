//
//  ViewController.swift
//  ZSRouteUtil
//
//  Created by zhangsen093725 on 11/18/2019.
//  Copyright (c) 2019 zhangsen093725. All rights reserved.
//

import UIKit
import ZSRouteUtil

class JOSHURLRouteModule: ZSURLRoute {
    
    override class var zs_schemeMap: Dictionary<String, String> {
        
        return ["https" : "web"]
    }
    
    override class var zs_hostMap: Dictionary<String, String> {
        
        return ["www.view.com" : "view"]
    }
    
    override class var zs_ignoreQueryKey: Array<String> {
        
        return ["key", "hk"]
    }
    
    override class var zs_replaceQuery: Dictionary<String, String> {
        
        return ["key" : "hahahahaha",
                "hk" : "100"]
    }
    
    override class var zs_ignoreCase: Bool {
        
        return true
    }
    
    override class func zs_routeTarget(result: ZSURLRouteResult) -> ZSURLRouteOutput.Type? {
        
        if result.scheme == "web"
        {
            let project = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            return NSClassFromString(project + "." + result.moudle.capitalized + "Controller") as? ZSURLRouteOutput.Type
        }
        
        return ViewController.self
    }
}


class JOSHURLRoute: ZSURLRoute {
    
    override class var zs_forwardEnable: Bool {
        
        return true
    }
    
    override class var zs_forward: Array<ZSURLRouteForward> {
        
        let forward: ZSURLRouteForward = ZSURLRouteForward()
        forward.zs_host = "***.view.***"
        forward.zs_path = "*/*/*"
        forward.zs_forwardTarget = JOSHURLRouteModule.self
        
        return [forward]
    }
}


class ViewController: UIViewController, ZSURLRouteOutput {
    
    lazy var button: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Route", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonW: CGFloat = 150
        let buttonH: CGFloat = 60
        let buttonX: CGFloat = (view.frame.width - buttonW) * 0.5
        
        button.frame = CGRect(x: buttonX, y: 100, width: buttonW, height: buttonH)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        
        JOSHURLRoute.zs_push(from: "HTTPS://www.view.com/index.html#/haskl/asdajs?qiuu=https://www.baidu.com?weuu=2iwi&asdjkh=1&q=1&jklasd=asjd&key = 1&askdhjajkshj&hk=88")
    }
    
    func zs_didFinishRoute(result: ZSURLRouteResult) {
        
        print("scheme: \(result.scheme)")
        print("moudle: \(result.moudle)")
        print("submoudle: \(result.submoudle)")
        print("params: \(result.params)")
        
        print("route: \(result.route)")
        print("ignore query: \(result.ignoreQuery)")
        print("origin route: \(result.originRoute)")
    }
    
}



