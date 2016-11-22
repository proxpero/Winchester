//
//  ECO Tests.swift
//  Endgame
//
//  Created by Todd Olsen on 9/25/16.
//
//

import XCTest
@testable import Endgame

class ECO_Tests: XCTestCase {

    func testGameEco() {
        let game = Game()
        try! game.execute(sanMoves: "e4 c5 Nf3 g6 d4 Bg7")
        XCTAssertNotNil(game.eco)
        XCTAssertEqual(game.eco!.code, ECO.Code.b27)
        XCTAssertEqual(game.eco!.code.rawValue, "B27")

        let expectedName = "Hyperaccelerated Pterodactyl, Sicilian"
        let actualName = game.eco!.name
        XCTAssertEqual(expectedName, actualName, "Expected name was \(expectedName) but the actual name was \(actualName)")
    }



}
