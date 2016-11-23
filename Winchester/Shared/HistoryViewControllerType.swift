//
//  HistoryViewControllerType.swift
//  Winchester
//
//  Created by Todd Olsen on 11/23/16.
//  Copyright © 2016 Todd Olsen. All rights reserved.
//

public protocol HistoryViewControllerType: class, ViewControllerType {

    weak var delegate: HistoryViewDelegate? { get set }
    weak var dataSource: HistoryViewDataSource? { get set }
    func updateCell(at itemIndex: Int?)
    func selectCell(at itemIndex: Int?)
}

extension HistoryViewControllerType where Self: CollectionViewController {
    public func updateCell(at itemIndex: Int?) {
        guard let indexPath = dataSource?.indexPath(for: itemIndex) else { return }
        collectionView?.reloadData()
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    public func selectCell(at itemIndex: Int?) {
        guard let indexPath = dataSource?.indexPath(for: itemIndex) else { return }
        collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}
