//
//  OutcomeTests.swift
//  Endgame
//
//  Created by Todd Olsen on 9/23/16.
//
//

import XCTest
@testable import Endgame

class OutcomeTests: XCTestCase {

    static let ww = "1-0"
    static let bw = "0-1"
    static let dr = "1/2-1/2"
    let outcomes = [Outcome(ww), Outcome(bw), Outcome(dr)]

    func testInitialization() {
        for outcome in outcomes {
            XCTAssertNotNil(outcome, "Could not create outcome: \(outcome)")
        }
    }

    func testWinningColor() {
        let results: [Color?] = [Color.white, Color.black, nil]
        for (outcome, color) in zip(outcomes, results) {
            XCTAssertEqual(outcome?.winningColor, color)
        }
    }

    func testValue() {
        let whiteResults = [1.0, 0.0, 0.5]
        let blackResults = [0.0, 1.0, 0.5]
        for (outcome, value) in zip(outcomes, whiteResults) {
            XCTAssertEqual(outcome?.value(for: .white), value)
        }
        for (outcome, value) in zip(outcomes, blackResults) {
            XCTAssertEqual(outcome?.value(for: .black), value)
        }
    }

    func testDescription() {
        let results = [OutcomeTests.ww, OutcomeTests.bw, OutcomeTests.dr]
        for (outcome, desc) in zip(outcomes, results) {
            XCTAssertEqual(outcome?.description, desc)
        }
    }
    
}

