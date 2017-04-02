//
//  Game+Transaction.swift
//  Endgame
//
//  Created by Todd Olsen on 3/28/17.
//
//


/*
struct TransactionSet {

    typealias Space = Board.Space
    typealias Event = Game.Event
    typealias Direction = Game.Event.Direction

    /// The underlying storage.
    fileprivate(set) var transactions: Set<Transaction> = []

}

extension TransactionSet {

    /// Initialize with an arraySlice of `Event`s and a `Direction`.
    init(events: ArraySlice<Event>, in direction: Direction) {
        self = TransactionSet()
        for event in events {
            insert(event, for: direction)
        }
    }

    /// 
    public var synthesis: Array<Transaction> {
        return Array(transactions)
    }

    func map<A>(f: @escaping (Transaction) -> A) -> [A] {
        return transactions.map(f)
    }

}

extension TransactionSet: CustomStringConvertible {

    /// CustomStringConvertible conformance
    var description: String {
        var result = ""
        for transaction in transactions {
            result += "\(transaction)\n"
        }
        return result
    }

}

extension TransactionSet {

    mutating func merge(_ element: Transaction) {

        let candidates = transactions.filter { $0.target == element.origin }
        guard candidates.count < 2 else { fatalError("Unexpected extra candidate \(candidates)") }
        guard candidates.count != 0 else {
            transactions.insert(element)
            return
        }

        let previous = candidates[0]
        transactions.remove(previous)
        let new = Transaction(
            origin: previous.origin,
            target: element.target
        )
        transactions.insert(new)

    }

    mutating func insert(_ event: Event, for direction: Direction) {

        guard let history = event.history else { fatalError("no history for \(event)") }

        let move = direction.isUndo ? history.move.reversed() : history.move
        let (old, new): (Piece, Piece) = {
            guard let promotion = history.promotion else {
                return (history.piece, history.piece)
            }
            if direction.isRedo {
                return (history.piece, promotion)
            } else {
                return (promotion, history.piece)
            }
        }()

        merge(Transaction(
            origin: Space(piece: old, square: move.origin),
            target: Space(piece: new, square: move.target))
        )

        if let capture = history.capture {

            let origin: Space
            let target: Space

            switch direction {
            case .redo:
                origin = capture
                target = Space(
                    piece: nil, square:
                    capture.square
                )

            case .undo:
                origin = Space(piece: nil, square: capture.square)
                target = capture
            }

            merge(Transaction(
                origin: origin,
                target: target)
            )

        }

        if history.move.isCastle() && history.piece.kind == .king {

            let (old, new) = history.move.castleSquares()
            let rook = Piece(rook: history.piece.color)

            switch direction {
            case .redo:
                merge(Transaction(
                    origin: Space(piece: rook, square: old),
                    target: Space(piece: rook, square: new))
                )
            case .undo:
                merge(Transaction(
                    origin: Space(piece: rook, square: new),
                    target: Space(piece: rook, square: old))
                )
            }
            
        }
        
    }
    
}
 */


