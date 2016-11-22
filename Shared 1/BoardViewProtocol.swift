//
//  BoardViewProtocol.swift
//  Winchester
//
//  Created by Todd Olsen on 11/16/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import CoreGraphics
import Endgame

protocol BoardViewType: class, BoardViewProtocol, PieceNodeDataSource, PieceNodeCaptureProtocol, HistoryTraversable { }

protocol BoardViewProtocol {

    var frame: CGRect { get }

    func setup(with board: Board)

//    weak var delegate: BoardViewDelegate? { get set }

    /// Assuming the frame is itself a square and divided into 64 smaller squares like a chessboard, return the `CGPoint` at the center of the provided `Square`.
    ///
    /// - Parameter square: An instance of `Square`
    /// - Returns: The CGPoint located at the center of `Square`
    func position(for square: Square) -> CGPoint

    /// Assuming the frame is itself a square and divided into 64 smaller squares like a chessboard, return the `Square` which would contain the location provided.
    ///
    /// - Parameters:
    ///   - location: The `CGPoint` representing the location in the frame.
    ///   - isViewFlipped: A `Bool` whether `y` coordinates increase as a point travels down the screen.
    /// - Returns: A `Square` which contains the point, or `nil` if no square could be found to contain the point.
    func square(for location: CGPoint, isViewFlipped: Bool) -> Square?

    var squareSize: CGSize { get }

    // Square Nodes
    var squareNodes: [Square.Node] { get }
    func clearSquareNodes(ofKind kind: Square.Kind)
    func clearSquareNodes()
    func present(_ squares: [Square], as kind: Square.Kind)

    // Piece Nodes
    var pieceNodes: [Piece.Node] { get }
    func add(_ pieceNode: Piece.Node, at origin: Square)
    func remove(_ pieceNode: Piece.Node)
    func move(_ pieceNode: Piece.Node, to target: Square)
    func updatePieces(with board: Board)

    // Arrow Nodes 
    func presentArrows(for moves: [Move], ofKind kind: Arrow.Kind)
    func removeArrows(with kind: Arrow.Kind)
    func removeAllArrows()

}

extension BoardViewProtocol {

    func position(for square: Square) -> CGPoint {
        let x = start + offset(for: square.file.index)
        let y = start + offset(for: square.rank.index)
        return CGPoint(x: x, y: y)
    }

    func square(for location: CGPoint, isViewFlipped: Bool = true) -> Square? {
        // divide edge by 8 and parition from origin out.

        let rowWidth = frame.size.width / 8.0

        // Determine which partition of the board (0..<8) the coordinate occupies.
        func partition(for coordinate: CGFloat, upperBound: CGFloat) -> Int {
            var boundry = upperBound
            var partition = 8
            while (coordinate < boundry) && (partition > 0) {
                partition -= 1
                boundry = rowWidth * CGFloat(partition)
            }
            return partition
        }

        let fileIndex = partition(for: location.x, upperBound: frame.origin.x + frame.size.width)
        var rankIndex = partition(for: location.y, upperBound: frame.origin.y + frame.size.height)
        rankIndex = isViewFlipped ? 7 - rankIndex : rankIndex

        return Square(file: File(index: fileIndex),
                      rank: Rank(index: rankIndex))
    }

    var squareSize: CGSize {
        let rowCount: CGFloat = 8.0
        let edge = (frame.size.width - (squareInset * (rowCount + 1.0))) / rowCount
        return CGSize(width: edge, height: edge)
    }

    // MARK: Private Functions and Properties

    private var squareInset: CGFloat {
        return 1.0
    }

    private var start: CGFloat {
        let boardEdge = frame.size.width
        let squareEdge = squareSize.width
        let start = (-boardEdge + squareEdge) / 2.0
        return start + squareInset
    }

    private func offset(for index: Int) -> CGFloat {
        return CGFloat(index) * (squareSize.width + squareInset)
    }

}

