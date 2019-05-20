//
//  headerCell.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit

class headerCell: UITableViewCell {

    @IBOutlet weak var imageState: UIImageView!
    @IBOutlet weak var headerState: UILabel!
    
    func setHeaderCell(image:UIImage, header:String){
        imageState.image = image;
        headerState.text = header;
    }
}
