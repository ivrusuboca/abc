
import Foundation

import Alamofire
import SwiftyJSON

public enum Failure : Error, Equatable // Equatable needed for XCTAssertEqual
{
   case withMessage(msg: String)
   case withCode(code:Int, msg: String)
}

public func getPrice(ofPair pair:String) throws -> (String, Decimal)
{

   var result:(String, Decimal)?
   var failure:Failure?
   
   let semaphore = DispatchSemaphore(value: 0)

   AF
      .request("https://api.binance.com/api/v3/ticker/price?symbol=\(pair)")
      { req in req.timeoutInterval = 2 }                        // timeout set to 2 seconds
      .cURLDescription { desc in print("curl: \(desc) ") }      // for debugging purposes
      .responseJSON(queue: DispatchQueue.global(qos: .utility)) // not in .main queue
   { res in
      
      defer
      {
         semaphore.signal() // whatever happens next, this will be called
      }
      
      switch res.result
      {
      case .success:
         guard let data = res.data, let json = try? JSON(data: data) else
         {
            failure = Failure.withMessage(msg: "invalid JSON format for response : \(String(describing: res.value))")
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
   let ret = semaphore.wait(timeout: DispatchTime.distantFuture)
   if ret != .success
   {
      failure = Failure.withMessage(msg: "Semaphore error : \(ret)")
   }

   assert(result != nil || failure != nil)
   
   if let r = result
   {
      return r
   }
   throw failure!
   
} // func

