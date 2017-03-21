//
//  EPD+Parsing.swift
//  Endgame
//
//  Created by Todd Olsen on 3/20/17.
//
//

extension EPD {
    /// An error thrown by `EPD.init(parse:)`.
    public enum ParseError: Error {
        case emptyString
        case invalidCode(String)
        //         TODO: Error Handling
    }

    
}
