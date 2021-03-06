//
//  ViewController.swift
//  ZSRouteUtil
//
//  Created by zhangsen093725 on 11/18/2019.
//  Copyright (c) 2019 zhangsen093725. All rights reserved.
//

import UIKit
import ZSRouteUtil

class JOSHURLForwardRoute: ZSURLRoute {
    
    override class var zs_schemeMap: Dictionary<String, String> {
        
        return ["http*" : "web"]
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
    
    override class var zs_ignoreCaseEnable: Bool {
        
        return true
    }
    
    override class var zs_filterWhitespacesEnable: Bool {
        
        return false
    }
    
    override class func zs_routeTarget(from result: ZSURLRouteResult) -> ZSURLRouteOutput.Type? {
        
        if result.scheme == "web"
        {
            let project = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            return NSClassFromString(project + "." + result.host.capitalized + "Controller") as? ZSURLRouteOutput.Type
        }
        
        return ViewController.self
    }
}


class JOSHURLRoute: ZSURLRoute {
    
    override class var zs_forwardEnable: Bool {
        
        return true
    }
    
    override class var zs_ignoreCaseEnable: Bool {
        
        return true
    }
    
    override class var zs_forwardList: Array<ZSURLRouteForward> {
        
        let forward: ZSURLRouteForward = ZSURLRouteForward()
        forward.host = "www.***.com"
        forward.path = "*/*/*"
        forward.target = JOSHURLForwardRoute.self
        
        return [forward]
    }
}


class ViewController: UIViewController, ZSURLRouteOutput {
    
    static func zs_didFinishRoute(result: ZSURLRouteResult) -> ZSURLRouteOutput {
        
        print("scheme: \(result.scheme)")
        print("moudle: \(result.host)")
        print("submoudle: \(result.path)")
        print("params: \(result.params)")
        
        print("route: \(result.route)")
        print("ignore query: \(result.ignoreQuery)")
        print("origin route: \(result.originRoute)")
        
        return self.init()
    }
    
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
        
        guard let url = "https://www.baidu.com?weuu=2iwi&asdjkh=1&q=1".addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted) else { return }
        
        JOSHURLRoute.zs_push(from: "HTTPS://www.view.com/index.html#/haskl/asdajs?qiuu=" + url  + "&jklasd=asjd&key = 1&askdhjajkshj&hk=88")
    }
}



