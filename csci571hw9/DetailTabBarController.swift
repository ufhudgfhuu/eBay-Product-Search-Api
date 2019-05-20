//
//  DetailTabBarController.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/14/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import Toast_Swift

var selectedItemDetail = JSON.null;
var selectedItemPrice = "";
var selectedItemImages = [String]();
var descriptionList = [JSON]();
var storeLink = "";

struct Pair{
    var key: String;
    var value: String;
}
var seller = [Pair]();
var shipping = [Pair]();
var returnPolicy = [Pair]();

var googleImageList = [String]();

struct SimilarItem {
    var itemId: Int;
    var title: String;
    var price: Double;
    var shippingCost: Double;
    var daysLeft: Int;
    var viewItemURL: String;
    var imageURL: String;
}
var similarItemList = [SimilarItem]();

class DetailTabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        // open spinner
        SwiftSpinner.show("Fetching Product Details...");
        let url = nodeUrl + "/shopping/" + selectedItem.itemId;
        
        // clear global value
        seller.removeAll();
        shipping.removeAll();
        returnPolicy.removeAll();
        googleImageList.removeAll();
        similarItemList.removeAll();
        selectedItemDetail = JSON.null;
        
        // request url
        Alamofire.request(url).responseString { response in
            debugPrint(response)
            
            if let json = response.result.value {
                let jsonObj = JSON(parseJSON: json)
                selectedItemDetail = jsonObj["Item"];
                
                // price
                selectedItemPrice = "N/A";
                if (selectedItemDetail["CurrentPrice"]["Value"].exists()) {selectedItemPrice =  "$" + selectedItemDetail["CurrentPrice"]["Value"].stringValue; }
                
                // pictures
                selectedItemImages.removeAll();
                if (selectedItemDetail["PictureURL"].exists()) { selectedItemImages = selectedItemDetail["PictureURL"].arrayValue.map { $0.stringValue}; }
                
                // description
                descriptionList.removeAll();
                if (selectedItemDetail["ItemSpecifics"]["NameValueList"].exists()){
                    descriptionList = selectedItemDetail["ItemSpecifics"]["NameValueList"].arrayValue;
                }
                
                // get seller info for seller Tab
                storeLink = "";
                if(selectedItemDetail["Storefront"].exists()){
                    let tmpPair = Pair(key: "Store Name", value: selectedItemDetail["Storefront"]["StoreName"].stringValue);
                    storeLink = selectedItemDetail["Storefront"]["StoreURL"].stringValue;
                    seller.append(tmpPair);
                }
                
                if(selectedItemDetail["Seller"]["FeedbackScore"].exists()){
                    let tmpPair = Pair(key: "Feedback Score", value: selectedItemDetail["Seller"]["FeedbackScore"].stringValue);
                    if tmpPair.value != "None" { seller.append(tmpPair); }

                    
                    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!inside Detail tab, the seller feedbackScore is " + tmpPair.value);
                    

                }
                
                if(selectedItemDetail["Seller"]["PositiveFeedbackPercent"].exists()){
                    let tmpPair = Pair(key: "Popularity", value: selectedItemDetail["Seller"]["PositiveFeedbackPercent"].stringValue);
                    seller.append(tmpPair);
                }
                
                if(selectedItemDetail["Seller"]["FeedbackRatingStar"].exists()){
                    let tmpPair = Pair(key: "Feedback Star", value: selectedItemDetail["Seller"]["FeedbackRatingStar"].stringValue);
                    seller.append(tmpPair);
                }
                
                // get shipping info for shipping tab
                if(selectedItem.shippingCost != ""){
                    let tmpPair = Pair(key: "Shipping Cost", value: selectedItem.shippingCost);
                    shipping.append(tmpPair);
                }
                
                if(selectedItemDetail["GlobalShipping"].exists()){
                    var tmpPair = Pair(key: "Global Shipping", value: "No");
                    let allowGlobalShipping = selectedItemDetail["GlobalShipping"].boolValue;
                    if(allowGlobalShipping == true){ tmpPair.value = "Yes"; }
                    shipping.append(tmpPair);
                }
                
                if(selectedItem.handlingTime != ""){
                    let tmpPair = Pair(key: "Handling Time", value: selectedItem.handlingTime);
                    shipping.append(tmpPair);
                }
                
                // return policy info
                if selectedItemDetail["ReturnPolicy"].exists(){
                    if selectedItemDetail["ReturnPolicy"]["ReturnsAccepted"].exists() {
                        let tmpPair = Pair(key:"Policy", value:selectedItemDetail["ReturnPolicy"]["ReturnsAccepted"].stringValue);
                        returnPolicy.append(tmpPair);
                    }
                    
                    if selectedItemDetail["ReturnPolicy"]["Refund"].exists() {
                        let tmpPair = Pair(key: "Refund Mode", value: selectedItemDetail["ReturnPolicy"]["Refund"].stringValue);
                        returnPolicy.append(tmpPair);
                    }
                    
                    if(selectedItemDetail["ReturnPolicy"]["ReturnsWithin"].exists()){
                        let returnWithin = selectedItemDetail["ReturnPolicy"]["ReturnsWithin"].intValue;
                        var tmpValue = ""
                        if returnWithin > 1 {
                            tmpValue = "\(returnWithin) days";
                        } else {
                            tmpValue = "\(returnWithin) day";
                        }
                        let tmpPair = Pair(key: "Return Within", value: tmpValue);
                        returnPolicy.append(tmpPair);
                    }
                    
                    if selectedItemDetail["ReturnPolicy"]["ShippingCostPaidBy"].exists() {
                        let tmpPair = Pair(key: "Shipping Cost Paid By", value: selectedItemDetail["ReturnPolicy"]["ShippingCostPaidBy"].stringValue);
                        returnPolicy.append(tmpPair);
                    }
                }
            }
            
            // search for similar items
            let urlForSimilarItem = nodeUrl + "/similarItem/" + selectedItem.itemId;
            Alamofire.request(urlForSimilarItem).responseString { response in
                debugPrint(response)
                
                if let json = response.result.value {
                    let jsonObj = JSON(parseJSON: json);
                    let similarItemListObj = jsonObj["getSimilarItemsResponse"]["itemRecommendations"]["item"].arrayValue;
                    
                    for i in 0..<similarItemListObj.count {
                        var newItem = SimilarItem(itemId: 0, title: "", price: 0, shippingCost: 0, daysLeft: 0, viewItemURL: "", imageURL: "");
                        // add title
                        newItem.title = similarItemListObj[i]["title"].exists() ? similarItemListObj[i]["title"].stringValue : "";
                        // add viewItemURL
                        newItem.viewItemURL = similarItemListObj[i]["viewItemURL"].exists() ? similarItemListObj[i]["viewItemURL"].stringValue : "";
                        // add image
                        newItem.imageURL = similarItemListObj[i]["imageURL"].exists() ? similarItemListObj[i]["imageURL"].stringValue : "";
                        // add price
                        newItem.price = similarItemListObj[i]["buyItNowPrice"].exists() && similarItemListObj[i]["buyItNowPrice"]["__value__"].exists() ?
                            similarItemListObj[i]["buyItNowPrice"]["__value__"].doubleValue : 0;
                        // add shipping cost
                        newItem.shippingCost = similarItemListObj[i]["shippingCost"].exists() && similarItemListObj[i]["shippingCost"]["__value__"].exists() ?
                            similarItemListObj[i]["shippingCost"]["__value__"].doubleValue : 0;
                        // add itemId
                        newItem.itemId = similarItemListObj[i]["itemId"].intValue;
                        // add days left
                        if (similarItemListObj[i]["timeLeft"].exists()) {
                            var locOfP = -1;
                            var locOfD = -1;
                            let tmpValue = similarItemListObj[i]["timeLeft"].stringValue;
                            var j = 0;
                            for c in tmpValue {
                                if (c == "P" && locOfP == -1) { locOfP = j+1; }
                                if (c == "D" && locOfD == -1) { locOfD = j; }
                                j = j+1;
                            }
                            if(locOfP != -1 && locOfD != -1){
                                let start = String.Index(encodedOffset: locOfP)
                                let end = String.Index(encodedOffset: locOfD)
                                let substring = String(tmpValue[start..<end])
                                newItem.daysLeft = Int(substring)!;
                            }
                        }
                        similarItemList.append(newItem);
                    }
                    
                    // search google for pictures
                    let urlForGoogle = nodeUrl + "/googleSearch/" + selectedItem.title.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!;
                    Alamofire.request(urlForGoogle).responseString { response in
                        debugPrint(response)
                        if let json = response.result.value {
                            let jsonObj = JSON(parseJSON: json);
                            let itemList = jsonObj["items"].arrayValue;
                            for i in 0..<itemList.count {
                                googleImageList.append(itemList[i]["link"].stringValue);
                            }

                            // send the notification
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloader"), object: nil);
      
                            // close spinner
                            SwiftSpinner.hide();
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    
        // add navigation buttons
        let wishListButton =  UIBarButtonItem(image:  UIImage(named: "icons8-heart-outline-22")!, style: .plain, target: self, action: #selector(modifyWishList));
        if defaults.object(forKey: selectedItem.itemId) != nil {
            wishListButton.image =  UIImage(named: "icons8-heart-filled-outline-22")!;
        }
        
        let facebookButton =  UIBarButtonItem(image: UIImage(named: "icons8-facebook-f-24")!, style: .plain, target: self, action: #selector(shareToFacebook));
        self.navigationItem.rightBarButtonItems = [wishListButton, facebookButton];
        
    }
    
    @objc func shareToFacebook(){
        var facebookUrl = "Buy " + selectedItem.title + " for " + selectedItem.price + " from Ebay!";
        facebookUrl = facebookUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!;
        facebookUrl = facebookUrl.replacingOccurrences(of: "&", with: "%26")
        facebookUrl = "https://www.facebook.com/sharer/sharer.php?u=" + selectedItemDetail["ViewItemURLForNaturalSearch"].stringValue + "&quote=" + facebookUrl + "&hashtag=%23CSCI571Spring2019Ebay";
        let url = URL(string: facebookUrl)!;
        UIApplication.shared.open(url);
    }
    
    @objc func modifyWishList(sender: UIBarButtonItem){
        if defaults.object(forKey: selectedItem.itemId) != nil {
            sender.image =  UIImage(named: "icons8-heart-outline-22")!;
            defaults.removeObject(forKey: selectedItem.itemId);
            view.makeToast("\(selectedItem.title) was removed from wishList");
        } else {
            sender.image =  UIImage(named: "icons8-heart-filled-outline-22")!;
            let encoder = JSONEncoder();
            if let encoded = try? encoder.encode(selectedItem) {
                defaults.set(encoded, forKey: selectedItem.itemId);
            }
            view.makeToast("\(selectedItem.title) was added to wishList");
        }
    }
}

