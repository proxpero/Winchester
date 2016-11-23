//
//  HistoryView.swift
//  Winchester
//
//  Created by Todd Olsen on 11/4/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Endgame


public enum HistoryView { }

public protocol HistoryCellType: class {

    func setText(text: String)
    func setIsBordered(isBordered: Bool)
    func setTextAlignment(textAlignment: NSTextAlignment)

}

extension HistoryView {

    public enum CellType: Equatable {

        case start
        case number(Int)
        case move(String)
        case outcome(Outcome)

        public func configureCell(cell: HistoryCellType) {
            cell.setText(text: self.text)
            cell.setIsBordered(isBordered: self.isBordered)
            cell.setTextAlignment(textAlignment: self.textAlignment)
        }

        public var shouldBeSelected: Bool {
            switch self {
            case .start: return true
            case .number: return false
            case .move: return true
            case .outcome: return false
            }
        }

        public var width: CGFloat {
            switch self {
            case .start: return 80.0
            case .number: return 45.0
            case .move: return 70.0
            case .outcome: return 80.0
            }
        }

        // MARK: - Private Computed Properties and Functions

        private var text: String {
            switch self {
            case .start: return "Start"
            case .number(let n): return "\(n)."
            case .move(let m): return m.replacingOccurrences(of: "x", with: "×")
            case .outcome(let outcome): return outcome.userDescription
            }
        }

        private var textAlignment: NSTextAlignment {
            switch self {
            case .start: return .center
            case .number: return .right
            case .move: return .center
            case .outcome: return .center
            }
        }

        private var isBordered: Bool {
            switch self {
            case .number: return false
            case .outcome: return false
            default: return true
            }
        }

        public static func == (lhs: HistoryView.CellType, rhs: HistoryView.CellType) -> Bool {
            switch (lhs, rhs) {
            case (.start, .start): return true
            case (.number(let a), .number(let b)): return a == b
            case (.move(let a), .move(let b)): return a == b
            case (.outcome(let a), .outcome(let b)): return a == b
            default:
                return false
            }
        }

    }
}

