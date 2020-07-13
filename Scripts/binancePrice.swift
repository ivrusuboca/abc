#!/usr/bin/swift sh

import Foundation

import Alamofire // @Alamofire ~> 5.2
import SwiftyJSON // @SwiftyJSON ~> 5.0.0

guard CommandLine.arguments.count > 1 else
{
   let scriptName = CommandLine.arguments[0].components(separatedBy: "/").last!
   print("usage   : \(scriptName).swift <pair> ")
   print("example : \(scriptName).swift BTCUSDT ")
   exit(0)
}

let pair = CommandLine.arguments[1]
print("getting price for pair : \(pair) ... ")

enum Failure : Error
{
   case withMessage(msg: String)
   case withCode(code:Int, msg: String)
}

func getPrice(ofPair pair:String) throws -> (String, Decimal)
{

   var result:(String, Decimal)?
   var failure:Failure?
   
   let group = DispatchGroup()
   group.enter()

   AF
      .request("https://api.binance.com/api/v3/ticker/price?symbol=\(pair)")
      { req in req.timeoutInterval = 2 }                        // timeout set to 2 seconds
      .cURLDescription { desc in print("curl: \(desc) ") }      // for debugging purposes
      .responseJSON(queue: DispatchQueue.global(qos: .utility)) // not in .main queue
   { res in
      
      defer
      {
         group.leave() // whatever happens next, this will be called
      }
      
      switch res.result
      {
      case .success:
         guard let data = res.data, let json = try? JSON(data: data) else
         {
            failure = Failure.withMessage(msg: "invalid JSON format for response : \(res.value)")
            return
         }
         guard
            let symbol = json["symbol"].string,
            let p = json["price"].string,
            let price = Decimal(string: p) else
         {
            if let msg = json["msg"].string, let code = json["code"].int
            {
               failure = Failure.withCode(code: code, msg: msg)
            }else
            {
               failure = Failure.withMessage(msg: "\(json)")
            }
            return
         }
         result = (symbol, price)
      case .failure(let err):
         failure = Failure.withMessage(msg: "\(err)")
      }
   }
   group.wait()

   assert(result != nil || failure != nil)
   
   if let r = result
   {
      return r
   }
   throw failure!
   
} // func

do
{
   let (p, price) = try getPrice(ofPair: pair)
   print("\(p) : \(price) ")
}catch Failure.withMessage(let msg) {
   print("failure with message : \(msg)")
}catch Failure.withCode(let code, let msg) {
   print("failure with code : \(code) and message : \(msg)")
}catch {
   print("unexpected failure : \(error) ")
}

print("done.")

