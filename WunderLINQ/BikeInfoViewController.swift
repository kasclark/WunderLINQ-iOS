//
//  BikeInfoViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/9/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import CoreBluetooth
import UIKit
import MessageUI
import MobileCoreServices

class BikeInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let bleData = BLE.shared
    let motorcycleData = MotorcycleData.shared
    let wlqData = WLQ.shared
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var resetPickerData: [String] = [String]()
    
    @IBOutlet weak var vinValueLabel: UILabel!
    @IBOutlet weak var nextServiceDateLabel: UILabel!
    @IBOutlet weak var nextServiceLabel: UILabel!
    @IBOutlet weak var clusterResetHeaderLabel: LocalisableLabel!
    @IBOutlet weak var clusterResetLabel: LocalisableLabel!
    @IBOutlet weak var clusterResetTypePicker: UIPickerView!
    @IBOutlet weak var clusterResetButton: LocalisableButton!
    
    @objc func leftScreen() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        if (self.peripheral != nil && self.characteristic != nil){
            print("Resetting Cluster Data Point")
            switch (clusterResetTypePicker.selectedRow(inComponent: 0)){
            case 0: // Reset Cluster Average Speed
                let resetCommand:[UInt8] = [0x57, 0x57, 0x44, 0x52, 0x53]
                let writeData =  Data(_: resetCommand)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                break;
            case 1: // Reset Cluster Economy 1
                let resetCommand:[UInt8] = [0x57, 0x57, 0x44, 0x52, 0x45, 0x01]
                let writeData =  Data(_: resetCommand)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                break;
            case 2: // Reset Cluster Economy 2
                let resetCommand:[UInt8] = [0x57, 0x57, 0x44, 0x52, 0x45, 0x02]
                let writeData =  Data(_: resetCommand)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                break;
            case 3: // Reset Cluster Trip 1
                let resetCommand:[UInt8] = [0x57, 0x57, 0x44, 0x52, 0x54, 0x01]
                let writeData =  Data(_: resetCommand)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                break;
            case 4: // Reset Cluster Trip 2
                let resetCommand:[UInt8] = [0x57, 0x57, 0x44, 0x52, 0x54, 0x02]
                let writeData =  Data(_: resetCommand)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                break;
            default:
                break;
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("bike_info_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        // Connect data
        self.clusterResetTypePicker.delegate = self
        self.clusterResetTypePicker.dataSource = self
        resetPickerData = [NSLocalizedString("avgspeed_header", comment: ""), NSLocalizedString("fueleconomyone_header", comment: ""), NSLocalizedString("fueleconomytwo_header", comment: ""), NSLocalizedString("trip1_label", comment: ""), NSLocalizedString("trip2_label", comment: "")]
        
        peripheral = bleData.peripheral
        characteristic = bleData.cmdCharacteristic
        
        if (motorcycleData.vin != nil){
            vinValueLabel.text = motorcycleData.getVIN()
        }
        if (motorcycleData.nextServiceDate != nil){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/d"
            nextServiceDateLabel.text = formatter.string(from: motorcycleData.getNextServiceDate())
        }
        if (motorcycleData.nextService != nil){
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                nextServiceLabel.text = "\(Int(round(Utility.kmToMiles(Double(motorcycleData.getNextService())))))(mi)"
            } else {
                nextServiceLabel.text = "\(motorcycleData.getNextService())(km)"
            }
        }
        if (wlqData.getfirmwareVersion() != "Unknown"){
            let firmwareVersion: Double = wlqData.getfirmwareVersion().toDouble() ?? 0.0
            if (firmwareVersion >= 1.8){
                clusterResetHeaderLabel.isHidden = false
                clusterResetLabel.isHidden = false
                clusterResetTypePicker.isHidden = false
                clusterResetButton.isHidden = false
            }
        }
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return resetPickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return resetPickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
}
