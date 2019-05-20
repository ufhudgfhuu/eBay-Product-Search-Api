//
//  McTextField.swift
//  csci571hw9
//
//  Created by Jiaying  Luo on 4/23/19.
//  Copyright © 2019 Jiaying  Luo. All rights reserved.
//

import UIKit
import McPicker

open class McTextField: UITextField {

    public var doneHandler: McPicker.DoneHandler = { _ in }
    public var cancelHandler: McPicker.CancelHandler?
    public var selectionChangedHandler: McPicker.SelectionChangedHandler?
    public var textFieldWillBeginEditingHandler: ((_ selections: [Int:String]) -> Void)?
    
    public var inputViewMcPicker: McPicker? {
        didSet {
            self.delegate = inputViewMcPicker
        }
    }

}
