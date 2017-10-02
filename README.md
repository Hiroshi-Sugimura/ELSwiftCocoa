# Overview

[![CI Status](http://img.shields.io/travis/Hiroshi-Sugimura/ELSwift.svg?style=flat)](https://travis-ci.org/Hiroshi-Sugimura/ELSwift)
[![Version](https://img.shields.io/cocoapods/v/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)
[![License](https://img.shields.io/cocoapods/l/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)
[![Platform](https://img.shields.io/cocoapods/p/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)

このモジュールは**ECHONET Liteプロトコル**をサポートします．
ECHONET Liteプロトコルはスマートハウス機器の通信プロトコルです．

This module provides **ECHONET Lite protocol**.
The ECHONET Lite protocol is a communication protocol for smart home devices.


## Installation

ELSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!

target 'simpleel' do  # << your target name
  pod 'ELSwift'
end
```



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Xcode 8.0
- iOS 9.3 (?)


## Demos(controller)

```Swift:Demo (ViewController.swift)
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
```


## Data stracture

```Swift:ELSwift
public class ELSwift : NSObject {
    static var isIPv6 = false
    static var inSocket: InSocket!
    static var outSocket: OutSocket!
    public static let MULTI_IP: String = "224.0.23.0"
    public static let PORT: UInt16 = 3360

    // define
    public static let SETI_SNA = 0x50
    public static let SETC_SNA = 0x51
    public static let GET_SNA = 0x52
    public static let INF_SNA = 0x53
    public static let SETGET_SNA = 0x5e
    public static let SETI = 0x60
    public static let SETC = 0x61
    public static let GET = 0x62
    public static let INF_REQ = 0x63
    public static let SETGET = 0x6e
    public static let SET_RES = 0x71
    public static let GET_RES = 0x72
    public static let INF = 0x73
    public static let INFC = 0x74
    public static let INFC_RES = 0x7a
    public static let SETGET_RES = 0x7e
    public static let EL_port = 3610
    public static let EL_Multi = "224.0.23.0"
    public static let EL_Multi6 = "FF02::1"

    static var EL_obj: [String]!
    static var EL_cls: [String]!

    public static var Node_details: Dictionary
    public static var facilities:Dictionary
}
```


```Swift:EL_STRUCTURE
public class EL_STRUCTURE : NSObject{
    public var EHD : [UInt8]
    public var TID : [UInt8]
    public var SEOJ : [UInt8]
    public var DEOJ : [UInt8]
    public var EDATA: [UInt8]    // 下記はEDATAの詳細
    public var ESV : UInt8
    public var OPC : UInt8
    public var DETAIL: [UInt8]
    public var DETAILs: Dictionary<String, [UInt8]>

    override init() {
        EHD = []
        TID = []
        SEOJ = []
        DEOJ = []
        EDATA = []
        ESV = 0x00
        OPC = 0x00
        DETAIL = []
        DETAILs = [String: [UInt8]]()
    }
}
```


## API


### 初期化，バインド, initialize

```
ELSwift.initialize(_ objList: [String], _ callback: ((_ rinfo:(address:String, port:UInt16), _ els: EL_STRUCTURE?, _ err: Error?) -> Void)?, _ ipVer: UInt8? ) throws -> Void
```

そしてcallbackはこんな感じで使いましょう。

```
do {
    try ELSwift.initialize( objectList, { rinfo, els, err in
        if let error = err {
            print (error)
            return
        }

        // ToDo

    }, 4)
}catch let error{
    print( error )
}
```


### データ表示系, data representations

* ELDATA形式

```
ELSwift.eldataShow(_ eldata:EL_STRUCTURE ) -> Void
```


* 文字列, string

```
ELSwift.stringShow(_ str: String ) throws -> Void
```


* バイトデータ, byte data

```
ELSwift.bytesShow(_ bytes: [UInt8] ) throws -> Void
```


### 変換系, converters


| from              |    to             |   function                         |
|:-----------------:|:-----------------:|:----------------------------------:|
| Bytes(=Integer[]) | ELDATA            | parseBytes(bytes)                  |
| String            | ELDATA            | parseString(str)                   |
| String            | ELっぽいString    | getSeparatedString_String(str)     |
| ELDATA            | ELっぽいString    | getSeparatedString_ELDATA(eldata)  |
| ELDATA            | Bytes(=Integer[]) | ELDATA2Array(eldata)               |


* DetailだけをParseする，内部でよく使うけど外部で使うかわかりません．

```
ELSwift.parseDetail( opc:UInt8, str:String ) throws -> Dictionary<String, [UInt8]>
```

* byte dataを入力するとELDATA形式にする

```
ELSwift.parseBytes(_ bytes:[UInt8] ) throws -> EL_STRUCTURE
```


* HEXで表現されたStringをいれるとELDATA形式にする

```
ELSwift.parseString(_ str: String ) throws -> EL_STRUCTURE
```


* 文字列をいれるとELらしい切り方のStringを得る

```
ELSwift.getSeparatedString_String(_ str: String ) -> String
```

* 文字列操作が我慢できないので作る（1Byte文字固定）  ok
```
ELSwift.substr(_ str:String, _ begginingIndex:UInt, _ count:UInt) -> String
```

* ELDATAをいれるとELらしい切り方のStringを得る

```
ELSwift.getSeparatedString_ELDATA(_ eldata : EL_STRUCTURE ) -> String
```


* ELDATA形式から配列へ

```
ELSwift.ELDATA2Array(_ eldata: EL_STRUCTURE ) throws -> [UInt8]
```


* 変換表

| from              |    to          |   function                         |
|:-----------------:|:--------------:|:----------------------------------:|
| Byte              | 16進表現String | toHexString(byte)                  |
| 16進表現String    |  Integer[]     | toHexArray(str)                    |


* 1バイトを文字列の16進表現へ（1Byteは必ず2文字にする）

```
ELSwift.toHexString(_ byte:UInt8 ) -> String
```

* HEXのStringを数値のバイト配列へ

```
ELSwift.toHexArray(_ str: String ) -> [UInt8]
```


* バイト配列を文字列にかえる

```
ELSwift.bytesToString(_ bytes: [UInt8] ) throws -> String
```


### 送信, send

* EL送信のベース

```
ELSwift.sendBase(_ ip:String,_ data:Data ) throws -> Void
```

* 配列の時

```
ELSwift.sendArray(_ ip:String,_ array:[UInt8] ) throws -> Void
```

* ELの非常に典型的なOPC一個でやる方式

```
ELSwift.sendOPC1(_ ip:String, _ seoj:[UInt8], _ deoj:[UInt8], _ esv: UInt8, _ epc: UInt8, _ edt:[UInt8]) throws -> Void
```

ex.

```
try ELSwift.sendOPC1( '192.168.2.150', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x31]);
```


* ELの非常に典型的な送信3 文字列タイプ

```
ELSwift.sendString(_ ip:String,_ string:String ) throws -> Void
```


### 受信データの完全コントロール, Full control method for received data.

ELの受信データを振り分けるよ，何とかしよう．
ELの受信をすべて自分で書きたい人はこれを完全に書き換えればいいとおもう．
普通の人はinitializeのuserfuncで事足りるはず．

```
ELSwift.returner( bytes:[UInt8], rinfo:((address:String, port:UInt16)) ) -> Void
```



### EL，上位の通信手続き

* 機器検索

```
ELSwift.search() -> Void
```

* ネットワーク内のEL機器全体情報を更新する

```
ELSwift.renewFacilities = function( ip, obj, opc, detail )
```

* ネットワーク内のEL機器全体情報を更新する，受信したら勝手に実行される mada, JSONの取り扱いが難しいとDictionaryで定義しないとダメ

```
ELSwift.renewFacilities( ip:String, els: EL_STRUCTURE ) throws -> Void
```


* プロパティマップをすべて取得する ok

```
ELSwift.getPropertyMaps ( ip:String, eoj:[UInt8] ) throws -> Void
```


* parse Propaty Map Form 2

16以上のプロパティ数の時，記述形式2，出力はForm1にすること

```
ELSwift.parseMapForm2(_ bitstr:String ) -> [UInt8]
```


## ECHONET Lite攻略情報（）


xxxxx

* コントローラ開発者向け

おそらく一番使いやすい受信データ解析はEL.facilitiesをそのままreadすることかも．
たとえば，そのまま表示すると，

Probably, easy analysis of the received data is to display directory.
For example,

```
console.dir( EL.facilities );
```

データはこんな感じ．

Reseiving data as,

```
{ '192.168.2.103':
   { '05ff01': { '80': '', d6: '' },
     '0ef001': { '80': '30', d6: '0100' } },
  '192.168.2.104': { '0ef001': { d6: '0105ff01' }, '05ff01': { '80': '30' } },
  '192.168.2.115': { '0ef001': { '80': '30', d6: '01013501' } } }
```


また，データ送信で一番使いやすそうなのはsendOPC1だとおもう．
これの組み合わせてECHONET Liteはほとんど操作できるのではなかろうか．

The simplest sending method is 'sendOPC1.'

```
try ELSwift.sendOPC1( "192.168.2.103", [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x30]);
```


## Author

神奈川工科大学  創造工学部  ホームエレクトロニクス開発学科．

杉村　博

Dept. of Home Electronics, Faculty of Creative Engineering, Kanagawa Institute of Technology.

SUGIMURA, Hiroshi


## License

ELSwift is available under the MIT license. See the LICENSE file for more info.


## Log

- 1.0.0 Swift 4
- 0.1.1 README.md
- 0.1.0 initial commit

