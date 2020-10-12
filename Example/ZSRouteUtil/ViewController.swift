//
//  ViewController.swift
//  ZSRouteUtil
//
//  Created by zhangsen093725 on 11/18/2019.
//  Copyright (c) 2019 zhangsen093725. All rights reserved.
//

import UIKit
import ZSRouteUtil

class JOSHURLRoute: ZSURLRoute {
    
    override class var zs_ignoreQueryKey: Array<String> {
        
        return ["key", "hk"]
    }
    
    override class var zs_replaceQuery: Dictionary<String, String> {
        
        return ["key" : "hahahahaha",
                "hk" : "100"]
    }
    
    override class func zs_routeTarget(result: ZSURLRouteResult) -> ZSURLRouteOutput.Type? {
        
        
        return ViewController.self
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
        
        JOSHURLRoute.zs_push(from: "https://www.baidu.com/index.html#/haskl/asdajs?qiuu=woiqw&jklasd=asjd&key = 1&askdhjajkshj&hk=88")
    }
    
    func zs_didFinishRoute(result: ZSURLRouteResult) {
        
        print("scheme: \(result.scheme)")
        print("host: \(result.moudle)")
        print("path: \(result.submoudle)")
        print("params: \(result.params)")
        
        print("route: \(result.route)")
        print("ignore query: \(result.ignoreQuery)")
        print("origin route: \(result.originRoute)")
    }
    
}



