//
//  SimilarItemTab.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftSpinner

class SimilarItemTab: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var similarItemView: UIView!
    @IBOutlet weak var similarItemErrorMessage: UILabel!
    var sortedSimilarItemList = [SimilarItem]();
    override func viewDidLoad() {
        SwiftSpinner.show("Fetching Similar Items...");
        super.viewDidLoad()
        collectionViewState.delegate = self;
        collectionViewState.dataSource = self;
        sortedSimilarItemList = similarItemList;
        switchBetweenAscAndDescState.isEnabled = false;
        if similarItemList.count == 0 {
            similarItemView.isHidden = true;
            similarItemErrorMessage.isHidden = false;
        } else {
            similarItemView.isHidden = false;
            similarItemErrorMessage.isHidden = true;
        }
        SwiftSpinner.hide();
    }
    
    // segmented Control
    @IBOutlet weak var switchSortRuleState: UISegmentedControl!
    @IBAction func switchSortRule(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sortedSimilarItemList = similarItemList;
            switchBetweenAscAndDescState.isEnabled = false;
            collectionViewState.reloadData();
        } else {
            switchBetweenAscAndDescState.isEnabled = true;
            reOrder();
        }
    }
    
    @IBOutlet weak var switchBetweenAscAndDescState: UISegmentedControl!
    @IBAction func switchBetweenAscAndDesc(_ sender: UISegmentedControl) {
        reOrder();
    }
    
    func reOrder(){
        let curIndex = switchSortRuleState.selectedSegmentIndex;
        let isAscend = switchBetweenAscAndDescState.selectedSegmentIndex == 0;
        if curIndex == 1 {
            if isAscend {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.title < $1.title});
            } else {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.title > $1.title});
            }
        }
        else if curIndex == 2 {
            if isAscend {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.price < $1.price});
            } else {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.price > $1.price});
            }
        }
        else if curIndex == 3 {
            if isAscend {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.daysLeft < $1.daysLeft});
            } else {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.daysLeft > $1.daysLeft});
            }
        }
        else if curIndex == 4 {
            if isAscend {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.shippingCost < $1.shippingCost});
            } else {
                sortedSimilarItemList = sortedSimilarItemList.sorted(by: {$0.shippingCost > $1.shippingCost});
            }
        }
        collectionViewState.reloadData();
    }
    
    // collection view
    @IBOutlet weak var collectionViewState: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedSimilarItemList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sortedSimilarItemList[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell;
        cell.setCollectionCell(item: item);
        cell.layer.cornerRadius = 8;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = UIColor.lightGray.cgColor;
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = sortedSimilarItemList[indexPath.row].viewItemURL;
        UIApplication.shared.open(URL(string: url)!);
    }
}
