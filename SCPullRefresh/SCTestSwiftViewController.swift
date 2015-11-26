//
//  SCTestSwiftViewController.swift
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/23.
//  Copyright © 2015年 Singro. All rights reserved.
//

import UIKit

@objc class SCTestSwiftViewController: SCPullRefreshViewController,UITableViewDelegate, UITableViewDataSource {

    override func loadView() {
        super.loadView()
        
        self.view!.backgroundColor = UIColor.redColor()
        
        self.configureTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshBlock = { () -> Void in
            
        }
        
        self.title = "xxxx"
        
        //        self.tableView = [[UITableView alloc] initWithFrame:self.scPullRefreshView.bounds style:UITableViewStylePlain];
        //        self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        //        self.tableView.dataSource      = self;
        //        self.tableView.delegate        = self;
        //        self.tableView.contentInsetTop = kNaviOffset;
        //        self.tableView.backgroundColor = kBackgroundColorGray;
        //        [self.scPullRefreshView addSubview:self.tableView];
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beginRefresh()
    }
    
    func configureTableView(){
        
        self.tableView = UITableView.init(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(self.tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "aaa"
        return cell
    }
}
