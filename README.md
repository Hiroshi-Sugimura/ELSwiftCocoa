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

target 'ELSwift_Example' do  # << your target name
  pod 'ELSwift'
  pod 'CocoaAsyncSocket'
end
```



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Xcode 8.0
- iOS 9.3 (?)


## Demos(controller)


```JavaScript:Demo
// モジュールの機能をELとして使う
// import functions as EL object
var EL = require('echonet-lite');

// 自分自身のオブジェクトを決める
// set EOJ for this script
// initializeで設定される，必ず何か設定しないといけない，今回はコントローラ
// this EOJ list is required. '05ff01' is a controller.
var objList = ['05ff01'];

////////////////////////////////////////////////////////////////////////////
// 初期化するとともに，受信動作をコールバックで登録する
// initialize and setting callback. the callback is called by reseived packet.
var elsocket = EL.initialize( objList, function( rinfo, els, err ) {

	if( err ){
		console.dir(err);
	}else{
		console.log('==============================');
		console.log('Get ECHONET Lite data');
		console.log('rinfo is ');
		console.dir(rinfo);

		// elsはELDATA構造になっているので使いやすいかも
		// els is ELDATA stracture.
		console.log('----');
		console.log('els is ');
		console.dir(els);

		// ELDATAをArrayにする事で使いやすい人もいるかも
		// convert ELDATA into byte array.
		console.log('----');
		console.log( 'ECHONET Lite data array is ' );
		console.log( EL.ELDATA2Array( els ) );

		// 受信データをもとに，実は内部的にfacilitiesの中で管理している
		// this module manages facilities by receved packets.
		console.log('----');
		console.log( 'Found facilities are ' );
		console.dir( EL.facilities );
	}
});

// NetworkのELをすべてsearchしてみよう．
// search ECHONET nodes in local network
EL.search();
```


## Demos(Devices)

こんな感じで作ってみたらどうでしょうか．
あとはairconObjのプロパティをグローバル変数として，別の関数から書き換えてもいいですよね．
これでGetに対応できるようになります．


```JavaScript:Demo
//////////////////////////////////////////////////////////////////////
// ECHONET Lite
var EL = require('echonet-lite');

// エアコンを例に
var objList = ['013001'];

// 自分のエアコンのデータ，今回はこのデータをグローバル的に使用する方法で紹介する．
var airconObj = {
    // super
    "80": [0x30],  // 動作状態
    "81": [0xff],  // 設置場所
    "82": [0x00, 0x00, 0x66, 0x00], // EL version, 1.1
    "88": [0x42],  // 異常状態
    "8a": [0x00, 0x00, 0x77], // maker code
    "9d": [0x04, 0x80, 0x8f, 0xa0, 0xb0],        // inf map, 1 Byte目は個数
    "9e": [0x04, 0x80, 0x8f, 0xa0, 0xb0],        // set map, 1 Byte目は個数
    "9f": [0x0d, 0x80, 0x81, 0x82, 0x88, 0x8a, 0x8f, 0x9d, 0x9e, 0x9f, 0xa0, 0xb0, 0xb3, 0xbb], // get map, 1 Byte目は個数
    // child
    "8f": [0x41], // 節電動作設定
    "a0": [0x31], // 風量設定
    "b0": [0x41], // 運転モード設定
    "b3": [0x19], // 温度設定値
    "bb": [0x1a] // 室内温度計測値
};

// ノードプロファイルに関しては内部処理するので，ユーザーはエアコンに関する受信処理だけを記述する．
var elsocket = EL.initialize( objList, function( rinfo, els ) {
    // コントローラがGetしてくるので，対応してあげる
    // エアコンを指定してきたかチェック
    if( els.DEOJ == '013000' || els.DEOJ == '013001' ) {
        // ESVで振り分け，主に0x60系列に対応すればいい
        switch( els.ESV ) {
            ////////////////////////////////////////////////////////////////////////////////////
            // 0x6x
          case EL.SETI: // "60
            break;
          case EL.SETC: // "61"，返信必要あり
            break;

          case EL.GET: // 0x62，Get
            for( var epc in els.DETAILs ) {
                if( airconObj[epc] ) { // 持ってるEPCのとき
                    EL.sendOPC1( rinfo.address, [0x01, 0x30, 0x01], EL.toHexArray(els.SEOJ), 0x72, EL.toHexArray(epc), airconObj[epc] );
                } else { // 持っていないEPCのとき, SNA
                    EL.sendOPC1( rinfo.address, [0x01, 0x30, 0x01], EL.toHexArray(els.SEOJ), 0x52, EL.toHexArray(epc), [0x00] );
                }
            }
            break;

          case EL.INFREQ: // 0x63
            break;

          case EL.SETGET: // "6e"
            break;

          default:
            // console.log( "???" );
            // console.dir( els );
            break;
        }
    }
});

//////////////////////////////////////////////////////////////////////
// 全て立ち上がったのでINFでエアコンONの宣言
EL.sendOPC1( '224.0.23.0', [0x01,0x30,0x01], [0x0e,0xf0,0x01], 0x73, 0x80, [0x30]);
```


## Data stracture

```
var EL = {
EL_port: 3610,
EL_Multi: '224.0.23.0',
EL_obj: null,
facilities: {}  // ネットワーク内の機器情報リスト
// Ex.
// { '192.168.0.3': { '05ff01': { d6: '' } },
// { '192.168.0.4': { '05ff01': { '80': '30', '82': '30' } } }
};


ELデータはこのモジュールで定義した構造で，下記のようになっています．

ELDATA is ECHONET Lite data stracture, which conteints

ELDATA {
  EHD : str.substr( 0, 4 ),
  TID : str.substr( 4, 4 ),
  SEOJ : str.substr( 8, 6 ),
  DEOJ : str.substr( 14, 6 ),
  EDATA: str.substr( 20 ),    // EDATA is followings
  ESV : str.substr( 20, 2 ),
  OPC : str.substr( 22, 2 ),
  DETAIL: str.substr( 24 ),
  DETAILs: EL.parseDetail( str.substr( 22, 2 ), str.substr( 24 ) )
}
```


## API


### 初期化，バインド, initialize

```
EL.initialize = function ( objList, userfunc, ipVer )
```

そしてuserfuncはこんな感じで使いましょう。

```
function( rinfo, els, err ) {

	console.log('==============================');
	if( err ) {
		console.dir(err);
	}else{
		// ToDo
	}
}
```


### データ表示系, data representations

* ELDATA形式

```
EL.eldataShow = function( eldata )
```


* 文字列, string

```
EL.stringShow = function( str )
```


* バイトデータ, byte data

```
EL.bytesShow = function( bytes )
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
EL.parseDetail = function( opc, str )
```

* byte dataを入力するとELDATA形式にする

```
EL.parseBytes = function( bytes )
```


* HEXで表現されたStringをいれるとELDATA形式にする

```
EL.parseString = function( str )
```


* 文字列をいれるとELらしい切り方のStringを得る

```
EL.getSeparatedString_String = function( str )
```


* ELDATAをいれるとELらしい切り方のStringを得る

```
EL.getSeparatedString_ELDATA = function( eldata )
```

* ELDATA形式から配列へ

```
EL.ELDATA2Array = function( eldata )
```


* 変換表

| from              |    to          |   function                         |
|:-----------------:|:--------------:|:----------------------------------:|
| Byte              | 16進表現String | toHexString(byte)                  |
| 16進表現String    |  Integer[]     | toHexArray(str)                    |


* 1バイトを文字列の16進表現へ（1Byteは必ず2文字にする）

```
EL.toHexString = function( byte )
```

* HEXのStringを数値のバイト配列へ

```
EL.toHexArray = function( string )
```


### 送信, send

* EL送信のベース

```
EL.sendBase = function( ip, buffer )
```

* 配列の時

```
EL.sendArray = function( ip, array )
```

* ELの非常に典型的なOPC一個でやる方式

```
EL.sendOPC1 = function( ip, seoj, deoj, esv, epc, edt)
```

ex.

```
EL.sendOPC1( '192.168.2.150', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x31]);
EL.sendOPC1( '192.168.2.150', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, 0x31);
EL.sendOPC1( '192.168.2.150', "05ff01", "013501", "61", "80", "31");
EL.sendOPC1( '192.168.2.150', "05ff01", "013501", EL.SETC, "80", "31");
```


* ELの非常に典型的な送信3 文字列タイプ

```
EL.sendString = function( ip, string )
```


### 受信データの完全コントロール, Full control method for received data.

ELの受信データを振り分けるよ，何とかしよう．
ELの受信をすべて自分で書きたい人はこれを完全に書き換えればいいとおもう．
普通の人はinitializeのuserfuncで事足りるはず．

```
EL.returner = function( bytes, rinfo, userfunc )
```



### EL，上位の通信手続き

* 機器検索

```
EL.search = function()
```

* ネットワーク内のEL機器全体情報を更新する

```
EL.renewFacilities = function( ip, obj, opc, detail )
```


## ECHONET Lite攻略情報


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
EL.sendOPC1( '192.168.2.103', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x30]);
```








## Author

神奈川工科大学  創造工学部  ホームエレクトロニクス開発学科．

杉村　博

Dept. of Home Electronics, Faculty of Creative Engineering, Kanagawa Institute of Technology.

SUGIMURA, Hiroshi


## License

ELSwift is available under the MIT license. See the LICENSE file for more info.


## Log

0.1.0 initial commit

