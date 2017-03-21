//: [Previous](@previous)

import Foundation
import Endgame

let fileA = File.a

let notFileA = ~fileA
let fileAFileB = File.a | File.b
let notAB = ~fileAFileB

let not = ~(File.a | File.b)

//: [Next](@next)
