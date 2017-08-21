//
//  ViewController.swift
//  ELSwift
//
//  Created by Hiroshi-Sugimura on 08/21/2017.
//  Copyright (c) 2017 Hiroshi-Sugimura. All rights reserved.
//

import UIKit
import ELSwift

class ViewController: UIViewController {

    let objectList:[String] = ["05ff01"]

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var btnSearch: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logView.text = ""
        
        do {
            try ELSwift.initialize( objectList, { rinfo, els, err in
                if let error = err {
                    print (error)
                    return
                }
                
                // sample 1: udp recv
                // els is a EL_STRACTURE
                /*
                 var EHD : [UInt8]
                 var TID : [UInt8]
                 var SEOJ : [UInt8]
                 var DEOJ : [UInt8]
                 var EDATA: [UInt8]    // 下記はEDATAの詳細
                 var ESV : UInt8
                 var OPC : UInt8
                 var DETAIL: [UInt8]
                 var DETAILs: Dictionary<String, [UInt8]>
                 */
                
                if let elsv = els {
                    let seoj = elsv.SEOJ
                    let esv = elsv.ESV
                    let detail = elsv.DETAIL
                    self.logView.text = "ip:\(rinfo.address), seoj:\(seoj), esv:\(esv), datail:\(detail)" + "\n" + self.logView.text
                }
                
                /*
                 // sample 2: facilities view
                 self.logView.text = ""
                 for ( ip, v ) in ELSwift.facilities {
                 for(obj, a) in v! {
                 for( epc, edt ) in a! {
                 // print( "ip:\(ip), obj:\(obj), epc:\(epc), edt:\(edt)" )
                 let s = "ip:\(ip), obj:\(obj), epc:\(epc), edt:\(edt!)"
                 self.logView.text = s + "\n" + self.logView.text
                 }
                 }
                 }
                 */
                
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

