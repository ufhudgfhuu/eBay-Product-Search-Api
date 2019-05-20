//
//  SearchResultsController.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/12/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire

class SearchResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     // create the table
    @IBOutlet weak var resultsTableState: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataList[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! productCell
        cell.setProductCell(item: item);
        cell.productWishListState.tag = indexPath.row;
        cell.productWishListState.isSelected = false;
        if defaults.object(forKey: dataList[indexPath.row].itemId) != nil {
            cell.productWishListState.isSelected = true;
        }
        // hight the selected item
        if item.itemId == selectedItem.itemId {
            cell.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0);
        } else {
             cell.backgroundColor = UIColor.white;
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = dataList[indexPath.row];
        self.performSegue(withIdentifier: "goToProductDetail", sender: self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(dataList.count == 0){ alert(); }
        resultsTableState.delegate = self;
        resultsTableState.dataSource = self;
    }
    
    func alert () {
        let alert = UIAlertController(title: "No Results!", message: "Failed to fetch search results", preferredStyle: UIAlertController.Style.alert);
        //alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}));
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil);
            _ = self.navigationController?.popViewController(animated: true);
        }));
        self.present(alert, animated: true, completion: nil);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultsTableState.reloadData();
    }
}
