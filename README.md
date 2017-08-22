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
// ���W���[���̋@�\��EL�Ƃ��Ďg��
// import functions as EL object
var EL = require('echonet-lite');

// �������g�̃I�u�W�F�N�g�����߂�
// set EOJ for this script
// initialize�Őݒ肳���C�K�������ݒ肵�Ȃ��Ƃ����Ȃ��C����̓R���g���[��
// this EOJ list is required. '05ff01' is a controller.
var objList = ['05ff01'];

////////////////////////////////////////////////////////////////////////////
// ����������ƂƂ��ɁC��M������R�[���o�b�N�œo�^����
// initialize and setting callback. the callback is called by reseived packet.
var elsocket = EL.initialize( objList, function( rinfo, els, err ) {

	if( err ){
		console.dir(err);
	}else{
		console.log('==============================');
		console.log('Get ECHONET Lite data');
		console.log('rinfo is ');
		console.dir(rinfo);

		// els��ELDATA�\���ɂȂ��Ă���̂Ŏg���₷������
		// els is ELDATA stracture.
		console.log('----');
		console.log('els is ');
		console.dir(els);

		// ELDATA��Array�ɂ��鎖�Ŏg���₷���l�����邩��
		// convert ELDATA into byte array.
		console.log('----');
		console.log( 'ECHONET Lite data array is ' );
		console.log( EL.ELDATA2Array( els ) );

		// ��M�f�[�^�����ƂɁC���͓����I��facilities�̒��ŊǗ����Ă���
		// this module manages facilities by receved packets.
		console.log('----');
		console.log( 'Found facilities are ' );
		console.dir( EL.facilities );
	}
});

// Network��EL�����ׂ�search���Ă݂悤�D
// search ECHONET nodes in local network
EL.search();
```


## Demos(Devices)

����Ȋ����ō���Ă݂���ǂ��ł��傤���D
���Ƃ�airconObj�̃v���p�e�B���O���[�o���ϐ��Ƃ��āC�ʂ̊֐����珑�������Ă������ł���ˁD
�����Get�ɑΉ��ł���悤�ɂȂ�܂��D


```JavaScript:Demo
//////////////////////////////////////////////////////////////////////
// ECHONET Lite
var EL = require('echonet-lite');

// �G�A�R������
var objList = ['013001'];

// �����̃G�A�R���̃f�[�^�C����͂��̃f�[�^���O���[�o���I�Ɏg�p������@�ŏЉ��D
var airconObj = {
    // super
    "80": [0x30],  // ������
    "81": [0xff],  // �ݒu�ꏊ
    "82": [0x00, 0x00, 0x66, 0x00], // EL version, 1.1
    "88": [0x42],  // �ُ���
    "8a": [0x00, 0x00, 0x77], // maker code
    "9d": [0x04, 0x80, 0x8f, 0xa0, 0xb0],        // inf map, 1 Byte�ڂ͌�
    "9e": [0x04, 0x80, 0x8f, 0xa0, 0xb0],        // set map, 1 Byte�ڂ͌�
    "9f": [0x0d, 0x80, 0x81, 0x82, 0x88, 0x8a, 0x8f, 0x9d, 0x9e, 0x9f, 0xa0, 0xb0, 0xb3, 0xbb], // get map, 1 Byte�ڂ͌�
    // child
    "8f": [0x41], // �ߓd����ݒ�
    "a0": [0x31], // ���ʐݒ�
    "b0": [0x41], // �^�]���[�h�ݒ�
    "b3": [0x19], // ���x�ݒ�l
    "bb": [0x1a] // �������x�v���l
};

// �m�[�h�v���t�@�C���Ɋւ��Ă͓�����������̂ŁC���[�U�[�̓G�A�R���Ɋւ����M�����������L�q����D
var elsocket = EL.initialize( objList, function( rinfo, els ) {
    // �R���g���[����Get���Ă���̂ŁC�Ή����Ă�����
    // �G�A�R�����w�肵�Ă������`�F�b�N
    if( els.DEOJ == '013000' || els.DEOJ == '013001' ) {
        // ESV�ŐU�蕪���C���0x60�n��ɑΉ�����΂���
        switch( els.ESV ) {
            ////////////////////////////////////////////////////////////////////////////////////
            // 0x6x
          case EL.SETI: // "60
            break;
          case EL.SETC: // "61"�C�ԐM�K�v����
            break;

          case EL.GET: // 0x62�CGet
            for( var epc in els.DETAILs ) {
                if( airconObj[epc] ) { // �����Ă�EPC�̂Ƃ�
                    EL.sendOPC1( rinfo.address, [0x01, 0x30, 0x01], EL.toHexArray(els.SEOJ), 0x72, EL.toHexArray(epc), airconObj[epc] );
                } else { // �����Ă��Ȃ�EPC�̂Ƃ�, SNA
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
// �S�ė����オ�����̂�INF�ŃG�A�R��ON�̐錾
EL.sendOPC1( '224.0.23.0', [0x01,0x30,0x01], [0x0e,0xf0,0x01], 0x73, 0x80, [0x30]);
```


## Data stracture

```
var EL = {
EL_port: 3610,
EL_Multi: '224.0.23.0',
EL_obj: null,
facilities: {}  // �l�b�g���[�N���̋@���񃊃X�g
// Ex.
// { '192.168.0.3': { '05ff01': { d6: '' } },
// { '192.168.0.4': { '05ff01': { '80': '30', '82': '30' } } }
};


EL�f�[�^�͂��̃��W���[���Œ�`�����\���ŁC���L�̂悤�ɂȂ��Ă��܂��D

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


### �������C�o�C���h, initialize

```
EL.initialize = function ( objList, userfunc, ipVer )
```

������userfunc�͂���Ȋ����Ŏg���܂��傤�B

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


### �f�[�^�\���n, data representations

* ELDATA�`��

```
EL.eldataShow = function( eldata )
```


* ������, string

```
EL.stringShow = function( str )
```


* �o�C�g�f�[�^, byte data

```
EL.bytesShow = function( bytes )
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
EL.parseDetail = function( opc, str )
```

* byte data����͂����ELDATA�`���ɂ���

```
EL.parseBytes = function( bytes )
```


* HEX�ŕ\�����ꂽString��������ELDATA�`���ɂ���

```
EL.parseString = function( str )
```


* �������������EL�炵���؂����String�𓾂�

```
EL.getSeparatedString_String = function( str )
```


* ELDATA��������EL�炵���؂����String�𓾂�

```
EL.getSeparatedString_ELDATA = function( eldata )
```

* ELDATA�`������z���

```
EL.ELDATA2Array = function( eldata )
```


* �ϊ��\

| from              |    to          |   function                         |
|:-----------------:|:--------------:|:----------------------------------:|
| Byte              | 16�i�\��String | toHexString(byte)                  |
| 16�i�\��String    |  Integer[]     | toHexArray(str)                    |


* 1�o�C�g�𕶎����16�i�\���ցi1Byte�͕K��2�����ɂ���j

```
EL.toHexString = function( byte )
```

* HEX��String�𐔒l�̃o�C�g�z���

```
EL.toHexArray = function( string )
```


### ���M, send

* EL���M�̃x�[�X

```
EL.sendBase = function( ip, buffer )
```

* �z��̎�

```
EL.sendArray = function( ip, array )
```

* EL�̔��ɓT�^�I��OPC��ł�����

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


* EL�̔��ɓT�^�I�ȑ��M3 ������^�C�v

```
EL.sendString = function( ip, string )
```


### ��M�f�[�^�̊��S�R���g���[��, Full control method for received data.

EL�̎�M�f�[�^��U�蕪�����C���Ƃ����悤�D
EL�̎�M�����ׂĎ����ŏ��������l�͂�������S�ɏ���������΂����Ƃ������D
���ʂ̐l��initialize��userfunc�Ŏ������͂��D

```
EL.returner = function( bytes, rinfo, userfunc )
```



### EL�C��ʂ̒ʐM�葱��

* �@�팟��

```
EL.search = function()
```

* �l�b�g���[�N����EL�@��S�̏����X�V����

```
EL.renewFacilities = function( ip, obj, opc, detail )
```


## ECHONET Lite�U�����


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
EL.sendOPC1( '192.168.2.103', [0x05,0xff,0x01], [0x01,0x35,0x01], 0x61, 0x80, [0x30]);
```








## Author

�_�ސ�H�ȑ�w  �n���H�w��  �z�[���G���N�g���j�N�X�J���w�ȁD

�����@��

Dept. of Home Electronics, Faculty of Creative Engineering, Kanagawa Institute of Technology.

SUGIMURA, Hiroshi


## License

ELSwift is available under the MIT license. See the LICENSE file for more info.


## Log

0.1.0 initial commit

