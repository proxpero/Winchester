//
//  HistoryCellType.swift
//  Endgame
//
//  Created by Todd Olsen on 10/21/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import SpriteKit
import Engine

enum HistoryCellType {

    case start
    case number(Int)
    case move(String)
    case outcome(Outcome)

    // MARK: - Internal Functions

    func configureCell(cell: HistoryCell) {
        cell.label.text = self.text
        cell.isBordered = self.isBordered
        cell.label.textAlignment = self.textAlignment
    }

    var shouldBeSelected: Bool {
        switch self {
        case .start: return true
        case .number: return false
        case .move: return true
        case .outcome: return false
        }
    }

    var width: CGFloat {
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


    static func == (lhs: HistoryCellType, rhs: HistoryCellType) -> Bool {
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
