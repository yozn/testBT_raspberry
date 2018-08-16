//
//  ConnectViewController.swift
//  testbt_raspberry
//
//  Created by 劉祐炘 on 2018/8/16.
//  Copyright © 2018年 yozn. All rights reserved.


import UIKit
import CoreBluetooth
class ConnectViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    @IBAction func sendAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Send to AIY", message: "請輸入服務代號", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text!)")
            let data = textField.text!.data(using: String.Encoding.utf8)
//            if let ch = self.characteristic{
//                
//                self.connectPeripheral?.writeValue(data!, for: ch, type: CBCharacteristicWriteType.withResponse)
//            }
            for ch in self.characteristicList{
                self.connectPeripheral?.writeValue(data!, for: ch, type: CBCharacteristicWriteType.withResponse)
            }
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var webView: UIWebView!
    var ServiceUUID1 = "180D"
    var characteristic: CBCharacteristic?
    var characteristicList:[CBCharacteristic] = []
    var connectPeripheral:CBPeripheral?
    var centralManager:CBCentralManager?
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未驗證")
        case .poweredOff:
            print("未啟動")
        case .poweredOn:
            print("可用")
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //connectPeripheral = peripheral
        peripheral.delegate = self
        
        peripheral.discoverServices(nil)
        print("連結成功2")
        //self.centralManager?.stopScan()
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("連接失敗")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("斷開連接")
        // 重新連接
        //central.connect(peripheral, options: nil)
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil){
            print("查找 services 时 \(String(describing: peripheral.name)) 报错 \(String(describing: error?.localizedDescription))")
        }
        for service: CBService in peripheral.services! {
            print("外設中的服務有：\(service)")
            print("Service uuid:\(service.uuid.uuidString)")
            if service.uuid.uuidString == ServiceUUID1{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        //本例的外設中只有一個服務
        //let service = peripheral.services?.last
        //print(service!)
        // 根據UUID尋找服務中的特徵
        //        peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
    }
    /** 發現特徵 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil{
            print("查找 characteristics 时 \(peripheral.name!) 报错 \(String(describing: error?.localizedDescription))")
        }
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外設中的特徵有：\(characteristic)")
            peripheral.readValue(for: characteristic)
            self.characteristicList.append(characteristic)
            //self.characteristic = characteristic
            //设置訂閱 characteristic 的 notifying 属性 为 true ， 表示接受广播
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        self.characteristic = service.characteristics?.last
        //        // 讀取特徵裏的數據
        //        peripheral.readValue(for: self.characteristic!)
        //        // 訂閲
        //        peripheral.setNotifyValue(true, for: self.characteristic!)
    }
    /** 接收到數據 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value{
            let array = [UInt8](data)
            print(array)
            
            
        }
        self.characteristic = characteristic
        //        let data = characteristic.value
        //        let temp = String.init(data: data!, encoding: String.Encoding.utf8)
        //        let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
        //        print("recv:\(String(describing: resultStr))")
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("寫入數據")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("next page")
//        centralManager = CBCentralManager.init(delegate: self, queue: .main)
        self.centralManager?.delegate = self
        self.centralManager?.connect(self.connectPeripheral!, options: nil)
        let path = Bundle.main.path(forResource: "範例/food_ok_html/食記  -[台北捷運行天宮站]-温咖啡 wen coffee 解憂咖啡館", ofType: "html")!
        let data: NSData = NSData(contentsOfFile:path)!
        let html = NSString(data: data as Data, encoding:String.Encoding.utf8.rawValue)
        
        self.webView .loadHTMLString(html! as String, baseURL: Bundle.main.bundleURL)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
