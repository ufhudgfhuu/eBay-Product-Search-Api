//
//  ViewController.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/9/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Toast_Swift
import McPicker

struct ItemData: Codable {
    var itemId: String;
    var image: String;
    var title: String;
    var price: String;
    var shipping: String;
    var zip: String;
    var condition: String;
    var shippingCost: String;
    var handlingTime: String;
}

var dataList = [ItemData]();
var wishList = [ItemData]();
var selectedItem = ItemData(itemId: "", image: "", title: "", price: "", shipping: "", zip: "", condition: "", shippingCost: "", handlingTime: "");

let nodeUrl = "http://csci571hw8-236103.appspot.com";

var totalAmount: Double = 0;

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var curZip = ""
    var zipCodes = [String?](repeating: nil, count: 5);
    
    // keyword
    @IBOutlet weak var keywordInputState: UITextField!
    // categories
    @IBOutlet weak var categoryInput: McTextField!
    
    // start function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the current view
        formView.isHidden = false;
        wishListView.isHidden = true;
        
        let data: [[String]] = [["All", "Art", "Baby", "Books", "Clothing, Shoes & Accessories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles"]];
        
        let mcInputView = McPicker(data: data);
        mcInputView.backgroundColor = .gray;
        mcInputView.backgroundColorAlpha = 0.25;
        categoryInput.inputViewMcPicker = mcInputView;
        categoryInput.doneHandler = { [weak categoryInput] (selections) in
            categoryInput?.text = selections[0]!;
        }
        categoryInput.selectionChangedHandler = { [weak categoryInput] (selections, componentThatChanged) in
            categoryInput?.text = selections[componentThatChanged]!
        }
        categoryInput.cancelHandler = { [weak categoryInput] in
            categoryInput?.text = "All"
        }
        categoryInput.textFieldWillBeginEditingHandler = { [weak categoryInput] (selections) in
            if categoryInput?.text == "" {
                // Selections always default to the first value per component
                categoryInput?.text = selections[0]
            }
        }
        categoryInput?.text = "All";

        // get the current zip
        Alamofire.request("http://ip-api.com/json").responseString { response in
            debugPrint(response)
            
            if let json = response.result.value {
                let jsonObj = JSON(parseJSON: json)
                self.curZip = jsonObj["zip"].stringValue
            }
        }
        
        // set for autocomplete
        zipCodeList.delegate = self;
        zipCodeList.dataSource = self;
        zipCodeList.isHidden = true;
        zipCodeList.layer.borderWidth = 2.0;
        zipCodeList.layer.borderColor = UIColor.gray.cgColor;
        zipCodeList.layer.cornerRadius = 4;
        
        // button style
        searchButtonState.layer.cornerRadius = 4;
        clearButtonState.layer.cornerRadius = 4;
        
        // set for wishList
        wishListTable.delegate = self;
        wishListTable.dataSource = self;
        
        // set for input zip code
        zipCodeSwitchState.isOn = false;
        zipCodeInputState.isHidden = true;
        
        // let button occupy space
        searchButtonState.frame = CGRect(x: 44, y: 400, width: 132, height: 30);
        clearButtonState.frame = CGRect(x: 206, y: 400, width: 132, height: 30);
    
    }
    
    // switch between form and wish list
    @IBOutlet weak var wishListTable: UITableView!
    @IBOutlet weak var wishListErrorMessage: UILabel!
    @IBOutlet weak var switchViewState: UISegmentedControl!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var wishListView: UIView!
    @IBOutlet weak var lenOfWishListLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            formView.isHidden = false;
            wishListView.isHidden = true;
        } else {
            formView.isHidden = true;
            wishListView.isHidden = false;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // read data from userdefaults into wishlist
        wishList.removeAll();
        totalAmount = 0;
        for (key, _) in defaults.dictionaryRepresentation() {
            if let savedItems = defaults.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let loadedItem = try? decoder.decode(ItemData.self, from: savedItems) {
                    wishList.append(loadedItem);
                    totalAmount += Double(loadedItem.price.dropFirst())!;
                }
            }
        }
        wishListTable.reloadData();
        lenOfWishListLabel.text = "WishList Total(\(wishList.count) items):";
        totalAmountLabel.text = "$\(totalAmount)"
        
        // show error message
        if wishList.count == 0 {
            wishListTable.isHidden = true;
            lenOfWishListLabel.isHidden = true;
            totalAmountLabel.isHidden = true;
            wishListErrorMessage.isHidden = false;
        } else {
            wishListTable.isHidden = false;
            lenOfWishListLabel.isHidden = false;
            totalAmountLabel.isHidden = false;
            wishListErrorMessage.isHidden = true;
        }
    }
    
    // condition checkboxes
    @IBOutlet weak var checkboxNewState: UIButton!
    @IBAction func checkBoxNew(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false;
        } else {
            sender.isSelected = true
        }
    }
    
    @IBOutlet weak var checkboxUsedState: UIButton!
    @IBAction func checkboxUsed(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false;
        } else {
            sender.isSelected = true
        }
    }
    
    @IBOutlet weak var checkboxUnspecidiedState: UIButton!
    @IBAction func checkboxUnspecidied(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false;
        } else {
            sender.isSelected = true
        }
    }
    
    // shipping checkboxes
    @IBOutlet weak var checkboxPickupState: UIButton!
    @IBAction func checkboxPickup(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false;
        } else {
            sender.isSelected = true
        }
    }
    
    @IBOutlet weak var checkboxFreeShippingState: UIButton!
    @IBAction func checkboxFreeShipping(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false;
        } else {
            sender.isSelected = true
        }
    }
    
    // distance
    @IBOutlet weak var distanceInputState: UITextField!
    
    // switch button
    @IBOutlet weak var zipCodeSwitchState: UISwitch!
    @IBAction func zipCodeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            zipCodeInputState.isHidden = false;
            searchButtonState.frame = CGRect(x: 44, y: 435, width: 132, height: 30);
            clearButtonState.frame = CGRect(x: 206, y: 435, width: 132, height: 30);
        } else {
            zipCodeInputState.isHidden = true;
            searchButtonState.frame = CGRect(x: 44, y: 400, width: 132, height: 30);
            clearButtonState.frame = CGRect(x: 206, y: 400, width: 132, height: 30);
        }
    }
    
    // custom zip code input
    @IBOutlet weak var zipCodeInputState: UITextField!
    
    @IBAction func zipCodeInputChange(_ sender: UITextView) {
        if(sender.text! == ""){
            zipCodeList.isHidden = true;
            return;
        }
        
        zipCodeList.isHidden = false;
        let url = "\(nodeUrl)/autocomplete/\(sender.text!)"
        
        Alamofire.request(url).responseString { response in
            debugPrint(response)
            if let json = response.result.value {
                let jsonObj = JSON(parseJSON: json)
                let locArray = jsonObj["postalCodes"];
                if(locArray.count == 0){
                    self.zipCodeList.isHidden = true;
                    return;
                }
                var len = 0;
                
                for i in 0 ..< self.zipCodes.count {
                    if(i < locArray.count){
                        self.zipCodes[len] = locArray[i]["postalCode"].stringValue;
                        print(self.zipCodes[len]!)
                    } else {self.zipCodes[len] = nil; }
                    len = len + 1;
                }
                self.zipCodeList.reloadData();
            }
        }
    }

    // autocomplete tableView & wishlist tableView
    @IBOutlet weak var zipCodeList: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == zipCodeList { return zipCodes.count; }
 
        return wishList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == zipCodeList {
            var cell = tableView.dequeueReusableCell(withIdentifier: "zipCode");
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "zipCode")
            }
            cell?.textLabel?.text = zipCodes[indexPath.row];
            return cell!;
        }
        
        print("current item is \(wishList[indexPath.row])");
        let item = wishList[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCellInWishList") as! productCell;
        cell.setProductCell(item: item);
        // hight the selected item
        if item.itemId == selectedItem.itemId {
            cell.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0);
        } else {
            cell.backgroundColor = UIColor.white;
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == zipCodeList {
            zipCodeInputState.text = zipCodes[indexPath.row];
            zipCodeList.isHidden = true;
            return;
        }
   
        selectedItem = wishList[indexPath.row];
        self.performSegue(withIdentifier: "fromWishListToDetail", sender: self);
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if( tableView == zipCodeList ){ return false; }
        else{ return true; }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove from userdefaults
            defaults.removeObject(forKey: wishList[indexPath.row].itemId);
            // print out the total amount
            totalAmount -= Double(wishList[indexPath.row].price.dropFirst())!;
            totalAmountLabel.text = "$\(totalAmount)";
            view.makeToast("\(wishList[indexPath.row].title) was removed from wishList");
            // remove from wishList
            wishList.remove(at: indexPath.row);
            // print current number of items
            lenOfWishListLabel.text = "WishList Total(\(wishList.count) items):";
            // if no item in userdefaults, show error message
            if wishList.count == 0 {
                wishListTable.isHidden = true;
                lenOfWishListLabel.isHidden = true;
                totalAmountLabel.isHidden = true;
                wishListErrorMessage.isHidden = false;
            }
            tableView.beginUpdates();
            tableView.deleteRows(at: [indexPath], with: .automatic);
            tableView.endUpdates();
        }
    }
    
    // search button
    @IBOutlet weak var searchButtonState: UIButton!
    @IBAction func validateAndSearch(_ sender: UIButton) {
        // start validation
        guard var keyword = keywordInputState.text, keywordInputState.text!.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 else {
            view.makeToast("Keyword is Mandatory");
            return;
        }
        keyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!;
 
        var zipCode = curZip
        if !zipCodeInputState.isHidden {
            if zipCodeInputState.text!.count > 0 {
                zipCode = zipCodeInputState.text!
            } else {
                view.makeToast("Zipcode is Mandatory");
                return;
            }
        }
        
        // open spinner
        SwiftSpinner.show("Searching...")
        
        // get the information and create an Url
        var dict:[String: String] = ["All": "-1", "Art" : "550", "Baby": "2984", "Books": "267", "Clothing, Shoes & Accessories": "11450", "Computers/Tablets & Networking": "58058", "Health & Beauty": "26395", "Music": "11233", "Video Games & Consoles": "1249"]
        let category = dict[categoryInput.text!]!
        
        let distance = distanceInputState.text!.count > 0 ? distanceInputState.text! : "10"
        
        var conditions = "";
        if(checkboxNewState.isSelected){ conditions += "New";}
        if(checkboxUsedState.isSelected){
            if(conditions != ""){ conditions += ","; }
            conditions += "Used";
        }
        if(checkboxUnspecidiedState.isSelected){
            if(conditions != ""){ conditions += ","; }
            conditions += "Unspecified";
        }
        if (conditions != "") {conditions = "&conditionOptions=" + conditions; }
        
        var shipOptions = "";
        if(checkboxPickupState.isSelected){ shipOptions += "LocalPickupOnly"; }
        if(checkboxFreeShippingState.isSelected){
            if(shipOptions != ""){ shipOptions += ",";}
            shipOptions += "FreeShippingOnly";
        }
        if (shipOptions != "") { shipOptions = "&shipOptions=" + shipOptions; }
        
        let url = "\(nodeUrl)/productSearchForm?keywords=\(keyword)&category=\(category)&postalCode=\(zipCode)&distance=\(distance)\(shipOptions)\(conditions)";
        
        // make a request
        callEbayFindingApi(url: url);
    }
    
    func callEbayFindingApi(url: String){
        Alamofire.request(url).responseString { response in
            debugPrint(response)
            if let json = response.result.value {
                let jsonObj = JSON(parseJSON: json)
                
                // share data between storyboards
                dataList.removeAll();
                if (jsonObj["findItemsAdvancedResponse"][0]["searchResult"][0]["item"] != JSON.null) {
                    let itemList =  jsonObj["findItemsAdvancedResponse", 0, "searchResult", 0, "item"];
                    
                    // The `index` is 0..<json.count's string value
                    for (_,subJson):(String, JSON) in itemList {
                        var newItem = ItemData(itemId: "", image: "", title: "", price: "", shipping: "", zip: "", condition: "", shippingCost: "", handlingTime: "");
                        // add image
                        if (subJson["galleryURL"] == JSON.null) {
                            newItem.image = "N/A";
                        } else {newItem.image = subJson["galleryURL"][0].stringValue; }
                        
                        // add title
                        if (subJson["title"] == JSON.null) {newItem.title = "N/A"; }
                        else {newItem.title = subJson["title"][0].stringValue; }
                        
                        // add price
                        if (subJson["sellingStatus"] == JSON.null || subJson["sellingStatus"][0]["currentPrice"] == JSON.null
                            || subJson["sellingStatus"][0]["currentPrice"][0]["__value__"] == JSON.null
                            || subJson["sellingStatus"][0]["currentPrice"][0]["@currencyId"] == JSON.null) {newItem.price = "N/A"; }
                        else { newItem.price = "$" + subJson["sellingStatus"][0]["currentPrice"][0]["__value__"].stringValue; }
                        
                        // add shipping
                        if (subJson["shippingInfo"] == JSON.null || subJson["shippingInfo"][0]["shippingServiceCost"] == JSON.null
                            || subJson["shippingInfo"][0]["shippingServiceCost"][0]["__value__"] == JSON.null
                            || subJson["shippingInfo"][0]["shippingServiceCost"][0]["@currencyId"] == JSON.null) {newItem.shipping = "N/A"; }
                        else {
                            let shippingCostInfo = subJson["shippingInfo"][0]["shippingServiceCost"][0];
                            newItem.shipping = shippingCostInfo["__value__"].stringValue == "0.0" ? "Free Shipping" : "$" + shippingCostInfo["__value__"].stringValue;
                        }
                        
                        // add zip
                        if (subJson["postalCode"] == JSON.null) { newItem.zip = "N/A"; }
                        else {newItem.zip = subJson["postalCode"][0].stringValue; }
                        
                        // condition
                        newItem.condition = "NA";
                        if(subJson["condition"] != JSON.null && subJson["condition"][0]["conditionId"] != JSON.null){
                            let conditonId: String = subJson["condition"][0]["conditionId"][0].stringValue;
                            if conditonId == "1000" {  newItem.condition = "NEW"; }
                            else if conditonId == "2000" || conditonId == "2500" {  newItem.condition = "REFURBISHED"; }
                            else if conditonId == "3000" || conditonId == "4000" || conditonId == "5000" || conditonId == "6000" {  newItem.condition = "USED"; }
                        }
                        
                        // add itemId
                        newItem.itemId = subJson["itemId"][0].stringValue;
 
                        // get shipping info for shipping tab
                        if subJson["shippingInfo"].exists() {
                            if (subJson["shippingInfo"][0]["shippingServiceCost"].exists() &&
                                subJson["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].exists()) {
                                let shippingCost = subJson["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].doubleValue;
                                newItem.shippingCost = shippingCost == 0.0 ? "FREE" : "$\(shippingCost)";
                            }
                            if (subJson["shippingInfo"][0]["handlingTime"].exists()) {
                                let handlingTime = subJson["shippingInfo"][0]["handlingTime"][0].intValue;
                                if handlingTime > 1 {
                                    newItem.handlingTime = "\(handlingTime) days";
                                } else {
                                    newItem.handlingTime = "\(handlingTime) day";
                                }
                            }
                        }
                        dataList.append(newItem);
                    }
                }
                // close spinner
                SwiftSpinner.hide();
            }
            // send data to next viewController
            self.performSegue(withIdentifier: "goToSearchResult", sender: self)
        }
    }
    
    // clear button
    @IBOutlet weak var clearButtonState: UIButton!
    @IBAction func clear(_ sender: Any) {
        // clear keyword input
        keywordInputState.text = "";
        // set category input to default value
        categoryInput?.text = "All";
        // clear checkbox value
        checkboxNewState.isSelected = false;
        checkboxUsedState.isSelected = false;
        checkboxUnspecidiedState.isSelected = false;
        checkboxPickupState.isSelected = false;
        checkboxFreeShippingState.isSelected = false;
        // clear distance input
        distanceInputState.text = "";
        // set state of input zip code
        zipCodeSwitchState.isOn = false;
        zipCodeInputState.text = "";
        zipCodeInputState.isHidden = true;
        searchButtonState.frame = CGRect(x: 44, y: 400, width: 132, height: 30);
        clearButtonState.frame = CGRect(x: 206, y: 400, width: 132, height: 30);
        // hide zipCodeList Table
        zipCodeList.isHidden = true;
    }    
}

