//
//  Board.swift
//  Engine
//
//  Created by Todd Olsen on 8/4/16.
//
//

/// A chess board.
/// This struct holds only what you would literally see looking at a chessboard.
/// There is no metadata.
public struct Board: Sequence, CustomStringConvertible, Hashable {

    // MARK: -

    /// A board side.
    public enum Side {

        // MARK: Cases

        /// Right side of the board.
        case kingside

        /// Right side of the board.
        case queenside

        // MARK: Public Computed Properties.

        /// `self` is kingside.
        public var isKingside: Bool {
            return self == .kingside
        }

        /// `self` is queenside.
        public var isQueenside: Bool {
            return self == .queenside
        }
        
    }

    // MARK: -

    /// A chess board space.
    public struct Space: Hashable, CustomStringConvertible {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// The space's location on a chess board.
        public var location: Location {
            get {
                return (file, rank)
            }
            set {
                (file, rank) = newValue
            }
        }

        /// The space's square on a chess board.
        public var square: Square {
            get {
                return Square(file: file, rank: rank)
            }
            set {
                location = newValue.location
            }
        }

        /// The color of a space's square on the board.
        public var color: Color {
            return (file.index & 1 != rank.index & 1) ? .white : .black
        }

        /// The space's name. For example: "a3".
        public var name: String {
            return "\(file.character)\(rank.rawValue)"
        }

        /// A textual representation of `self`.
        public var description: String {
            let pieceDescription: String = piece != nil ? "\(piece!.description)" : ""
            return "Space(\(name) \(pieceDescription))"
        }

        /// The hash value.
        public var hashValue: Int {
            let pieceHash = piece?.hashValue ?? (6 << 1)
            let fileHash = file.hashValue << 4
            let rankHash = rank.hashValue << 7
            return pieceHash + fileHash + rankHash
        }

        /// Create a chess board space with a piece, file, and rank.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.init(piece: piece, location: (file, rank))
        }

        /// Create a chess board space with a piece and location.
        public init(piece: Piece? = nil, location: Location) {
            self.piece = piece
            (file, rank) = location
        }

        /// Create a chess board space with a piece and square.
        public init(piece: Piece? = nil, square: Square) {
            self.piece = piece
            (file, rank) = square.location
        }

        /// Clears the piece from the space and returns it.
        @discardableResult
        public mutating func clear() -> Piece? {
            let piece = self.piece
            self.piece = nil
            return piece
        }

        /// Returns `true` if both spaces are the same.
        public static func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
            return lhs.piece == rhs.piece
                && lhs.file == rhs.file
                && lhs.rank == rhs.rank
        }
    }

    // MARK: - Public Initializers

    /// Create a chess board.
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

    // MARK: - Public Subscripts

    /// Gets and sets the bitboard for `piece`.
    public subscript(piece: Piece) -> Bitboard {
        get {
            return _bitboards[piece.hashValue]
        }
        set {
            _bitboards[piece.hashValue] = newValue
        }
    }

    /// Gets and sets a piece at `location`.
    public subscript(location: Location) -> Piece? {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    /// Gets and sets a piece at `square`.
    public subscript(square: Square) -> Piece? {
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

    // MARK: - Public Computed Properties and Functions

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
        return self.flatMap({ $0.piece })
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

    // MARK: - Getting Spaces

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

    // MARK: - Getting Pieces

    /// Removes a piece at `square`, and returns it.
    @discardableResult
    public mutating func removePiece(at square: Square) -> Piece? {
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
    public mutating func removePiece(at location: Location) -> Piece? {
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

    // MARK: - Getting Locations and Squares

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

    // MARK: - Protocol Conformance

    /// Returns an iterator over the spaces of the board.
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    /// An iterator for `Board` used as a base for both `Iterator` and `Generator`.
    public struct Iterator: IteratorProtocol {

        private let _board: Board
        private var _index: Int

        init(_ board: Board) {
            self._board = board
            self._index = 0
        }

        public mutating func next() -> Board.Space? {
            guard let square = Square(rawValue: _index) else {
                return nil
            }
            defer { _index += 1 }
            return _board.space(at: square)
        }
    }

    /// A textual representation of `self`.
    public var description: String {
        return "Board(\(fen))"
    }

    /// The hash value.
    public var hashValue: Int {
        return Set(self).hashValue
    }

    /// Returns `true` if both boards are the same.
    public static func == (lhs: Board, rhs: Board) -> Bool {
        return lhs._bitboards == rhs._bitboards
    }

    // MARK: - Private Stored Properties

    /// Returns the bitboards used to store positions for all twelve cases of 
    /// `Piece`. This is the only stored property of a `Board`.
    private var _bitboards: Array<Bitboard>

    // MARK: - Attackers

    internal func _execute(uncheckedMove move: Move, for color: PlayerTurn, isEnPassant: Bool, promotion: Piece?) -> (Board, Piece?)? {

        guard let piece = self[move.origin] else { return nil }

        var newBoard = self
        var endPiece = piece
        var captureSquare = move.target
        var capture = self[captureSquare]

        if piece.kind.isPawn {
            if move.target.rank == Rank(endFor: color)  {
                guard
                    let promo = promotion,
                    promo.kind.isPromotionType() else {
                        fatalError("Unexpected Promotion: \(promotion)")
                }
                endPiece = Piece(kind: promo.kind, color: color)
            } else if isEnPassant {
                capture = Piece(pawn: color.inverse())
                captureSquare = Square(file: move.target.file, rank: move.origin.rank)
            }
        } else if piece.kind.isKing {
            if move.isCastle() {
                let (old, new) = move._castleSquares()
                let rook = Piece(rook: color)
                newBoard[rook][old] = false
                newBoard[rook][new] = true
            }
        }

        newBoard[piece][move.origin] = false
        newBoard[endPiece][move.target] = true
        if let capture = capture {
            newBoard[capture][captureSquare] = false
        }

        return (newBoard, capture)
    }

    /// Return the attacks that can be made by `piece`
    public func _attacks(for piece: Piece, obstacles: Bitboard) -> Bitboard {
        return self[piece]._attacks(for: piece, obstacles: obstacles)
    }

    /// Returns the attacks that can be made by `color`
    public func _attacks(for color: Color) -> Bitboard {
        return Piece.pieces(for: color).reduce(0) { $0 | _attacks(for: $1, obstacles: occupiedSpaces) }
    }

    /// Returns the attackers to `square` corresponding to `color`.
    ///
    /// - parameter square: The `Square` being attacked.
    /// - parameter color: The `Color` of the attackers.
    public func attackers(targeting square: Square, color: Color) -> Bitboard {
        let all = occupiedSpaces
        let attackingPieces = Piece.pieces(for: color)
        let defendingPieces = Piece.pieces(for: color.inverse())
        let attacks = defendingPieces.map({ piece in
            square.attacks(for: piece, obstacles: all)
        })
        let queens = (attacks[2] | attacks[3]) & self[Piece(queen: color)]
        return zip(attackingPieces, attacks)
            .map({ self[$0] & $1 })
            .reduce(queens, |)
    }

    /**
     Returns a bitboard of pieces of the same kind and color that are
     attacking the same square, useful for discovering ambiguities.
     */
    public func attacks(by piece: Piece, to square: Square) -> Bitboard {
        return square.attacks(for: piece, obstacles: occupiedSpaces) & bitboard(for: piece)
    }

    /// Returns the attackers to the king for `color`.
    ///
    /// - parameter color: The `Color` of the potentially attacked king.
    ///
    /// - returns: A bitboard of all attackers, or 0 if the king does not exist
    ///   or if there are no pieces attacking the king.
    public func attackersToKing(for color: Color) -> Bitboard {
        guard let square = squareForKing(for: color) else {
            return 0
        }
        return attackers(targeting: square, color: color.inverse())
    }

    /// Returns `true` if the king for `color` is in check.
    public func isKingInCheck(for color: Color) -> Bool {
        return attackersToKing(for: color) != 0
    }

    public func isKingInMultipleCheck(for color: Color) -> Bool {
        return attackersToKing(for: color).count > 1
    }

    /// Returns an array of moves which the player for `color` might execute
    /// to retake a lost piece.
    internal func _uncheckedGuardingMoves(for color: Color) -> [Move] {

        var result: [Move] = []

        let currentBits = bitboard(for: color)
        let enemyBits = bitboard(for: color.inverse())

        for candidate in currentBits {
            let newBits = currentBits & ~candidate.bitmask
            let occupiedBits = newBits | enemyBits
            guard let piece = self[candidate] else { fatalError("Expected a piece at \(candidate.description)") }

            for origin in newBits {
                let isDefender = origin.bitmask._attacks(for: piece, obstacles: occupiedBits).contains(candidate)
                let exposesKing: Bool = {
                    var newBoard = self
                    newBoard[origin] = nil
                    return newBoard.attackersToKing(for: color).count > 0
                }()
                if isDefender && !exposesKing {
                    result.append(Move(origin: origin, target: candidate))
                }
            }
        }

        return result
    }

    internal func _defendedSquares(for color: Color) -> Bitboard {
        let mine = pieces(for: color).reduce(0) { $0 | self[$1] }
//        let enemy = pieces(for: color.inverse()).reduce(0) { $0 | self[$1] }
        return _attacks(for: color) & mine
    }

}
