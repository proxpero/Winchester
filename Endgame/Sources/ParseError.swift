//
//  ParseError.swift
//  Endgame
//
//  Created by Todd Olsen on 3/20/17.
//
//

enum ParseError: Error {
    case invalidFEN(String)
    case invalidMove(String)
    case invalidEPD(String)
}
