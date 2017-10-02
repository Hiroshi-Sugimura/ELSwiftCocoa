# Overview

[![CI Status](http://img.shields.io/travis/Hiroshi-Sugimura/ELSwift.svg?style=flat)](https://travis-ci.org/Hiroshi-Sugimura/ELSwift)
[![Version](https://img.shields.io/cocoapods/v/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)
[![License](https://img.shields.io/cocoapods/l/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)
[![Platform](https://img.shields.io/cocoapods/p/ELSwift.svg?style=flat)](http://cocoapods.org/pods/ELSwift)

���̃��W���[����**ECHONET Lite�v���g�R��**���T�|�[�g���܂��D
ECHONET Lite�v���g�R���̓X�}�[�g�n�E�X�@��̒ʐM�v���g�R���ł��D

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
                 var EDATA: [UInt8]    // ���L��EDATA�̏ڍ�
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
    public var EDATA: [UInt8]    // ���L��EDATA�̏ڍ�
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


### �������C�o�C���h, initialize

```
ELSwift.initialize(_ objList: [String], _ callback: ((_ rinfo:(address:String, port:UInt16), _ els: EL_STRUCTURE?, _ err: Error?) -> Void)?, _ ipVer: UInt8? ) throws -> Void
```

������callback�͂���Ȋ����Ŏg���܂��傤�B

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


### �f�[�^�\���n, data representations

* ELDATA�`��

```
ELSwift.eldataShow(_ eldata:EL_STRUCTURE ) -> Void
```


* ������, string

```
ELSwift.stringShow(_ str: String ) throws -> Void
```


* �o�C�g�f�[�^, byte data

```
ELSwift.bytesShow(_ bytes: [UInt8] ) throws -> Void
```


### �ϊ��n, converters


| from              |    to             |   function                         |
|:-----------------:|:-----------------:|:----------------------------------:|
| Bytes(=Integer[]) | ELDATA            | parseBytes(bytes)                  |
| String            | ELDATA            | parseString(str)                   |
| String            | EL���ۂ�String    | getSeparatedString_String(str)     |
| ELDATA            | EL���ۂ�String    | getSeparatedString_ELDATA(eldata)  |
| ELDATA            | Bytes(=Integer[]) | ELDATA2Array(eldata)               |


* Detail������Parse����C�����ł悭�g�����ǊO���Ŏg�����킩��܂���D

```
ELSwift.parseDetail( opc:UInt8, str:String ) throws -> Dictionary<String, [UInt8]>
```

* byte data����͂����ELDATA�`���ɂ���

```
ELSwift.parseBytes(_ bytes:[UInt8] ) throws -> EL_STRUCTURE
```


* HEX�ŕ\�����ꂽString��������ELDATA�`���ɂ���

```
ELSwift.parseString(_ str: String ) throws -> EL_STRUCTURE
```


* �������������EL�炵���؂����String�𓾂�

```
ELSwift.getSeparatedString_String(_ str: String ) -> String
```

* �����񑀍삪�䖝�ł��Ȃ��̂ō��i1Byte�����Œ�j  ok
```
ELSwift.substr(_ str:String, _ begginingIndex:UInt, _ count:UInt) -> String
```

* ELDATA��������EL�炵���؂����String�𓾂�

```
ELSwift.getSeparatedString_ELDATA(_ eldata : EL_STRUCTURE ) -> String
```


* ELDATA�`������z���

```
ELSwift.ELDATA2Array(_ eldata: EL_STRUCTURE ) throws -> [UInt8]
```


* �ϊ��\

| from              |    to          |   function                         |
|:-----------------:|:--------------:|:----------------------------------:|
| Byte              | 16�i�\��String | toHexString(byte)                  |
| 16�i�\��String    |  Integer[]     | toHexArray(str)                    |


* 1�o�C�g�𕶎����16�i�\���ցi1Byte�͕K��2�����ɂ���j

```
ELSwift.toHexString(_ byte:UInt8 ) -> String
```

* HEX��String�𐔒l�̃o�C�g�z���

```
ELSwift.toHexArray(_ str: String ) -> [UInt8]
```


* �o�C�g�z��𕶎���ɂ�����

```
ELSwift.bytesToString(_ bytes: [UInt8] ) throws -> String
```


### ���M, send

* EL���M�̃x�[�X

```
ELSwift.sendBase(_ ip:String,_ data:Data ) throws -> Void
```

* �z��̎�

```
ELSwift.sendArray(_ ip:String,_ array:[UInt8] ) throws -> Void
```

* EL�̔��ɓT�^�I��OPC��ł�����

```
ELSwift.sendOPC1(_ ip:String, _ seoj:[UInt8], _ deoj:[UInt8], _ esv: UInt8, _ epc: UInt8, _ edt:[UInt8]) throws -> Void
```

ex.

```
try ELSwift.sendOPC1( '192.168.2.150', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x31]);
```


* EL�̔��ɓT�^�I�ȑ��M3 ������^�C�v

```
ELSwift.sendString(_ ip:String,_ string:String ) throws -> Void
```


### ��M�f�[�^�̊��S�R���g���[��, Full control method for received data.

EL�̎�M�f�[�^��U�蕪�����C���Ƃ����悤�D
EL�̎�M�����ׂĎ����ŏ��������l�͂�������S�ɏ���������΂����Ƃ������D
���ʂ̐l��initialize��userfunc�Ŏ������͂��D

```
ELSwift.returner( bytes:[UInt8], rinfo:((address:String, port:UInt16)) ) -> Void
```



### EL�C��ʂ̒ʐM�葱��

* �@�팟��

```
ELSwift.search() -> Void
```

* �l�b�g���[�N����EL�@��S�̏����X�V����

```
ELSwift.renewFacilities = function( ip, obj, opc, detail )
```

* �l�b�g���[�N����EL�@��S�̏����X�V����C��M�����珟��Ɏ��s����� mada, JSON�̎�舵���������Dictionary�Œ�`���Ȃ��ƃ_��

```
ELSwift.renewFacilities( ip:String, els: EL_STRUCTURE ) throws -> Void
```


* �v���p�e�B�}�b�v�����ׂĎ擾���� ok

```
ELSwift.getPropertyMaps ( ip:String, eoj:[UInt8] ) throws -> Void
```


* parse Propaty Map Form 2

16�ȏ�̃v���p�e�B���̎��C�L�q�`��2�C�o�͂�Form1�ɂ��邱��

```
ELSwift.parseMapForm2(_ bitstr:String ) -> [UInt8]
```


## ECHONET Lite�U�����i�j


xxxxx

* �R���g���[���J���Ҍ���

�����炭��Ԏg���₷����M�f�[�^��͂�EL.facilities�����̂܂�read���邱�Ƃ����D
���Ƃ��΁C���̂܂ܕ\������ƁC

Probably, easy analysis of the received data is to display directory.
For example,

```
console.dir( EL.facilities );
```

�f�[�^�͂���Ȋ����D

Reseiving data as,

```
{ '192.168.2.103':
   { '05ff01': { '80': '', d6: '' },
     '0ef001': { '80': '30', d6: '0100' } },
  '192.168.2.104': { '0ef001': { d6: '0105ff01' }, '05ff01': { '80': '30' } },
  '192.168.2.115': { '0ef001': { '80': '30', d6: '01013501' } } }
```


�܂��C�f�[�^���M�ň�Ԏg���₷�����Ȃ̂�sendOPC1���Ƃ������D
����̑g�ݍ��킹��ECHONET Lite�͂قƂ�Ǒ���ł���̂ł͂Ȃ��낤���D

The simplest sending method is 'sendOPC1.'

```
try ELSwift.sendOPC1( "192.168.2.103", [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x30]);
```


## Author

�_�ސ�H�ȑ�w  �n���H�w��  �z�[���G���N�g���j�N�X�J���w�ȁD

�����@��

Dept. of Home Electronics, Faculty of Creative Engineering, Kanagawa Institute of Technology.

SUGIMURA, Hiroshi


## License

ELSwift is available under the MIT license. See the LICENSE file for more info.


## Log

- 1.0.0 Swift 4
- 0.1.1 README.md
- 0.1.0 initial commit

