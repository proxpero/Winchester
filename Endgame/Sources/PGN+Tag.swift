//
//  PGN+Tag.swift
//  Endgame
//
//  Created by Todd Olsen on 11/2/16.
//
//

import Foundation

extension PGN {

    public enum Tag: String, CustomStringConvertible {

        // MARK: Cases

        /// Event tag.
        case event = "Event"

        /// Site tag.
        case site = "Site"

        /// Date tag.
        case date = "Date"

        /// Round tag.
        case round = "Round"

        /// White tag.
        case white = "White"

        /// Black tag.
        case black = "Black"

        /// Result tag.
        case result = "Result"

        /// Annotator tag.
        case annotator = "Annotator"

        /// Ply (moves) count tag.
        case plyCount = "PlyCount"

        /// TimeControl tag.
        case timeControl = "TimeControl"

        /// Time tag.
        case time = "Time"

        /// Termination tag.
        case termination = "Termination"

        /// Playing mode tag.
        case mode = "Mode"

        /// FEN tag.
        case fen = "FEN"

        /// White player's title tag.
        case whiteTitle = "WhiteTitle"

        /// Black player's title tag.
        case blackTitle = "BlackTitle"

        /// White player's elo rating tag.
        case whiteElo = "WhiteElo"

        /// Black player's elo rating tag.
        case blackElo = "BlackElo"

        /// White player's United States Chess Federation rating tag.
        case whiteUSCF = "WhiteUSCF"

        /// Black player's United States Chess Federation rating tag.
        case blackUSCF = "BlackUSCF"

        /// White player's network or email address tag.
        case whiteNA = "WhiteNA"

        /// Black player's network or email address tag.
        case blackNA = "BlackNA"

        /// White player's type tag; either human or program.
        case whiteType = "WhiteType"

        /// Black player's type tag; either human or program.
        case blackType = "BlackType"

        /// The starting date tag of the event.
        case eventDate = "EventDate"

        /// Tag for the name of the sponsor of the event.
        case eventSponsor = "EventSponsor"

        /// The playing section tag of a tournament.
        case section = "Section"

        /// Tag for the stage of a multistage event.
        case stage = "Stage"

        /// The board number tag in a team event or in a simultaneous exhibition.
        case board = "Board"

        /// The traditional opening name tag.
        case opening = "Opening"

        /// Tag used to further refine the opening tag.
        case variation = "Variation"

        /// Used to further refine the variation tag.
        case subVariation = "SubVariation"

        /// Tag used for an opening designation from the five volume *Encyclopedia of Chess Openings*.
        case eco = "ECO"

        /// Tag used for an opening designation from the *New in Chess* database.
        case nic = "NIC"

        /// Tag similar to the Time tag but given according to the Universal Coordinated Time standard.
        case utcTime = "UTCTime"

        /// Tag similar to the Date tag but given according to the Universal Coordinated Time standard.
        case utcDate = "UTCDate"

        /// Tag for the "set-up" status of the game.
        case setUp = "SetUp"

        // MARK: CustomStringConvertible Protocol Conformance

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

        public static var roster: [(tag: Tag, default: String)] {
            return [
                (.event, "?"),
                (.site, "?"),
                (.date, "????.??.??"),
                (.round, "?"),
                (.white, "?"),
                (.black, "?"),
                (.result, "?")]
        }
        
    }

}
