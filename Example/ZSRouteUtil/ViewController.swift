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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        JOSHURLRoute.zs_present(from: "https://www.baidu.com/index.html#/haskl/asdajs?qiuu=woiqw&jklasd=asjd&key = 1&askdhjajkshj&hk=88")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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



