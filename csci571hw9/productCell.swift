//
//  productCell.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/13/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import Toast_Swift

protocol productCellDelegate{
    func showMessage();
}

let defaults = UserDefaults.standard;

class productCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productShippingCost: UILabel!
    @IBOutlet weak var productZip: UILabel!
    @IBOutlet weak var productCondition: UILabel!    
    @IBOutlet weak var productWishListState: UIButton!
    @IBAction func productWishList(_ sender: UIButton) {
        let index = sender.tag;
        if sender.isSelected {
            sender.isSelected = false;
            defaults.removeObject(forKey: dataList[index].itemId);
            self.superview?.makeToast("\(dataList[index].title) was removed from wishList");
        } else {
            sender.isSelected = true;
            let encoder = JSONEncoder();
            if let encoded = try? encoder.encode(dataList[index]) {
                defaults.set(encoded, forKey: dataList[index].itemId)
            }
            self.superview?.makeToast("\(dataList[index].title) was added to wishList");
        }
    }
    func setProductCell(item: ItemData){
        let url = URL(string: item.image);
        let data = try? Data(contentsOf: url!);
        productImage.image = UIImage(data: data!);
        productTitle.text = item.title;
        productPrice.text = item.price;
        productShippingCost.text = item.shipping;
        productZip.text = item.zip;
        productCondition.text = item.condition;
    }
}
