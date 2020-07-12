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
         print("failure : invalid JSON format for response : \(res.value) ")
         return
      }
      guard
         let symbol = json["symbol"].string,
         let p = json["price"].string,
         let price = Decimal(string: p) else
      {
         if let msg = json["msg"].string, let code = json["code"].int
         {
            print("failure : code \(code) w/ message : \(msg) ")
         }else
         {
            print("failure : \(json) ")
         }
         return
      }
      print("\(symbol) : \(p) ")
   case .failure(let err):
      print("failure : \(res.value) w/ error : \(err) ")
   }
}

group.wait()

print("done.")

