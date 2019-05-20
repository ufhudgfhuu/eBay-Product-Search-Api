//
//  ProductDetailViewController.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/14/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductDetailViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var scrollViewState: UIScrollView!
    @IBOutlet weak var pageControlState: UIPageControl!
    @IBOutlet weak var titleState: UILabel!
    @IBOutlet weak var priceState: UILabel!
    @IBOutlet weak var searchIconState: UIImageView!
    @IBOutlet weak var tableTitleState: UILabel!
    @IBOutlet weak var detailTableState: UITableView!
    
    var frame = CGRect(x:0, y:0, width:0, height:0);
    override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(ProductDetailViewController.reload), name: NSNotification.Name(rawValue: "reloader"), object: nil);
    }
    
    @objc func reload(notification: NSNotification){
        // set pagination numofpages
        pageControlState.numberOfPages = selectedItemImages.count;
        
        // add images to scroll view and set its size
        for i in 0..<selectedItemImages.count {
            frame.origin.x = scrollViewState.frame.size.width*CGFloat(i);
            frame.size = scrollViewState.frame.size;
            let imgView = UIImageView(frame: frame);
            let url = URL(string: selectedItemImages[i]);
            let data = try? Data(contentsOf: url!);
            imgView.contentMode = .scaleToFill
            imgView.image = UIImage(data: data!);
            self.scrollViewState.addSubview(imgView);
        }
        scrollViewState.contentSize = CGSize(width:(scrollViewState.frame.size.width*CGFloat(selectedItemImages.count)), height: scrollViewState.frame.size.height);
        scrollViewState.delegate = self;
        
        // set title and price
        titleState.text = selectedItem.title;
        priceState.text = selectedItemPrice;
        
        // set table
        if descriptionList.count == 0 {
            searchIconState.isHidden = true;
            tableTitleState.isHidden = true;
            detailTableState.isHidden = true;
        }
        detailTableState.delegate = self;
        detailTableState.dataSource = self;
        detailTableState.reloadData();
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollViewState.contentOffset.x / scrollViewState.frame.size.width;
        pageControlState.currentPage = Int(pageNumber);
    }

    // create the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descriptionList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aLine = descriptionList[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! descriptionCell;
        cell.setDescriptionCell(aLine: aLine);
        return cell;
    }
}
