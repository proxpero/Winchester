//
//  EPD.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

import Foundation

/// A representation of Extended Position Description data.
public struct EPD {

    public enum Opcode: CustomStringConvertible {

        /// Analysis count: depth searched.
        case acd(Int)

        /// Analysis count: nodes.
        case acn(Int)

        /// Analysis count: search time in seconds.
        case acs(Int)

        /// Best moves: move(s) judged best for some reason.
        case bm([String])

        /// Centipawn evaluation: evaluation in hundredths of a pawn from the perspective
        /// of the side to move -- note this differs from the Analysis window which shows
        /// evaluations in pawns from White's perspective.
        case ce(Int)

        /// Direct move fullmove count
        case dm(Int)

        /// Comment 0
        case c0(String)

        /// Comment 1
        case c1(String)

        /// Comment 2
        case c2(String)

        /// Comment 3
        case c3(String)

        /// Comment 4
        case c4(String)

        /// Comment 5
        case c5(String)

        /// Comment 6
        case c6(String)

        /// Comment 7
        case c7(String)

        /// Comment 8
        case c8(String)

        /// Comment 9
        case c9(String)

        /// ECO system opening code.
        case eco(String)

        /// Unique Identification for this position.
        case id(String)

        /// New In Chess system opening code.
        case nic(String)

        /// Predicted move: the first move of the PV.
        case pm(Square)

        /// Predicted variation: the line of best play.
        case pv([Square])

        /// Repetition count.
        case rc(Int)

        /// A textual representation of `self`.
        public var description: String {

            switch self {
            case .acd(let d):
                return "Analysis Count Depth: \(d)"

            case .acn(let n):
                return "Analysis Count Nodes: \(n)"

            case .acs(let s):
                return "Analysis Count (seconds): \(s)"

            case .bm(let m):
                return "Best move: \(m)"

            case .ce(let n):
                return "Centipawn Evaluation: \(n)"

            case .dm(let count):
                return "Direct mate fullmove count: \(count)"

            case .c0(let c0):
                return "Comment 0: \(c0)"

            case .c1(let c1):
                return "Comment 1: \(c1)"

            case .c2(let c2):
                return "Comment 2: \(c2)"

            case .c3(let c3):
                return "Comment 3: \(c3)"

            case .c4(let c4):
                return "Comment 4: \(c4)"

            case .c5(let c5):
                return "Comment 5: \(c5)"

            case .c6(let c6):
                return "Comment 6: \(c6)"

            case .c7(let c7):
                return "Comment 7: \(c7)"

            case .c8(let c8):
                return "Comment 8: \(c8)"

            case .c9(let c9):
                return "Comment 9: \(c9)"

            case .eco(let eco):
                return "ECO system opening code: \(eco)"

            case .id(let s):
                return "Unique Identification for this position: \(s)"

            case .nic(let s):
                return "New In Chess system opening code: \(s)"

            case .pm(let m):
                return "Predicted move (the first move of the Predicted Variation): \(m)"

            case .pv(let ms):
                return "Predicted variation (the line of best play): \(ms)"

            case .rc(let count):
                return "Repetition count: \(count)"
            }
        }

        public init?(tag: String, value: [String]) {

            switch tag {

//            case "acd":
//                guard value.count == 1, let d = Int(value[0]) else { return nil }
//                self = .acd(d)
//
//            case "acn":
//                guard value.count == 1, let t = Int(value[0]) else { return nil }
//                self = .acn(t)
//
//            case "acs":
//                guard value.count == 1, let s = Int(value[0]) else { return nil }
//                self = .acs(s)

            case "bm":
                self = .bm(value)

            case "ce":
                guard value.count == 1, let x = value.first else { return nil }
                if let num = Int(x) {
                    self = .ce(num)
                } else if x == "+M1" {
                    self = .ce(Int.max)
                } else {
                    self = .ce(0)
                }

//            case "c0":
//                guard value.count == 1 else { return nil }
//                self = .c0(value[0])
//
//            case "c1":
//                guard value.count == 1 else { return nil }
//                self = .c1(value[0])
//
//            case "c2":
//                guard value.count == 1 else { return nil }
//                self = .c2(value[0])
//
//            case "c3":
//                guard value.count == 1 else { return nil }
//                self = .c3(value[0])
//
//            case "c4":
//                guard value.count == 1 else { return nil }
//                self = .c4(value[0])
//
//            case "c5":
//                guard value.count == 1 else { return nil }
//                self = .c5(value[0])
//
//            case "c6":
//                guard value.count == 1 else { return nil }
//                self = .c6(value[0])
//
//            case "c7":
//                guard value.count == 1 else { return nil }
//                self = .c7(value[0])
//
//            case "c8":
//                guard value.count == 1 else { return nil }
//                self = .c8(value[0])
//
//            case "c9":
//                guard value.count == 1 else { return nil }
//                self = .c9(value[0])
//
//            case "eco":
//                guard value.count == 1 else { return nil }
//                self = .c0(value[0])
//
            case "id":
                guard value.count == 1, let first = value.first else { return nil }
                self = .id(first)
//
//            case "nic":
//                guard value.count == 1 else { return nil }
//                self = .nic(value.first!)
//
//            case "pm":
//                guard value.count == 1 else { return nil }
//                let move = value.flatMap { Square($0) }.first!
//                self = .pm(move)

            case "pv":
                let moves = value.flatMap { Square($0) }
                self = .pv(moves)

            default:
                return nil
            }
        }
    }

    /// An error thrown by `EPD.init(parse:)`.
    public enum ParseError: Error {
        case emptyString
//         TODO: Error Handling
    }

    /// The position for `self`.
    public var position: Position

    /// The opcodes for `self`.
    public var opcodes: [Opcode]

    /// Craete an EPD.
    ///
    /// - parameter position: the initial position of the pieces in the EPD.
    /// - parameter opcodes:
    public init(position: Position, opcodes: [Opcode]) {
        self.position = position
        self.opcodes = opcodes
    }

    /// Creates an `EPD` from a string.
    public init?(parse epd: String) {
        let components = epd.split(by: Character.whitespaces)
        let fen = (0...3).map { components[$0] }.joined(separator: " ") + " 0 1"
        guard let position = Position(fen: fen) else { return nil }
        var opcodes: [EPD.Opcode] = []

        let codes = (4..<components.endIndex).map { components[$0] }.joined(separator: " ").splitBySemicolon()

        for entry in codes.map({ $0.splitByWhitespaces() }) {
            guard let op = entry.first else { fatalError() }
            let rest = entry.dropFirst().map { $0.trimmingCharacters(in: .punctuationCharacters) }
            guard !rest.isEmpty else { fatalError() }
            if let opcode = EPD.Opcode(tag: op, value: rest) {
                opcodes.append(opcode)
            }
        }
        self.init(position: position, opcodes: opcodes)
    }
}

extension EPD: Equatable {
    public static func == (lhs: EPD, rhs: EPD) -> Bool {
        return lhs.position == rhs.position && lhs.opcodes == rhs.opcodes
    }
}

extension EPD.Opcode: Equatable {
    public static func == (lhs: EPD.Opcode, rhs: EPD.Opcode) -> Bool {
        switch (lhs, rhs) {
        case let (.acd(x), .acd(y)):
            return x == y
        case let (.acn(x), .acn(y)):
            return x == y
        case let (.acs(x), .acs(y)):
            return x == y
        case let (.bm(x), .bm(y)):
            return x == y
        case let (.ce(x), .ce(y)):
            return x == y
        case let (.c0(x), .c0(y)):
            return x == y
        case let (.c1(x), .c1(y)):
            return x == y
        case let (.c2(x), .c2(y)):
            return x == y
        case let (.c3(x), .c3(y)):
            return x == y
        case let (.c4(x), .c4(y)):
            return x == y
        case let (.c5(x), .c5(y)):
            return x == y
        case let (.c6(x), .c6(y)):
            return x == y
        case let (.c7(x), .c7(y)):
            return x == y
        case let (.c8(x), .c8(y)):
            return x == y
        case let (.c9(x), .c9(y)):
            return x == y
        case let (.eco(x), .eco(y)):
            return x == y
        case let (.id(x), .id(y)):
            return x == y
        case let (.nic(x), .nic(y)):
            return x == y
        case let (.pm(x), .pm(y)):
            return x == y
        case let (.pv(x), .pv(y)):
            return x == y
        default:
            return false
        }
    }
}
