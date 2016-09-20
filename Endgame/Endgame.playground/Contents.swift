
import CoreGraphics
import SpriteKit
import Engine

func index(for row: Int) -> Int {
    return 2*row/3-1

//    var k = 4*(row-1)-(-1*row)+1

    var n = row
//    n = 8*n - 6
//    n = n / 6
//    n = n + 1
//    n = 4*n / 6
//    n = n / 2

//    n = n - 1


    n = 2*n/3 - 1

    return n

}

let rows = [2, 3, 5, 6, 8, 9, 11, 12, 14, 15, 17, 18, 20, 21]
//let test = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

let result = rows.map(index)
if result == Array<Int>(0...13) {
    print("SUCCESS!!!")
} else {
    print("FAILURE")
}
