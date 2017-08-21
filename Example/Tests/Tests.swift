// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import ELSwift

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("ELSwift Library") {

            it( "substr" ) {
                expect( ELSwift.substr("1234567890", 2, 3) ) == "345"
            }
            
            
            //////////////////////////////////////////////////////////////////////
            // 変換系
            //////////////////////////////////////////////////////////////////////
            
            // Detailだけをparseする，内部で主に使う mada
            // it( "parseDetail" ) {
            //    expect( NSDictionary( dictionary: try ELSwift.parseDetail( opc: 0x01, str: "800130" ) ).isEqual( ["80", [0x30]] ) ) == true
            //}

/*
            // バイトデータをいれるとEL_STRACTURE形式にする ok
            it("parseBytes") {
                var els:EL_STRUCTURE  = EL_STRUCTURE(
                    EHD :  [0x10, 0x81],
                    TID :  [0x00, 0x00],
                    SEOJ : [0x05, 0xff, 0x01],
                    DEOJ : [0x02, 0x90, 0x01],
                    EDATA : [0x60, 0x01, 0x80, 0x01, 0x30],
                    ESV : 0x60,
                    OPC : 0x01,
                    DETAIL : [0x80, 0x01, 0x30],
                    DETAILs : ["80": [0x30]] )

                let t:[UInt8] = [0x10, 0x81, 0x00, 0x00, 0x05, 0xff, 0x01, 0x02, 0x90, 0x01, 0x60, 0x01, 0x80, 0x01, 0x30]
                expect( ELSwift.parseBytes( t ) ) == els
            }
 */
            
            /*
             // 16進数で表現された文字列をいれるとEL_STRUCTURE形式にする ok
            public static func parseString(_ str: String ) throws -> EL_STRUCTURE
            
            
            // 文字列をいれるとELらしい切り方のStringを得る  ok
            public static func getSeparatedString_String(_ str: String ) -> String
            
            
            // 文字列操作が我慢できないので作る（1Byte文字固定）  ok
            public class func substr(_ str:String, _ begginingIndex:UInt8, _ count:UInt8) -> String
            
            
            // ELDATAをいれるとELらしい切り方のStringを得る  ok
            public static func getSeparatedString_ELDATA(_ eldata : EL_STRUCTURE ) -> String
            
            
            // EL_STRACTURE形式から配列へ mada
            public static func ELDATA2Array(_ eldata: EL_STRUCTURE ) throws -> [UInt8]
            
            // 1バイトを文字列の16進表現へ（1Byteは必ず2文字にする） ok
            public static func toHexString(_ byte:UInt8 ) -> String
            
            // 16進表現の文字列を数値のバイト配列へ ok
            public static func toHexArray(_ str: String ) -> [UInt8]
            
            
            // バイト配列を文字列にかえる ok
            public static func bytesToString(_ bytes: [UInt8] ) throws -> String
            
            
            
            //////////////////////////////////////////////////////////////////////
            // 送信
            //////////////////////////////////////////////////////////////////////
            
            // EL送信のベース ok
            public static func sendBase(_ ip:String,_ data:Data ) throws -> Void{
                
                // 配列の時 ok
                public static func sendArray(_ ip:String,_ array:[UInt8] ) throws -> Void{
                    
                    // ELの非常に典型的なOPC一個でやる
                    public static func sendOPC1(_ ip:String, _ seoj:[UInt8], _ deoj:[UInt8], _ esv: UInt8, _ epc: UInt8, _ edt:[UInt8]) throws -> Void
                    
                    
                    // ELの非常に典型的な送信3 文字列タイプ ok
                    public static func sendString(_ ip:String,_ string:String ) throws -> Void{
                        
*/
                        //////////////////////////////////////////////////////////////////////
                        // EL受信
                        //////////////////////////////////////////////////////////////////////
                        
                        //////////////////////////////////////////////////////////////////////
                        // EL，上位の通信手続き
                        //////////////////////////////////////////////////////////////////////
                        
                        // parse Propaty Map Form 2
                        // 16以上のプロパティ数の時，記述形式2，出力はForm1にすること
            it( "parseMapForm2" ) {
                let array = ELSwift.parseMapForm2("1041414100004000604100410000020202" )
                dump(array)
                expect( array ) == [ 16,  128,  129,  130,  136,  138,  157,  158,  159,  215,  224,  225,  226,  229,  231,  232,  234 ]
            }

        }
    }
}
