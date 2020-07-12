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

AF
   .request("https://api.binance.com/api/v3/ticker/price?symbol=\(pair)")
   .responseJSON(queue: DispatchQueue.global(qos: .utility)) // not in .main queue
{ res in
   let json = try! JSON(data: res.data!)
   let price = Decimal(string: json["price"].string!)!
   let symbol = json["symbol"].string!
   print("\(symbol) : \(price) ")
}

sleep(3) // sleep few seconds

print("done.")

