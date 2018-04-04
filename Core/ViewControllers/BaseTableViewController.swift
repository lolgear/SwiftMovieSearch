//
//  BaseTableViewController.swift
//  NetworkWorm
//
//  Created by Lobanov Dmitry on 03.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit
class BaseTableViewController: UIViewController {
    class BaseTableViewControllerEnhancements {
        weak var enchanted: BaseTableViewController?
        var refreshAvailable = false
        func apply() {
            if self.refreshAvailable {
                self.enchanted?.addRefresh()
            }
        }
        func configured(refreshAvailable: Bool = false) -> Self {
            self.refreshAvailable = refreshAvailable
            return self
        }
    }
    
    private(set) var style = UITableViewStyle.grouped
    var tableViewDelegate: UITableViewDelegate?
    var tableViewDataSource: UITableViewDataSource?
    private(set) var refreshControl: UIRefreshControl? = {
        var refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(BaseTableViewController.handleRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    var tableView: UITableView!
    var enhancements = BaseTableViewControllerEnhancements()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
}

//MARK: Setup
extension BaseTableViewController {
    @objc func setupController() {
        
    }
    
    @objc func setupUI() {
        self.setupTableView()
    }
    
    @objc func setupTableView() {
        self.tableView = self.createdTableView(tableView: self.createTableView(style: self.style))
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
    }
    
    @objc func setupDataSources() {
        self.tableView.delegate = self.tableViewDelegate
        self.tableView.dataSource = self.tableViewDataSource        
    }
    
    @objc func addConstraints() {
        if let superview = self.tableView.superview {
            let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": self.tableView])
            let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": self.tableView])
            superview.addConstraints(vertical + horizontal)
            let height = NSLayoutConstraint(item: self.tableView, attribute: .height, relatedBy: .equal, toItem: superview, attribute: .height, multiplier: 1, constant: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupController()
        self.setupUI()
        self.setupDataSources()
        self.enhancements.apply()
        self.addConstraints()
    }
}

//MARK: Configuration
extension BaseTableViewController {
    func configured(dataSource: UITableViewDataSource?) -> Self {
        self.tableViewDataSource = dataSource
        return self
    }
    
    func configured(delegate: UITableViewDelegate?) -> Self {
        self.tableViewDelegate = delegate
        return self
    }
}

//MARK: Refresh
extension BaseTableViewController {
    func addRefresh() {
        guard let refresh = self.refreshControl else {
            return
        }
        self.tableView.addSubview(refresh)
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl?) {
        
    }
}

//MARK: Setup Table View
extension BaseTableViewController {
    func createdTableView(tableView: UITableView) -> UITableView {
        return tableView
    }
    
    func setupedTableView(tableView: UITableView) -> UITableView {
        return tableView
    }
    
    func createTableView(style: UITableViewStyle) -> UITableView {
        return UITableView(frame: CGRect.zero, style: self.style)
    }
}


