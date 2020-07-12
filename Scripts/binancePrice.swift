#!/usr/bin/swift sh

import Foundation

guard CommandLine.arguments.count > 1 else
{
   let scriptName = CommandLine.arguments[0].components(separatedBy: "/").last!
   print("usage   : \(scriptName).swift <pair> ")
   print("example : \(scriptName).swift BTCUSDT ")
   exit(0)
}

let pair = CommandLine.arguments[1]
print("getting price for pair : \(pair) ... ")

