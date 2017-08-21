//
//  ELSwift.swift
//
//  Created by sugimura on 08/09/2017.
//  Copyright (c) 2017 sugimura. All rights reserved.
//

import Foundation
import CocoaAsyncSocket


class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    let PORT:UInt16 = 3610
    var socket:GCDAsyncUdpSocket!
    
    override init(){
        super.init()
    }
    
    func sendBinary(_ ipaddress: String, _ udpPacket :Data) throws -> Void{
        do{
            socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            try socket.connect(toHost: ipaddress, onPort: PORT)
            socket.send(udpPacket, withTimeout: 2, tag: 0)
            socket.closeAfterSending()
        }catch let error{
            print(error)
            throw error
            // error handling
        }
    }
    
    func send(_ message:String){
        let data = message.data(using: String.Encoding.utf8)
        socket.send(data!, withTimeout: 2, tag: 0)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        // print("didConnectToAddress")
    }
    
    private func udpSocket(_ sock: GCDAsyncUdpSocket?!, didNotConnect error: Error!) {
        // print("didNotConnect \(error)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        // print("didSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        // print("didNotSendDataWithTag")
    }
    
    
    @nonobjc func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: Data!, fromAddress address: Data!, withFilterContext filterContext: Any!) {
        // print("didReceiveData")
        // print(data)
    }
}


class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    
    let IP = "224.0.23.0"
    let PORT:UInt16 = 3610
    var socket:GCDAsyncUdpSocket!
    var rawData = ""
    var cbfunc:((NSNotification) -> Void)?
    
    override init() {
        print("insocket init")
        super.init()
    }
    
    deinit {
        print("insocket deinit")
        socket = nil
    }
    
    func setupConnection() {
        print("insocket setupConnetciton")
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        //initなどでNSNotification登録
        NotificationCenter.default.addObserver( self, selector: #selector(self.update),
                                                name: Notification.Name(rawValue: "ELUDPRecv"), object: nil)
        
        do{
            try socket.bind(toPort: PORT)
            try socket.enableBroadcast(true)
            try socket.joinMulticastGroup(IP)
            try socket.beginReceiving()
        }catch{
            print(error)
            // error handling
        }
    }
    
    
    // 受診したらコールバックでこの関数が呼ばれる
    func udpSocket(_ sock: GCDAsyncUdpSocket!, didReceive data: Data!, fromAddress address: Data!, withFilterContext filterContext: Any!) {
        var host: NSString?
        var port1: UInt16 = 0
        GCDAsyncUdpSocket.getHost(&host, port: &port1, fromAddress: address)

        // print("incoming message: \(data!), From \(host!) : \(port1)")
        // dump(data)
        
        let d = data.map {
            String( format: "%.2hhx", $0)
            }.joined()
        
        // 受信したらメインスレッドに通知を送る
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ELUDPRecv"), object: nil, userInfo:  ["host": host!, "port": port1, "data": d])
    }
    
    // NotificationCenterで受け取った時のアクションを定義，メインスレッドへ
    // Notificationの受け取りがインスタンスじゃないとダメなので，一旦InSocketで受け取っている。
    func update(_ notification: NSNotification)  {
        // print("update > notification:")
        // dump(notification)
        if let f = cbfunc {
            f(notification)
        }
    }
    
    func updateCallback( _ cb:((NSNotification) -> Void)? ){
        print( "UDP updateCallback" )
        cbfunc = cb
    }
    
    
}


//==============================================================================
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


//==============================================================================
enum ELError: Error {
    case BadReceivedData
}


//==============================================================================
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
    
    // user settings
    static var callbackFunc : ((_ rinfo: (address:String, port:UInt16), _ els: EL_STRUCTURE?, _ err: Error?) -> Void)? = {_,_,_ in }
    
    static var EL_obj: [String]!
    static var EL_cls: [String]!
    
    public static var Node_details: Dictionary<String, [UInt8]>!  = [String: [UInt8]]()
    
    /* ex.
     Node_details:	{
     "80": [0x30],
     "82": [0x01, 0x0a, 0x01, 0x00], // EL version, 1.1
     "83": [0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], // identifier
     "8a": [0x00, 0x00, 0x77], // maker code
     "9d": [0x02, 0x80, 0xd5],       // inf map, 1 Byte目は個数
     "9e": [0x00],                 // set map, 1 Byte目は個数
     "9f": [0x09, 0x80, 0x82, 0x83, 0x8a, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7], // get map, 1 Byte目は個数
     "d3": [0x00, 0x00, 0x01],  // 自ノードで保持するインスタンスリストの総数（ノードプロファイル含まない）, user項目
     "d4": [0x00, 0x02],        // 自ノードクラス数, user項目
     "d5": [],    // インスタンスリスト通知, user項目
     "d6": [],    // 自ノードインスタンスリストS, user項目
     "d7": [] }  // 自ノードクラスリストS, user項目
     */
    
  	// ネットワーク内の機器情報リスト(JSON)
    // ELSwift.facilities[ ip:String ][ seoj:String ][ epc:String ] = "edt"
    // public static var facilities:JSON = JSON(["127.0.0.1", ""])
    public static var facilities:Dictionary<String, Dictionary<String, Dictionary<String,String?>? >? > = Dictionary<String, Dictionary<String, Dictionary<String, String?>? >? >()

    
    override init() {
    }
    
    // NotificationCenterで受け取った時のアクションを定義
    public class func update(_ notification: NSNotification)  {
       
        guard let userInfo = notification.userInfo,
            let hostTemp = userInfo["host"] as? String,
            let portTemp = userInfo["port"] as? UInt16,
            let dataTemp = userInfo["data"] as? String else {
                print("No userInfo found in notification")
                return
        }
        ELSwift.returner( bytes: ELSwift.toHexArray( dataTemp ), rinfo: (address: hostTemp, port: portTemp) )
    }
    
    
    // 初期化，バインド mada
    public class func initialize(_ objList: [String], _ callback: ((_ rinfo:(address:String, port:UInt16), _ els: EL_STRUCTURE?, _ err: Error?) -> Void)?, _ ipVer: UInt8? ) throws -> Void {
        do{
            
            // 送信用ソケットの準備
            // 送信する
            ELSwift.outSocket = OutSocket()

            
            // 受信用ソケットの準備
            if( ELSwift.inSocket == nil ) {
                ELSwift.inSocket = InSocket()
                ELSwift.inSocket?.setupConnection()
                ELSwift.inSocket.updateCallback(ELSwift.update)
            }
            EL_obj = objList
            
            let classes = objList.map{
                ELSwift.substr( $0, 0, 4)
            }
            EL_cls = classes
            
            Node_details["80"] = [0x30]
            Node_details["82"] = [0x01, 0x0a, 0x01, 0x00] // EL version, 1.1
            Node_details["83"] = [0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // identifier
            Node_details["8a"] = [0x00, 0x00, 0x77] // maker code
            Node_details["9d"] = [0x02, 0x80, 0xd5]       // inf map, 1 Byte目は個数
            Node_details["9e"] = [0x00]                 // set map, 1 Byte目は個数
            Node_details["9f"] = [0x09, 0x80, 0x82, 0x83, 0x8a, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7] // get map, 1 Byte目は個数
            Node_details["d3"] = [0x00, 0x00, UInt8(EL_obj.count)]  // 自ノードで保持するインスタンスリストの総数（ノードプロファイル含まない）, user項目
            Node_details["d4"] = [0x00, UInt8(EL_cls.count + 1)]        // 自ノードクラス数, user項目, D4はノードプロファイルが入る
            
            var v = EL_obj.map{
                ELSwift.toHexArray( $0 )
            }
            v.insert( [UInt8(objList.count)], at: 0 )
            Node_details["d5"] = v.flatMap{ $0 }    // インスタンスリスト通知, user項目
            Node_details["d6"] = Node_details["d5"]    // 自ノードインスタンスリストS, user項目
            
            v = EL_cls.map{
                ELSwift.toHexArray( $0 )
            }
            v.insert( [UInt8(EL_cls.count)], at: 0 )
            Node_details["d7"] = v.flatMap{ $0 }  // 自ノードクラスリストS, user項目
            
            // 初期化終わったのでノードのINFをだす
            try ELSwift.sendOPC1( EL_Multi, [0x0e,0xf0,0x01], [0x0e,0xf0,0x01], 0x73, 0xd5, Node_details["d5"]! );
            
            ELSwift.callbackFunc = callback
            
        }catch let error {
            throw error
        }
        
    }
    
    
    //////////////////////////////////////////////////////////////////////
    // eldata を見る，表示関係
    //////////////////////////////////////////////////////////////////////
    
    // ELDATA形式
    public static func eldataShow(_ eldata:EL_STRUCTURE ) -> Void{
        print( "EHD: \(eldata.EHD) TID: \(eldata.TID) SEOJ: \(eldata.SEOJ) DEOJ: \(eldata.DEOJ)")
        print( "EDATA: \(eldata.EDATA)" )
    }
    
    // 文字列 ok
    public static func stringShow(_ str: String ) throws -> Void {
        do{
            ELSwift.eldataShow( try ELSwift.parseString(str) )
        }catch let error{
            throw error
        }
    }
    
    // バイトデータ ok
    public static func bytesShow(_ bytes: [UInt8] ) throws -> Void{
        do{
            ELSwift.eldataShow( try ELSwift.parseBytes( bytes ) )
        }catch let error{
            throw error
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////
    // 変換系
    //////////////////////////////////////////////////////////////////////
    
    // Detailだけをparseする，内部で主に使う mada
    public static func parseDetail( opc:UInt8, str:String ) throws -> Dictionary<String, [UInt8]> {
        var ret: Dictionary<String, [UInt8]> = [String: [UInt8]]() // 戻り値用，連想配列
        
        do {
            var now:Int = 0  // 現在のIndex
            var epc:UInt8 = 0
            var pdc:UInt8 = 0
            var edt:[UInt8] = []
            var array:[UInt8] = ELSwift.toHexArray( str )  // edts
            
            // OPCループ
            for _ in (0 ..< opc ) { // i使ってないとかアホなwarning出るけど無視
                // EPC（機能）
                epc = array[now]
                now += 1
                
                // PDC（EDTのバイト数）
                pdc = array[now]
                now += 1
                
                // getの時は pdcが0なのでなにもしない，0でなければ値が入っている
                if( pdc == 0 ) {
                    ret[ ELSwift.toHexString(epc) ] = [0x00] // 本当はnilを入れたい
                } else {
                    // PDCループ
                    for _ in (0..<pdc) { // j使ってないとかアホなwarning出るけど無視
                        // 登録
                        edt += [ array[now] ]
                        now += 1
                    }
                    ret[ ELSwift.toHexString(epc) ] = try ELSwift.toHexArray( ELSwift.bytesToString( edt ) )
                }
                
            }  // opcループ
            
        } catch let error {
            print( "ELSwift.parseDetail(): detail error. opc: \(opc), str: \(str)" )
            throw error
        }
        
        return ret
    }
    
    
    // バイトデータをいれるとEL_STRACTURE形式にする ok
    public static func parseBytes(_ bytes:[UInt8] ) throws -> EL_STRUCTURE {
        do{
            // 最低限のELパケットになってない
            if( bytes.count < 14 ) {
                print( "ELSwift.parseBytes error. bytes is less then 14 bytes. bytes.count is \(bytes.count)" )
                print( bytes )
                throw ELError.BadReceivedData
            }
            
            // 数値だったら文字列にして
            var str:String = ""
            
            for i in (0..<bytes.count) {
                str += ELSwift.toHexString( bytes[i] )
            }
            
            // 文字列にしたので，parseStringで何とかする
            return ( try ELSwift.parseString(str) )
        }catch let error {
            throw error
        }
        
    }
    
    
    // 16進数で表現された文字列をいれるとEL_STRUCTURE形式にする ok
    public static func parseString(_ str: String ) throws -> EL_STRUCTURE {
        let eldata: EL_STRUCTURE = EL_STRUCTURE()
        do{
            eldata.EHD = ELSwift.toHexArray( ELSwift.substr( str, 0, 4 ) )
            eldata.TID = ELSwift.toHexArray( ELSwift.substr( str, 4, 4 ) )
            eldata.SEOJ = ELSwift.toHexArray( ELSwift.substr( str, 8, 6 ) )
            eldata.DEOJ = ELSwift.toHexArray( ELSwift.substr( str, 14, 6 ) )
            eldata.EDATA = ELSwift.toHexArray( ELSwift.substr( str, 20, UInt(str.utf8.count - 20) ) )
            eldata.ESV = ELSwift.toHexArray( ELSwift.substr( str, 20, 2 ) )[0]
            eldata.OPC = ELSwift.toHexArray( ELSwift.substr( str, 22, 2 ) )[0]
            eldata.DETAIL = ELSwift.toHexArray( ELSwift.substr( str, 24, UInt(str.utf8.count - 24) ) )
            eldata.DETAILs = try ELSwift.parseDetail( opc: eldata.OPC, str: ELSwift.substr( str, 24, UInt(str.utf8.count - 24) ) )
        }catch let error{
            throw error
        }
        
        return ( eldata )
    }
    
    
    // 文字列をいれるとELらしい切り方のStringを得る  ok
    public static func getSeparatedString_String(_ str: String ) -> String {
        var ret:String = ""
        
        let a = ELSwift.substr( str, 0, 4 )
        let b = ELSwift.substr( str, 4, 4 )
        let c = ELSwift.substr( str, 8, 6 )
        let d = ELSwift.substr( str, 14, 6 )
        let e = ELSwift.substr( str, 20, 2 )
        let f = ELSwift.substr( str, 22, UInt(str.utf8.count - 20) )
        ret = "\(a) \(b) \(c) \(d) \(e) \(f)"
        
        return ret
    }
    
    
    // 文字列操作が我慢できないので作る（1Byte文字固定）  ok
    public class func substr(_ str:String, _ begginingIndex:UInt, _ count:UInt) -> String {
        let begin = str.index( str.startIndex, offsetBy: Int(begginingIndex))
        let end   = str.index( begin, offsetBy: Int(count))
        let ret   = str.substring(with: begin..<end)
        return( ret )
    }
    
    
    // ELDATAをいれるとELらしい切り方のStringを得る  ok
    public static func getSeparatedString_ELDATA(_ eldata : EL_STRUCTURE ) -> String {
        return ( "\(eldata.EHD) \(eldata.TID) \(eldata.SEOJ) \(eldata.DEOJ) \(eldata.EDATA)" )
    }
    
    
    // EL_STRACTURE形式から配列へ mada
    public static func ELDATA2Array(_ eldata: EL_STRUCTURE ) throws -> [UInt8] {
        let ret = ELSwift.toHexArray( "\(eldata.EHD)\(eldata.TID)\(eldata.SEOJ)\(eldata.DEOJ)\(eldata.EDATA)" )
        return ret
    }
    
    // 1バイトを文字列の16進表現へ（1Byteは必ず2文字にする） ok
    public static func toHexString(_ byte:UInt8 ) -> String {
        return ( String(format: "%02hhx", byte) )
    }
    
    
    
    // 16進表現の文字列を数値のバイト配列へ ok
    public static func toHexArray(_ str: String ) -> [UInt8] {
        var ret: [UInt8] = []
        
        //for i in (0..<str.utf8.count); i += 2 ) {
        // Swift 3.0 ready
        stride(from:0, to: str.utf8.count, by: 2).forEach {
            let i = $0
            
            // var l = ELSwift.substr( str, i, 1 )
            // var r = ELSwift.substr( str, i+1, 1 )
            
            let hexString = ELSwift.substr( str, UInt(i), 2 )
            let hex = Int(hexString, radix: 16) ?? 0
            
            ret += [ UInt8(hex) ]
        }
        
        return ret
    }
    
    
    // バイト配列を文字列にかえる ok
    public static func bytesToString(_ bytes: [UInt8] ) throws -> String{
        var ret:String = ""
        
        for i in (0..<bytes.count) {
            ret += ELSwift.toHexString( bytes[i] )
        }
        return ret
    }
    
    
    //////////////////////////////////////////////////////////////////////
    // 送信
    //////////////////////////////////////////////////////////////////////
    
    // EL送信のベース ok
    public static func sendBase(_ ip:String,_ data:Data ) throws -> Void{
        // 送信する
        do{
            try ELSwift.outSocket.sendBinary( ip, data )
        }catch let error{
            throw error
        }
    }
    
    
    // 配列の時 ok
    public static func sendArray(_ ip:String,_ array:[UInt8] ) throws -> Void{
        do{
            // ELSwift.sendBase( ip, Data(buffer: UnsafeBufferPointer(start: &array, count: array.count)))
            try ELSwift.sendBase( ip, Data(buffer: UnsafeBufferPointer(start: array, count: array.count)))
        }catch let error{
            throw error
        }
    }
    
    
    // ELの非常に典型的なOPC一個でやる
    public static func sendOPC1(_ ip:String, _ seoj:[UInt8], _ deoj:[UInt8], _ esv: UInt8, _ epc: UInt8, _ edt:[UInt8]) throws -> Void{
        do{
            var binArray:[UInt8]
            
            if( esv == 0x62 ) { // get
                binArray = [
                    0x10, 0x81,
                    0x00, 0x00,
                    seoj[0], seoj[1], seoj[2],
                    deoj[0], deoj[1], deoj[2],
                    esv,
                    0x01,
                    epc,
                    0x00]
                
            }else{
                
                binArray = [
                    0x10, 0x81,
                    0x00, 0x00,
                    seoj[0], seoj[1], seoj[2],
                    deoj[0], deoj[1], deoj[2],
                    esv,
                    0x01,
                    epc,
                    UInt8(edt.count)] + edt
                
            }
            
            // データができたので送信する
            try ELSwift.sendArray( ip, binArray )
        }catch let error{
            throw error
        }
    }
    
    
    // ELの非常に典型的な送信3 文字列タイプ ok
    public static func sendString(_ ip:String,_ string:String ) throws -> Void{
        do{
            // 送信する
            let array:[UInt8] = ELSwift.toHexArray(string)
            try ELSwift.sendArray( ip, array )
        }catch let error{
            throw error
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////
    // EL受信
    //////////////////////////////////////////////////////////////////////
    
    // ELの受信データを振り分けるよ，何とかしよう  mada
    public static func returner( bytes:[UInt8], rinfo:((address:String, port:UInt16)) ) -> Void{
        // print( "ELSwift.returner:ELSwift.parseBytes.")
        var ret_els:EL_STRUCTURE
        do{
            ret_els = try ELSwift.parseBytes( bytes )
            
            // キチンとパースできたか？, Non-optionalだから必ずnilではない。
            //if( nil == els ) {
            //    return
            //}
            
            // ヘッダ確認
            if( ret_els.EHD != [0x10, 0x81] ) {
                return
            }
            
            // Node profileに関してきちんと処理する
            if( ret_els.DEOJ == [0x0e, 0xf0, 0x00] || ret_els.DEOJ == [0x0e, 0xf0, 0x01] ) {
                
                switch( ret_els.ESV ) {
                    ////////////////////////////////////////////////////////////////////////////////////
                    // 0x5x
                // エラー受け取ったときの処理
                case UInt8(ELSwift.SETI_SNA):   // 0x50
                    return
                case UInt8(ELSwift.SETC_SNA):   // 0x51
                    return
                case UInt8(ELSwift.GET_SNA):    // 0x52
                    return
                case UInt8(ELSwift.INF_SNA):    // 0x53
                    return
                case UInt8(ELSwift.SETGET_SNA): // 0x5e
                    return
                    
                    
                    ////////////////////////////////////////////////////////////////////////////////////
                // 0x6x
                case UInt8(ELSwift.SETI): // "60
                    break
                    
                case UInt8(ELSwift.SETC): // "61"
                    break
                    
                case UInt8(ELSwift.GET): // 0x62
                    // print( "ELSwift.returner: get prop. of Node profile.")
                    for (key, _) in ret_els.DETAILs {
                        let epc = key
                        if( ELSwift.Node_details[epc] != nil ) { // 持ってるEPCのとき
                            try ELSwift.sendOPC1( rinfo.address, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x72, ELSwift.toHexArray(epc)[0], ELSwift.Node_details[epc]! )
                        } else { // 持っていないEPCのとき, SNA
                            try ELSwift.sendOPC1( rinfo.address, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x52, ELSwift.toHexArray(epc)[0], [0x00] )
                        }
                    }
                    break
                    
                case UInt8(ELSwift.INF_REQ): // 0x63
                    if let d5 = ret_els.DETAILs["d5"] {
                        if( d5 == [0x00] ) {
                            // print( "ELSwift.returner: Ver1.0 INF_REQ.")
                            if( ELSwift.isIPv6 ) {
                                try ELSwift.sendOPC1( ELSwift.EL_Multi6, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x73, 0xd5, ELSwift.Node_details["d5"]! )
                            }else{
                                try ELSwift.sendOPC1( ELSwift.EL_Multi, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x73, 0xd5, ELSwift.Node_details["d5"]! )
                            }
                        }
                    }
                    break
                    
                case UInt8(ELSwift.SETGET): // "6e"
                    break
                    
                    ////////////////////////////////////////////////////////////////////////////////////
                // 0x7x
                case UInt8(ELSwift.SET_RES): // 71
                    // SetCに対する返答のSetResは，EDT 0x00でOKの意味を受け取ることとなる．ゆえにその詳細な値をGetする必要がある
                    if( ret_els.DETAIL[0] == 0x00 ) {
                        let msg = try "1081000005ff01\(ELSwift.bytesToString( ret_els.SEOJ ))6201\(ELSwift.toHexString(ret_els.DETAIL[0]))00"
                        try ELSwift.sendString( rinfo.address, msg )
                    }
                    break
                    
                case UInt8(ELSwift.GET_RES): // 72
                    // V1.1
                    // d6のEDT表現がとても特殊，EDT1バイト目がインスタンス数になっている
                    if( ret_els.SEOJ[0...1] == [0x0e, 0xf0] && ret_els.DETAILs["d6"] != nil ) {
                        // print( "ELSwift.returner: get object list! PropertyMap req V1.0.")
                        // 自ノードインスタンスリストSに書いてあるオブジェクトのプロパティマップをもらう
                        if let array = ret_els.DETAILs["d6"] {
                            var instNum = array[0]
                            while( 0 < instNum ) {
                                let begin:Int = ( Int(instNum) - 1) * 3 + 1
                                let end:Int   = ( Int(instNum) - 1) * 3 + 4
                                let tempEOJ:[UInt8] = Array( array[ begin..<end ] )
                                try ELSwift.getPropertyMaps( ip: rinfo.address, eoj: tempEOJ )
                                instNum -= 1
                            }
                        }
                    }else if( ret_els.DETAILs["9f"] != nil ) {
                        if let array = ret_els.DETAILs["9f"] {
                            if( array.count < 16 ) { // プロパティマップ16バイト未満は記述形式１
                                let num = array[0]
                                for i:UInt8 in (0..<num ) {
                                    // このとき9fをまた取りに行くと無限ループなのでやめる
                                    if( array[ Int(i+1) ] != 0x9f ) {
                                        try ELSwift.sendOPC1( rinfo.address, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x62, array[ Int(i+1) ], [0x00] )
                                    }
                                }
                            } else {
                                // 16バイト以上なので記述形式2，EPCのarrayを作り直したら，あと同じ
                                if let details9f = ret_els.DETAILs["9f"] {
                                    let array2:[UInt8] = try ELSwift.parseMapForm2( ELSwift.bytesToString( details9f ) )
                                    let num = array2[0]
                                    for i in (0..<num ) {
                                        // このとき9fをまた取りに行くと無限ループなのでやめる
                                        if( array2[Int(i+1)] != 0x9f ) {
                                            try ELSwift.sendOPC1( rinfo.address, [0x0e, 0xf0, 0x01], ret_els.SEOJ, 0x62, array2[Int(i+1)], [0x00] )
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    break
                    
                case UInt8(ELSwift.INF):  // 0x73
                    // V1.0 オブジェクトリストをもらったらそのオブジェクトのPropertyMapをもらいに行く, デバイスが後で起動した
                    if( ret_els.DETAILs["d5"] != nil ) {
                        // ノードプロファイルオブジェクトのプロパティマップをもらう
                        try ELSwift.getPropertyMaps( ip:rinfo.address, eoj:[0x0e, 0xf0, 0x00] )
                    }
                    break
                    
                case UInt8(ELSwift.INFC): // "74"
                    // V1.0 オブジェクトリストをもらったらそのオブジェクトのPropertyMapをもらいに行く
                    if( ret_els.DETAILs["d5"] != nil ) {
                        // ノードプロファイルオブジェクトのプロパティマップをもらう
                        try ELSwift.getPropertyMaps( ip:rinfo.address, eoj:[0x0e, 0xf0, 0x00] )
                        
                        // print( "ELSwift.returner: get object list! PropertyMap req.")
                        if let array = ret_els.DETAILs["d5"] {
                            var instNum = array[0]
                            while( 0 < instNum ) {
                                let begin:Int = Int((instNum - 1) * 3 + 1 )
                                let end:Int = Int((instNum - 1) * 3 + 4)
                                let tempEOJ:[UInt8] = Array( array[ begin...end ] )
                                try ELSwift.getPropertyMaps( ip: rinfo.address, eoj: tempEOJ )
                                instNum -= 1
                            }
                            
                        }
                    }
                    break
                    
                case UInt8(ELSwift.INFC_RES): // "7a"
                    break
                case UInt8(ELSwift.SETGET_RES): // "7e"
                    break
                    
                default:
                    break
                }
            }
            
            // 受信状態から機器情報修正, GETとINFREQは除く
            if( ret_els.ESV != 0x62 && ret_els.ESV != 0x63 ) {
                try ELSwift.renewFacilities( ip: rinfo.address, els: ret_els )
            }
            
            // dump( ELSwift.facilities )
            
            // 機器オブジェクトに関してはユーザー関数に任す
            if let f = ELSwift.callbackFunc {
                f( (rinfo.address, rinfo.port), ret_els, nil)
            }else{
                print("callbackFunc is null")
            }
           
        } catch let error {
            if let f = ELSwift.callbackFunc {
                f( (rinfo.address, rinfo.port), nil, error)
            }else{
                print("callbackFunc is null")
            }
        }
        
    }
    
    
    // ネットワーク内のEL機器全体情報を更新する，受信したら勝手に実行される mada, JSONの取り扱いが難しいとDictionaryで定義しないとダメ
    public static func renewFacilities( ip:String, els: EL_STRUCTURE ) throws -> Void {
        // print("== renewFacilities")
        
        do {
            //var epcList = ELSwift.parseDetail( opc: els.OPC, str: els.DETAIL )
            // Swift版ではすでにparseされたものとして引数になっている，ただし格納が[UInt8]
            let epcList = els.DETAILs
            let seoj = try ELSwift.bytesToString( els.SEOJ )

            // 新規IP
            if( ELSwift.facilities[ ip ] == nil ) { //見つからない
                ELSwift.facilities[ ip ] = [String: [String:String]]()
            }
            
            // 新規obj
            if( ELSwift.facilities[ ip ]??[ seoj ] == nil ) {
                ELSwift.facilities[ ip ]??[ seoj ] = [String:String]()
                // 新規オブジェクトのとき，プロパティリストもらおう
                // ELSwift.getPropertyMaps( ip, ELSwift.toHexArray(els.SEOJ) )
                try ELSwift.getPropertyMaps( ip: ip, eoj: els.SEOJ )
            }
            
            for (epc,value) in epcList {
                // 新規epc
                if( ELSwift.facilities[ ip ]??[ seoj ]??[ epc ] == nil ) {
                    ELSwift.facilities[ ip ]??[ seoj ]??[ epc ] = ""
                }
                
                ELSwift.facilities[ ip ]??[ seoj ]??[ epc ] = try ELSwift.bytesToString( value )
            }
 
        }catch let error {
            print("ELSwift.renewFacilities error.")
            // dump(e)
            throw error
        }
        
        // print("Success renewFacilities")
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////
    // EL，上位の通信手続き
    //////////////////////////////////////////////////////////////////////
    
    // 機器検索 mada
    public static func search() -> Void {
        
        do{
            if( ELSwift.isIPv6 ) {
                try ELSwift.sendOPC1( ELSwift.EL_Multi6, [0x0e,0xf0, 0x01], [0x0e, 0xf0, 0x00],  0x62, 0xD6, [0x00] )  // すべてノードに対して，すべてのEOJをGetする
                
            }else{
                try ELSwift.sendOPC1( ELSwift.EL_Multi, [0x0e,0xf0, 0x01], [0x0e, 0xf0, 0x00], 0x62, 0xD6, [0x00] )  // すべてノードに対して，すべてのEOJをGetする
            }
        }catch let error{
            print("Error: ELSwift.search.")
            print(error)
        }
    }
    
    
    // プロパティマップをすべて取得する ok
    public static func getPropertyMaps ( ip:String, eoj:[UInt8] ) throws -> Void{
        do{
            try ELSwift.sendOPC1( ip, [0x0e,0xf0,0x01], eoj, 0x62, 0x9D, [0x00] )  // INF prop
            try ELSwift.sendOPC1( ip, [0x0e,0xf0,0x01], eoj, 0x62, 0x9E, [0x00] )  // SET prop
            try ELSwift.sendOPC1( ip, [0x0e,0xf0,0x01], eoj, 0x62, 0x9F, [0x00] )  // GET prop
        }catch let error{
            throw error
        }
    }
    
    
    // parse Propaty Map Form 2
    // 16以上のプロパティ数の時，記述形式2，出力はForm1にすること
    public static func parseMapForm2(_ bitstr:String ) -> [UInt8] {
        
        var ret: [UInt8] = []
        var val:UInt = 0x80
        var array:[UInt8] = ELSwift.toHexArray( bitstr )
        
        // bit loop
        for bit:UInt8 in (0..<8 ) {
            // byte loop
            for byt in (1..<17) {
                if(  0x01  ==  ((array[byt] >> bit) & 0x01)   ) {
                    // print("array[byt] \(array[byt]), byt \(byt), bit \(bit), val \(val)")
                    ret.append( UInt8(val) )
                }
                val += 1
            }
        }
        
        ret = [UInt8(ret.count)] + ret
        
        return ret
    }
    
    
}

