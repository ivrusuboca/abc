#!/usr/bin/swift sh

import Foundation

import abc // ../../abc

guard CommandLine.arguments.count > 1 else
{
   let scriptName = CommandLine.arguments[0].components(separatedBy: "/").last!
   print("usage   : \(scriptName).swift <pair> ")
   print("example : \(scriptName).swift BTCUSDT ")
   exit(0)
}

let pair = CommandLine.arguments[1]
print("getting price for pair : \(pair) ... ")

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

