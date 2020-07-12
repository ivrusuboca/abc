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
   
   let json = try! JSON(data: res.data!)
   let price = Decimal(string: json["price"].string!)!
   let symbol = json["symbol"].string!
   print("\(symbol) : \(price) ")
   
   group.leave()
}

group.wait()

print("done.")

