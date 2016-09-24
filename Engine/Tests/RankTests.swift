//
//  RankTests.swift
//  Engine
//
//  Created by Todd Olsen on 9/23/16.
//
//

import XCTest
@testable import Engine

class RankTests: XCTestCase {
    
    func testRankIndex() {
        XCTAssertEqual(Rank.five.index, 4)
    }

    func testRankFromNumber() {
        for n in 1...8 {
            XCTAssertNotNil(Rank(n))
        }
    }

    func testAllRanks() {
        XCTAssertEqual(Rank.all, [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func testRankTo() {
        XCTAssertEqual(Rank.one.to(.eight), Rank.all)
        XCTAssertEqual(Rank.one.to(.one), [Rank.one])
    }

    func testRankBetween() {
        XCTAssertEqual(Rank.two.between(.five), [.three, .four])
        XCTAssertEqual(Rank.two.between(.three), [])
        XCTAssertEqual(Rank.two.between(.two), [])
    }

    func testRankOpposite() {
        let all = Rank.all
        let reversed = all.reversed()
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testRankAdvancedBy() {
        XCTAssertEqual(Rank.four.advanced(by: 3)!, Rank.seven)
        XCTAssertEqual(Rank.four.advanced(by: 3, for: .black)!, Rank.one)
    }

    func testRankPrevious() {
        XCTAssertEqual(Rank.four.previous()!, Rank.three)
    }
    
    func testRankNext() {
        XCTAssertEqual(Rank.four.next()!, Rank.five)
    }
    
}
