//
//  Board.swift
//  Endgame
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess board.
/// This struct holds only what you would literally see looking at a chessboard.
/// There is no metadata.
public struct Board {

    // MARK: - Private Stored Properties

    /// Returns the bitboards used to store positions for all twelve cases of
    /// `Piece`. This is the only stored property of a `Board`.
    fileprivate var _bitboards: Array<Bitboard>

}

extension Board {

    /// Create a standard chess board.
    public init() {
        _bitboards = Array(repeating: 0, count: 12)
        for piece in Piece.all {
            _bitboards[piece.hashValue] = piece.startingPositions
        }
    }

    /// Create a chess board from arrays of piece characters.
    ///
    /// Returns `nil` if a piece can't be initialized from a character. 
    /// Characters beyond the 8x8 area are ignored. Empty spaces are denoted 
    /// with a whitespace or period.
    public init?(pieces: [[Character]]) {
        self.init()
        for rankIndex in pieces.indices {
            guard let rank = Rank(index: rankIndex)?.opposite() else { break }
            for fileIndex in pieces[rankIndex].indices {
                guard let file = File(index: fileIndex) else { break }
                let pieceChar = pieces[rankIndex][fileIndex]
                if pieceChar != " " && pieceChar != "." {
                    guard let piece = Piece(character: pieceChar) else { return nil }
                    self[(file, rank)] = piece
                }
            }
        }
    }

    /// Create a chess board from a valid FEN position.
    public init?(fen: String) {
        func pieces(for string: String) -> [Piece?]? {
            var pieces: [Piece?] = []
            for char in string.characters {
                guard pieces.count < 8 else {
                    return nil
                }
                if let piece = Piece(character: char) {
                    pieces.append(piece)
                } else if let num = Int(String(char)) {
                    guard 1...8 ~= num else { return nil }
                    pieces += Array(repeating: nil, count: num)
                } else {
                    return nil
                }
            }
            return pieces
        }
        guard !fen.characters.contains(" ") else {
            return nil
        }
        let parts = fen.characters.split(separator: "/").map(String.init)
        let ranks = Rank.all.reversed()
        guard parts.count == 8 else {
            return nil
        }
        var board = Board()
        for (rank, part) in zip(ranks, parts) {
            guard let pieces = pieces(for: part) else {
                return nil
            }
            for (file, piece) in zip(File.all, pieces) {
                board[(file, rank)] = piece
            }
        }
        self = board
    }

}

extension Board {

    /// Gets and sets the bitboard for `piece`.
    subscript(piece: Piece) -> Bitboard {
        get {
            return _bitboards[piece.hashValue]
        }
        set {
            _bitboards[piece.hashValue] = newValue
        }
    }

    /// Gets and sets a piece at `location`.
    subscript(location: Location) -> Piece? {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    /// Gets and sets a piece at `square`.
    subscript(square: Square) -> Piece? {
        get {
            for index in _bitboards.indices {
                if _bitboards[index][square] {
                    return Piece(value: index)
                }
            }
            return nil
        }
        set {
            for index in _bitboards.indices {
                _bitboards[index][square] = false
            }
            if let piece = newValue {
                self[piece][square] = true
            }
        }
    }

}


extension Board {

    /// Returns the number of pieces for `color`, or all if `nil`.
    public func pieceCount(for color: Color? = nil) -> Int {
        if let color = color {
            return bitboard(for: color).count
        } else {
            return _bitboards.map({ $0.count }).reduce(0, +)
        }
    }

    /// The board's pieces.
    public var pieces: [Piece] {
        return self.flatMap { $0.piece }
    }

    /// The board's white pieces.
    public var whitePieces: [Piece] {
        return pieces.filter({ $0.color.isWhite })
    }

    /// The board's black pieces.
    public var blackPieces: [Piece] {
        return pieces.filter({ $0.color.isBlack })
    }

    public func pieces(for color: Color) -> [Piece]{
        return pieces.filter({ $0.color == color })
    }

    /// Returns the FEN string for the board.
    public var fen: String {
        func fen(forRank rank: Rank) -> String {
            var fen = ""
            var accumulator = 0
            for space in spaces(at: rank) {
                if let piece = space.piece {
                    if accumulator > 0 {
                        fen += String(accumulator)
                        accumulator = 0
                    }
                    fen += String(piece.character)
                } else {
                    accumulator += 1
                    if space.file == .h {
                        fen += String(accumulator)
                    }
                }
            }
            return fen
        }
        return Rank.all.reversed().map(fen).joined(separator: "/")
    }

    // MARK: - Board Population.

    /// Returns `true` if `self` contains `piece`.
    public func contains(_ piece: Piece) -> Bool {
        return !self[piece].isEmpty
    }

    /// Returns the number of `piece` in `self`.
    public func count(of piece: Piece) -> Int {
        return bitboard(for: piece).count
    }

    /// A bitboard for the occupied spaces of `self`.
    public var occupiedSpaces: Bitboard {
        return _bitboards.reduce(0, |)
    }

    /// A bitboard for the empty spaces of `self`.
    public var emptySpaces: Bitboard {
        return ~occupiedSpaces
    }

    /// Returns `self` flipped horizontally.
    public func flippedHorizontally() -> Board {
        var board = self
        for index in _bitboards.indices {
            board._bitboards[index].flipHorizontally()
        }
        return board
    }

    /// Returns `self` flipped vertically.
    public func flippedVertically() -> Board {
        var board = self
        for index in _bitboards.indices {
            board._bitboards[index].flipVertically()
        }
        return board
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Clears all the pieces from `self`.
    public mutating func clear() {
        self = Board()
    }

    /// Returns the bitboard for `piece`.
    public func bitboard(for piece: Piece) -> Bitboard {
        return self[piece]
    }

    /// Returns the bitboard for `color`.
    public func bitboard(for color: Color) -> Bitboard {
        return Piece.all
            .filter { $0.color == color }
            .map { $0.hashValue }
            .reduce(0) { $0 | _bitboards[$1] }
    }

    /// Returns the spaces at `file`.
    public func spaces(at file: File) -> [Space] {
        return Rank.all.map { space(at: (file, $0)) }
    }

    /// Returns the spaces at `rank`.
    public func spaces(at rank: Rank) -> [Space] {
        return File.all.map { space(at: ($0, rank)) }
    }

    /// Returns the space at `location`.
    public func space(at location: Location) -> Space {
        return Space(piece: self[location], location: location)
    }

    /// Returns the square at `location`.
    public func space(at square: Square) -> Space {
        return Space(piece: self[square], square: square)
    }

    public func spaces(with piece: Piece) -> [Space] {
        return self[piece].map { Space(piece: piece, square: $0) }
    }

    public func spaces(for color: Color) -> [Space] {
        return self.filter { $0.piece?.color == color }
    }

    /// Removes a piece at `square`, and returns it.
    ///
    /// - parameter square: The square of the piece on the board.
    @discardableResult
    mutating func removePiece(at square: Square) -> Piece? {
        if let piece = self[square] {
            self[piece][square] = false
            return piece
        } else {
            return nil
        }
    }

    /// Removes a piece at `location`, and returns it.
    ///
    /// - parameter location: The location of the piece on the board.
    @discardableResult
    mutating func removePiece(at location: Location) -> Piece? {
        return removePiece(at: Square(location: location))
    }

    /// Swaps the pieces between the two locations.
    public mutating func swap(_ first: Location, _ second: Location) {
        swap(Square(location: first), Square(location: second))
    }

    /// Swaps the pieces between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        switch (self[first], self[second]) {
        case let (firstPiece?, secondPiece?):
            self[firstPiece].swap(first, second)
            self[secondPiece].swap(first, second)
        case let (firstPiece?, nil):
            self[firstPiece].swap(first, second)
        case let (nil, secondPiece?):
            self[secondPiece].swap(first, second)
        default:
            break
        }
    }

}

// MARK: - Getting Locations and Squares

extension Board {

    /// Returns the locations where `piece` exists.
    public func locations(for piece: Piece) -> [Location] {
        return bitboard(for: piece).map({ $0.location })
    }

    /// Returns the squares where `piece` exists.
    public func squares(for piece: Piece) -> [Square] {
        return Array(bitboard(for: piece))
    }

    /// Returns the squares where pieces for `color` exist.
    public func squares(for color: Color) -> [Square] {
        return Array(bitboard(for: color))
    }

    /// Returns the square of the king for `color`, if any.
    public func squareForKing(for color: Color) -> Square? {
        return bitboard(for: Piece(king: color)).lsbSquare
    }

}

extension Board: CustomStringConvertible {

    /// A textual representation of `self`.
    public var description: String {
        return "Board(\(fen))"
    }

}

extension Board: Equatable {

    /// Returns `true` if both boards are the same.
    public static func == (lhs: Board, rhs: Board) -> Bool {
        return lhs._bitboards == rhs._bitboards
    }

}

extension Board: Hashable {

    /// The hash value.
    public var hashValue: Int {
        return Set(self).hashValue
    }

}
