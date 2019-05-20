//
//  descriptionCellTableViewCell.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/14/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftyJSON

class descriptionCell: UITableViewCell {
    @IBOutlet weak var descriptionNameState: UILabel!
    @IBOutlet weak var descriptionValueState: UILabel!
    func setDescriptionCell(aLine : JSON){
        descriptionNameState.text = aLine["Name"].stringValue;
        descriptionValueState.text = aLine["Value"][0].stringValue;
    }
}
