//
//  FileTests.swift
//  Endgame
//
//  Created by Todd Olsen on 9/23/16.
//
//

import XCTest
@testable import Endgame

class FileTests: XCTestCase {

    func testFileIndex() {
        XCTAssertEqual(File.d.index, 3)
    }

    func testFileFromCharacter() {
        for u in 65...72 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u)!)))
        }
        for u in 97...104 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u)!)))
        }
    }

    func testAllFiles() {
        XCTAssertEqual(File.all, ["a", "b", "c", "d", "e", "f", "g", "h"])
    }

    func testFileTo() {
        XCTAssertEqual(File.a.to(.h), File.all)
        XCTAssertEqual(File.a.to(.a), [File.a])
    }

    func testFileBetween() {
        XCTAssertEqual(File.c.between(.f), [.d, .e])
        XCTAssertEqual(File.c.between(.d), [])
        XCTAssertEqual(File.c.between(.c), [])
    }

    func testFileOpposite() {
        let all = File.all
        let reversed = all.reversed()
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testFileAdvancedBy() {
        XCTAssertEqual(File.d.advanced(by: 2), File.f)
    }

    func testFilePrevious() {
        XCTAssertEqual(File.d.previous()!, File.c)
    }

    func testFileNext() {
        XCTAssertEqual(File.d.next()!, File.e)
    }
}

