//
//  CellController.swift
//  EssentialFeed_2023iOS
//
//  Created by Владислав Тодоров on 11.02.2024.
//

import UIKit

// The clients can access what they need and they are not forced to implemented all the method, conforming to interface segrigation principle
public struct CellController {
    // Using hashable to use UITAbleviewDiffableDatasource
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
