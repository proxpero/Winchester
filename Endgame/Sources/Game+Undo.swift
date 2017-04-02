//
//  Game+Undo.swift
//  Endgame
//
//  Created by Todd Olsen on 3/22/17.
//
//

extension Game {

    /// Sets the game's `moveIndex` to the starting position.
    /// Emits a `game:moveIndexDidChange` call to the game delegate.
    /// Emits a `game:didTraverse` call to the game delegate.
    public func undoAll() {
        undo(count: moveIndex)
    }

    /// Sets the game's `moveIndex` to the last position.
    /// Emits a `game:moveIndexDidChange` call to the game delegate.
    /// Emits a `game:didTraverse` call to the game delegate.
    public func redoAll() {
        return redo(count: events.count - moveIndex - 1)
    }

    /// Decrements the game's `moveIndex` by `count`.
    /// Emits a `game:moveIndexDidChange` call to the game delegate.
    /// Emits a `game:didTraverse` call to the game delegate.
    public func undo(count: Int = 1) {
        traverse(count: count, direction: .undo)
    }

    /// Increments the game's `moveIndex` by `count`.
    /// Emits a `game:moveIndexDidChange` call to the game delegate.
    /// Emits a `game:didTraverse` call to the game delegate.
    public func redo(count: Int = 1) {
        traverse(count: count, direction: .redo)
    }

    func traverse(count: Int, direction: Game.Event.Direction) {

        guard count > 0 else { return }

        let lowerbound: Array<Game.Event>.Index
        let upperbound: Array<Game.Event>.Index

        switch direction {
        case .undo:
            lowerbound =  Swift.max(events.startIndex + 1, moveIndex - count + 1)
            upperbound = moveIndex + 1
            // Note: the setter on `moveIndex` calls the appropriate delegate method.
            moveIndex = Swift.max(lowerbound - 1, events.startIndex)

        case .redo:
            lowerbound = moveIndex + 1
            upperbound = Swift.min(events.endIndex, lowerbound+count)
            // Note: the setter on `moveIndex` calls the appropriate delegate method.
            moveIndex = upperbound - 1
        }

        synthesize(events: events[lowerbound..<upperbound], in: direction)

    }

    /// Returns a array of `Board.Space`s which describe the minimum actions necessary
    /// to change a board position from the prior state, before the traversal
    /// of events, to the ending state, after the traversal.
    func synthesize(events: ArraySlice<Event>, in direction: Game.Event.Direction) {

        typealias Space = Board.Space
        typealias Event = Game.Event
        typealias Direction = Game.Event.Direction

        var transactions: Set<Transaction> = []

        // Merge `element` into the existing `transactions` set. If the piece has not yet moved then insert the transaction, otherwise add its move onto its previous moves (like vector addition).
        func merge(_ element: Transaction?) {

            guard let element = element else { return }

            let candidates = transactions.filter { $0.target == element.origin }
            guard candidates.count < 2 else { fatalError("Unexpected extra candidate \(candidates)") }

            guard !candidates.isEmpty else {
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

        func insert(_ event: Event, for direction: Direction) {

            guard let history = event.history else { fatalError("no history for \(event)") }

            // The transaction from the piece that explicitly moved, including a
            // possible promotion to a different piece.
            func basicTransaction() -> Transaction {

                let move = direction.isUndo ? history.move.reversed() : history.move

                let (old, new): (Piece, Piece) = {
                    // If the transaction is not a promotion, then the start piece
                    // and the end piece will be the same.
                    guard let promotion = history.promotion else {
                        return (history.piece, history.piece)
                    }
                    if direction.isRedo {
                        return (history.piece, promotion)
                    } else {
                        return (promotion, history.piece)
                    }
                }()

                return Transaction(
                    origin: Space(piece: old, square: move.origin),
                    target: Space(piece: new, square: move.target))
            }

            // The removal or addition transaction created by the victim of 
            // a capture.
            func captureTransaction() -> Transaction? {

                guard let capture = history.capture else {
                    return nil
                }

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

                return Transaction(
                    origin: origin,
                    target: target
                )

            }

            // The transaction created by the rook movement in a castle.
            func castleTransaction() -> Transaction? {

                guard history.move.isCastle() && history.piece.kind == .king else { return nil }

                let rook = Piece(rook: history.piece.color)
                let (old, new): (Square, Square) = {
                    let (a, b) = history.move.castleSquares()
                    return direction.isRedo ? (a, b) : (b, a)
                }()

                return Transaction(
                    origin: Space(piece: rook, square: old),
                    target: Space(piece: rook, square: new)
                )

            }

            // Merge the optional capture transaction.
            merge(captureTransaction())

            // Merge the basic transaction.
            merge(basicTransaction())

            // Merge the optional castle transaction.
            merge(castleTransaction())

        }

        // Undone events are reverse .
        for event in direction.isRedo ? Array(events) : Array(events.reversed()) {
            insert(event, for: direction)
        }

        // Finally, call the delegate with a summary of the traversal.
        delegate?.game(self, didTraverse: events, in: direction, with: transactions)
    }

}

public struct Transaction {
    /// A `Space` corresponding to the initial square and piece combination.
    var origin: Board.Space

    /// A `Space` corresponding to the final square and piece combination.
    var target: Board.Space

}

extension Transaction: Equatable {

    /// Equatable conformance
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.origin == rhs.origin && lhs.target == rhs.target // && lhs.status == rhs.status
    }

}

extension Transaction: Hashable {

    /// The hash value.
    public var hashValue: Int {
        return origin.hashValue ^ target.hashValue // ^ status.hashValue
    }
}

