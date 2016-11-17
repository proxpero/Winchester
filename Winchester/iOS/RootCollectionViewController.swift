//
//  RootCollectionViewController.swift
//  Winchester
//
//  Created by Todd Olsen on 10/15/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

import UIKit
import Endgame

final class RootCollectionViewController: UICollectionViewController {

    // MARK: - Stored Properties

    var model: Model!
    var delegate: Delegate!

}

// MARK: - Section

protocol Playable { }
extension Game: Playable { }
extension Puzzle: Playable { }

extension RootCollectionViewController {

    fileprivate enum Section: Int {

        case userGames
        case classicGames
        case puzzles

        static var all: [Section] {
            return [.userGames, .classicGames, .puzzles]
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }

        var title: String {
            switch self {
            case .userGames: return "My Games"
            case .classicGames: return "Classic Games"
            case .puzzles: return "Puzzles"
            }
        }

        var shouldHideShowAllButton: Bool {
            return true
        }

        var didSelectShowAll: () -> () {
            switch self {
            case .userGames:
                return { }
            case .classicGames:
                return { }
            case .puzzles:
                return { }
            }
        }

        var shouldHideCreateItem: Bool {
            return true
        }

        func isCreateNewGame(for indexPath: IndexPath) -> Bool {
            return indexPath.row == 0
        }

        var cellType: UICollectionViewCell.Type {
            switch self {
            case .userGames: return ShowGameCell.self
            case .classicGames: return ShowGameCell.self
            case .puzzles: return ShowPuzzleCell.self
            }
        }

        var configureCell: (UICollectionViewCell) -> (Playable) -> () {
            switch self {
            case .userGames:
                return configureShowGameCell
            case .classicGames:
                return configureShowGameCell
            case .puzzles:
                return configureShowPuzzleCell
            }
        }

        func configureNewGameCell(cell: UICollectionViewCell) -> () -> () {
            guard let cell = cell as? ShowGameCell else { fatalError() }
            return {
                cell.imageView.image = #imageLiteral(resourceName: "create")
                cell.whiteRow.isHidden = true
                cell.blackRow.isHidden = true
            }
        }

        func configureShowGameCell(cell: UICollectionViewCell) -> (Playable) -> () {
            guard let cell = cell as? ShowGameCell else { fatalError("Expected a `ShowGameCell`") }
            return { game in
                guard let game = game as? Game else { fatalError("Expected a game") }
                let image = game[game.endIndex-1].position.board.view(edge: cell.bounds.height).image()
                cell.imageView.image = image
                cell.whiteLabel.text = game.whitePlayer.name
                cell.blackLabel.text = game.blackPlayer.name
                cell.whiteOutcomeLabel.text = game.outcome.description(for: .white)
                cell.blackOutcomeLabel.text = game.outcome.description(for: .black)
            }

        }

        func configureShowPuzzleCell(cell: UICollectionViewCell) -> (Playable) -> () {
            guard let cell = cell as? ShowPuzzleCell else { fatalError("Expected a `ShowPuzzleCell`") }
            return { puzzle in
                guard let puzzle = puzzle as? Puzzle else { fatalError("Expected a puzzle") }
            }
        }
    }
}

// MARK: - Model

extension RootCollectionViewController {

    struct Model {

        // MARK: Private Stored Properties

        private let _userGames: Array<Game>
        private let _classicGames: Array<Game>

        // MARK: Initializers

        init(userGames: [Game], classicGames: [Game]) {
            self._userGames = userGames
            self._classicGames = classicGames
        }

        // MARK: Computed Properties and Functions

        var sectionCount: Int {
            return Section.all.count
        }

        func userGame(at index: Int) -> Game {
            if index == 0 { return Game() }
            return _userGames[index-1]
        }

        func classicGame(at index: Int) -> Game {
            return _classicGames[index]
        }

        func puzzle(at index: Int) -> Puzzle {
            return Puzzle()
        }

        func title(for section: Int) -> String {
            return Section(section).title
        }

        func itemCount(in section: Int) -> Int {
            switch Section(section) {
            case .userGames: return _userGames.count + 1
            case .classicGames: return _classicGames.count
            case .puzzles: return 0
            }
        }

        func headerConfiguration(for indexPath: IndexPath) -> (identifier: String, with: (UICollectionReusableView) -> ()) {
            return (_headerReuseIdentifier(for: indexPath), configureHeader(at: indexPath))
        }

        func cellConfiguration(for indexPath: IndexPath) -> (identifier: String, with: (UICollectionViewCell) -> ()) {
            return (_cellReuseIdentifier(for: indexPath), configureCell(at: indexPath))
        }

        func _cellType(for indexPath: IndexPath) -> UICollectionViewCell.Type {
            return Section(at: indexPath).cellType
        }

        func _headerReuseIdentifier(for indexPath: IndexPath) -> String {
            return HeaderCell.reuseIdentifier
        }

        func _cellReuseIdentifier(for indexPath: IndexPath) -> String {
            return (_cellType(for: indexPath) as! ReusableCell.Type).reuseIdentifier
        }

        func configureHeader(at indexPath: IndexPath) -> (UICollectionReusableView) -> () {
            return { cell in
                guard let cell = cell as? HeaderCell else { fatalError("Unexpected") }
                let section = Section(at: indexPath)
                cell.titleLabel.text = section.title
                cell.showAllButton.isHidden = section.shouldHideShowAllButton
                cell.didTapShowAll = section.didSelectShowAll
                cell.createItemButton.isHidden = section.shouldHideCreateItem
            }
        }
        
        func configureCell(at indexPath: IndexPath) -> (UICollectionViewCell) -> () {
            return { cell in
                let section = Section(at: indexPath)
                switch section {
                case .userGames:
                    if section.isCreateNewGame(for: indexPath) {
                        return section.configureNewGameCell(cell: cell)()
                    } else {
                        return section.configureCell(cell)(self.userGame(at: indexPath.row))
                    }
                case .classicGames:
                    let game = self.classicGame(at: indexPath.row)
                    return section.configureCell(cell)(game)
                case .puzzles:
                    let puzzle = Puzzle()
                    return section.configureCell(cell)(puzzle)
                }
            }
        }

    }
}

// MARK: - Delegate

extension RootCollectionViewController {

    struct Delegate {

        let didSelectUserGame: (Game) -> ()
        let didSelectFavoriteGame: (Game) -> ()
        let didSelectPuzzle: (Puzzle) -> ()

        func didSelectItem(at indexPath: IndexPath, with model: Model) {
            let section = Section(at: indexPath)
            switch section {
            case .userGames:
                didSelectUserGame(model.userGame(at: indexPath.row))
            case .classicGames:
                didSelectFavoriteGame(model.classicGame(at: indexPath.row))
            case .puzzles:
                didSelectPuzzle(model.puzzle(at: indexPath.row))
            }
        }
    }
}

// MARK: - UIKit

extension RootCollectionViewController: UICollectionViewDelegateFlowLayout {

    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }

    override func viewDidLoad() {

    }

    // MARK: - Collection View Data Source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.sectionCount
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.itemCount(in: section)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else { fatalError("Unexpected kind") }
        let configuration = model.headerConfiguration(for: indexPath)
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: configuration.identifier, for: indexPath)
        configuration.with(cell)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configuration = model.cellConfiguration(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configuration.identifier, for: indexPath)
        configuration.with(cell)
        return cell
    }

    // MARK: - Collection View Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectItem(at: indexPath, with: model)
    }

    // MARK: - Collection View Flow Delegate

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width: CGFloat
//        if traitCollection.horizontalSizeClass == .compact {
//            width = collectionView.frame.width
//        } else {
//            width = (collectionView.frame.width / 2) - 20
//        }
//        return CGSize(width: width, height: 70)
//    }

}
