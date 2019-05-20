//
//  GoogleTab.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftSpinner

class GoogleTab: UIViewController {
    @IBOutlet weak var scrollViewState: UIScrollView!
    
    override func viewDidLoad() {
        SwiftSpinner.show("Fetching Google Data...");
        super.viewDidLoad();
        
        for i in 0..<googleImageList.count {
            let imgView = UIImageView();
            let url = URL(string: googleImageList[i]);
            let data = try? Data(contentsOf: url!);
            if(data == nil){continue;}
            imgView.image = UIImage(data: data!);
            let yPosition = scrollViewState.frame.size.height*CGFloat(i)/2 + CGFloat(i)*120;
            imgView.frame = CGRect(x: 20, y: yPosition, width: scrollViewState.frame.size.width-40, height: scrollViewState.frame.size.height/2);
            scrollViewState.contentSize.height = scrollViewState.frame.width*CGFloat(i+1);
            scrollViewState.addSubview(imgView);
        }
        SwiftSpinner.hide();
    }
}
