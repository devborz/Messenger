//
//  FiTableView.swift
//  Pangea
//
//  Created by Усман Туркаев on 02.09.2021.
//

import UIKit

struct FiContent: Hashable, Equatable {
    
    var type: ChatContentType
    
    func hash(into hasher: inout Hasher) {
        switch type {
        case .message(value: let value):
            hasher.combine(value.model.id)
        case .header(value: let value):
            hasher.combine(value.date.timeIntervalSince1970)
        case .seenIndicator(value: let value):
            hasher.combine(value.isSeen)
        }
    }
}

class FiTableView<T : Hashable>: UITableView, UITableViewDataSource {
    
    typealias FiSnapshot = [T]
    
    typealias CellsProvider = (FiTableView, IndexPath, T) -> UITableViewCell?
    
    private var snapshot: FiSnapshot?
    
    private var nextSnapshot: FiSnapshot?
    
    private var isUpdating: Bool = false {
        didSet {
            guard isUpdating != oldValue && !isUpdating else { return }
            guard nextSnapshot != nil else { return }
            updateWithAnimation()
        }
    }
    
    var isEmpty: Bool {
        return snapshot?.count ?? 0 == 0
    }
    
    internal override var dataSource: UITableViewDataSource? {
        get {
            return super.dataSource
        }
        set {
            super.dataSource = newValue
        }
    }
    
    var cellProvider: CellsProvider?
    
    private init() {
        super.init(frame: .zero, style: .plain)
    }

    init(_ snapshot: FiSnapshot, provider: @escaping CellsProvider) {
        super.init(frame: .zero, style: .plain)
        self.snapshot = snapshot
        self.cellProvider = provider
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(snapshot: FiSnapshot) {
        self.snapshot = snapshot
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }
    
    func animateDifference(snapshot: FiSnapshot) {
        self.nextSnapshot = snapshot
        if !isUpdating {
            updateWithAnimation()
        }
    }
    
    private func updateWithAnimation() {
        self.isUpdating = true
        guard let snapshot = snapshot,
              let nextSnapshot = nextSnapshot else {
            self.isUpdating = false
            return
        }
        self.snapshot = nextSnapshot
        self.nextSnapshot = nil
        
        let oldSet: Set<T> = Set(snapshot)
        let newSet: Set<T> = Set(nextSnapshot)

        let deletedItems = oldSet.subtracting(newSet)
        let insertedItems = newSet.subtracting(oldSet)
        
        guard !insertedItems.isEmpty || !deletedItems.isEmpty else {
            isUpdating = false
            return
        }
        
        var deletingIndexPaths: [IndexPath] = []
        var insertingIndexPaths: [IndexPath] = []
        
        for deletedItem in deletedItems {
            if let index = snapshot.firstIndex(of: deletedItem) {
                print(index)
                deletingIndexPaths.append(IndexPath(row: index, section: 0))
            }
        }
        
        for index in 0..<insertedItems.count {
            insertingIndexPaths.append(.init(row: index, section: 0))
        }
        
        guard insertingIndexPaths.count + deletingIndexPaths.count == oldSet.symmetricDifference(newSet).count else {
            self.isUpdating = false
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.performBatchUpdates { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.deleteRows(at: deletingIndexPaths, with: .fade)
                strongSelf.insertRows(at: insertingIndexPaths, with: .top)
            } completion: { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.isUpdating = false
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapshot?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = snapshot?[indexPath.row] {
            return cellProvider?(self, indexPath, item) ?? UITableViewCell()
        } else {
            return UITableViewCell()
        }
    }
}
