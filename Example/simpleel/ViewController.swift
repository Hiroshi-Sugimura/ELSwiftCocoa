//
//  ViewController.swift
//  simpleel
//
//  Created by sugimura on 2017/10/02.
//  Copyright © 2017年 sugimura. All rights reserved.
//

import UIKit
import ELSwift

class ViewController: UIViewController {

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var btnSearch: UIButton!
    
    let objectList:[String] = ["05ff01"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        logView.text = ""
        
        do {
            try ELSwift.initialize( objectList, { rinfo, els, err in
                if let error = err {
                    print (error)
                    return
                }
                
                if let elsv = els {
                    let seoj = elsv.SEOJ
                    let esv = elsv.ESV
                    let detail = elsv.DETAIL
                    self.logView.text = "ip:\(rinfo.address), seoj:\(seoj), esv:\(esv), datail:\(detail)" + "\n" + self.logView.text
                }
            }, 4)
        }catch let error{
            print( error )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func btnSearchDown(_ sender: Any) {
             ELSwift.search()
    }
}

