//
//  collectionCell.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
class collectionCell: UICollectionViewCell {
    @IBOutlet weak var imageState: UIImageView!
    @IBOutlet weak var titleState: UILabel!
    @IBOutlet weak var shippingCostState: UILabel!
    @IBOutlet weak var daysLeftState: UILabel!
    @IBOutlet weak var priceState: UILabel!
    
    func setCollectionCell(item: SimilarItem){
        let url = URL(string: item.imageURL);
        let data = try? Data(contentsOf: url!);
        imageState.image = UIImage(data: data!);
        titleState.text = item.title;
        shippingCostState.text = "$ \(item.shippingCost)";
        if item.daysLeft > 1 {
            daysLeftState.text = "\(item.daysLeft) Days Left";
        } else {
            daysLeftState.text = "\(item.daysLeft) Day Left";
        }
        priceState.text = "$ \(item.price)";
    }
}
