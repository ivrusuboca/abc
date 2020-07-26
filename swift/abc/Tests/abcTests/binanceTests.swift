import XCTest
@testable import abc

final class binanceTests: XCTestCase
{
   
    func testGetPriceValid()
    {
      do
      {
         let (p, price) = try getPrice(ofPair: "BTCUSDT")
         XCTAssertEqual(p, "BTCUSDT", "Wrong pair returned. ")
         XCTAssertGreaterThanOrEqual(price, 0, "Negative price. ")
      }catch Failure.withMessage(let msg) {
         XCTFail("Test with valid pair failed due to : \(msg) ")
      }catch Failure.withCode(let code, let msg) {
         XCTFail("Test with valid pair failed due to : \(msg) w/ code : \(code) ")
      }catch {
         XCTFail("Test with valid pair failed due to : \(error) ")
      }
    }
   
    func testGetPriceInvalid()
    {
      
      XCTAssertThrowsError(try getPrice(ofPair: "BTCUSDTX"), "Failed to throw exception. ")
      {
         error in
         XCTAssertEqual(error as? Failure, Failure.withCode(code: -1121, msg: "Invalid symbol."))
      }
    }

   static var allTests = [
       ("testGetPriceValid", testGetPriceValid),
       ("testGetPriceInvalid", testGetPriceInvalid)
   ]

}
