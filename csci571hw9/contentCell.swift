//
//  contentCell.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/15/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit

class contentCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var keyState: UILabel!
    @IBOutlet weak var valueState: UITextView!
    var tapLink:UITapGestureRecognizer = UITapGestureRecognizer()
    func setContentCell(key:String, value:String){
        keyState.text = key;

        tapLink.delegate = (valueState as! UIGestureRecognizerDelegate);
        if key == "Store Name" {
            // create the link
            tapLink = UITapGestureRecognizer(target: self, action: #selector( contentCell.openStorePage(_:) ));
            tapLink.numberOfTapsRequired = 1;
            valueState.addGestureRecognizer(tapLink);
            
            // style the link
            let attributedString = NSMutableAttributedString(string: value);
            let url = URL(string: storeLink)!
            
            // Set the 'click here' substring to be the link
            let myRange = NSRange(location: 0, length: value.count);
            attributedString.setAttributes([.link: url], range: myRange);
            
            valueState.attributedText = attributedString;
            valueState.isUserInteractionEnabled = true;
            valueState.isEditable = false;
            
            // Set how links should appear: blue and underlined
            valueState.linkTextAttributes = [
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            
            valueState.font = .systemFont(ofSize: 14);
        }
        else if key == "Feedback Star"{
        
            let starImage = NSTextAttachment();
            // set the image
            if(value.suffix(8) == "Shooting"){
                starImage.image = UIImage(named: "baseline_stars_black_18dp");
            } else {
                starImage.image = UIImage(named: "baseline_star_border_black_18dp");
            }
            // set the color
            var color = UIColor.lightGray;
            if value.prefix(5) == "Green" { color = UIColor.green; }
            else if value.prefix(6) == "Purple" { color = UIColor.purple; }
            else if value.prefix(3) == "Red" { color = UIColor.red; }
            else if value.prefix(6) == "Silver" {color = UIColor(red: 0.7529, green: 0.7529, blue: 0.7529, alpha: 1.0); }
            else if value.prefix(9) == "Turquoise" { color = UIColor(red: 0.251, green: 0.8784, blue: 0.8157, alpha: 1.0); }
            else if value.prefix(6) == "Yellow" { color = UIColor.orange; }
            starImage.image = starImage.image!.tint(with: color);

            let star = NSAttributedString(attachment: starImage);
            let text = NSMutableAttributedString(string: "");
            text.append(star);
            valueState.attributedText = text;
        }
        else { valueState.text = value; }
        valueState.textAlignment = .center;
    }
    
    // func openStorePage(){
    @objc func openStorePage(_ recognizer: UITapGestureRecognizer){
        if storeLink != "" {
            let url = URL(string: storeLink)!;
            UIApplication.shared.open(url);
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
}

extension UIImage {
    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
