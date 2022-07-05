//
//  InputRow.swift
//  Mocha
//
//  Created by Jake on 2/20/19.
//  Copyright © 2019 Mocha. All rights reserved.
//

import Foundation
import UIKit

public class TypedInputCell<T>: FormInputCell, UITextFieldDelegate {

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 20
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTapped))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleButton, doneButton], animated: false)

        textField.inputAccessoryView = toolbar
        textField.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var outputValue: Any? {
        let text = textField.text ?? ""
        switch T.self {
        case is String.Type:
            return text
        case is Double.Type:
            return (numberFormatter.number(from: text) ?? 0).doubleValue
        case is NSDecimalNumber.Type:
            let decimal = NSDecimalNumber(string: text)
            if decimal == NSDecimalNumber.notANumber {
                return NSDecimalNumber(0)
            }
                
            return decimal
        case is Date.Type:
            return dateFormatter.date(from: text)
        default:
            return nil
        }
    }

    // For iOS14, the picker shows directly in the row
    // For iOS < 14, the picker shows as the keyboard
    private var datePicker: UIDatePicker?

    func updateKeyboardType(row: any BaseRow) {
        switch T.self {
        case is String.Type:
            textField.keyboardType = .default
            textField.addTarget(self, action: #selector(textFieldValueChange(_ :)), for: .editingChanged)

        case is Double.Type, is NSDecimalNumber.Type:
            textField.keyboardType = .decimalPad
            textField.addTarget(self, action: #selector(textFieldValueChange(_ :)), for: .editingChanged)
            
        case is Date.Type:

            let datePicker = UIDatePicker()
            datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

            if #available(iOS 14, *) {
                self.datePicker = datePicker
                appendView(view: datePicker)
                textField.isHidden = true
            } else {
                textField.isHidden = false
                textField.inputView = datePicker
            }

            // Concrete type
            if let row = row as? TypedRow<Date> {
                datePicker.date = row.value
            }

        default:
            textField.keyboardType = .default
        }
    }

    public override func setup(_ row: any BaseRow) {

        titleLabel.text = row.title
        if let row = row as? TypedRow<Double>, row.value < Double.ulpOfOne {
            // clear the text so that user can start input from integer value
            textField.text = ""
        } else if let row = row as? TypedRow<NSDecimalNumber>, row.value == 0 {
            textField.text = ""

        } else if let row = row as? TypedRow<Double> {
            textField.text = numberFormatter.string(from: row.value as NSNumber)

        } else if let row = row as? TypedRow<NSDecimalNumber> {
            textField.text = String(describing: row.value)

        } else if let row = row as? TypedRow<Date> {
            textField.text = dateFormatter.string(from: row.value)

        } else {
            textField.text = row.description
        }

        updateKeyboardType(row: row)

        textField.placeholder = row.placeholder
    }

    @objc private func doneBtnTapped() {
        _ = resignFirstResponder()
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        textField.text = dateFormatter.string(from: sender.date)
        self.delegate?.cellDidChangeValue(self, value: outputValue)
    }

    @objc private func textFieldValueChange(_ sender: UITextField) {
        self.delegate?.cellDidChangeValue(self, value: outputValue)
    }

    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }

    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return textField.resignFirstResponder()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let inputView = textField.inputView else {
            return true
        }
        let isDatePicker = inputView.isKind(of: UIDatePicker.self)

        return !isDatePicker
    }
}
