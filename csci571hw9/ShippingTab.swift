//
//  ShippingTab.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftSpinner

class ShippingTab: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    struct Header{
        var headerImage: UIImage;
        var headerTitle: String;
    }
    struct ASection {
        var header: Header;
        var content:[Pair];
    }
    var tableSectionArray = [ASection]();
    
    @IBOutlet weak var tableState: UITableView!
    
    override func viewDidLoad() {
        
        SwiftSpinner.show("Fetching Shipping Data...");
        
        super.viewDidLoad();
        if(seller.count > 0){
            tableSectionArray.append(ASection(header: Header(headerImage: UIImage(named: "icons8-shop-25")!, headerTitle: "Seller"), content: seller));
        }
        if(shipping.count > 0){
            tableSectionArray.append(ASection(header: Header(headerImage:  UIImage(named: "icons8-water-transportation-25")!, headerTitle: "Shipping Info"), content: shipping));
        }
        if(returnPolicy.count > 0){
            tableSectionArray.append(ASection(header: Header(headerImage: UIImage(named: "icons8-truck-25")!, headerTitle: "Return Policy"), content: returnPolicy));
        }
        
        tableState.delegate = self;
        tableState.dataSource = self;
        
        SwiftSpinner.hide();
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSectionArray[section].content.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell") as! contentCell
        let key = tableSectionArray[indexPath.section].content[indexPath.row].key;
        let value = tableSectionArray[indexPath.section].content[indexPath.row].value;
       cell.setContentCell(key: key, value: value);
        return cell;
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSectionArray.count;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! headerCell;
        cell.setHeaderCell(image: tableSectionArray[section].header.headerImage, header: tableSectionArray[section].header.headerTitle);
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = UIColor.lightGray.cgColor;
        return cell;
    }
}
