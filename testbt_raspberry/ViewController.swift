//
//  ViewController.swift
//  testbt_raspberry
//
//  Created by 劉祐炘 on 2018/8/9.
//  Copyright © 2018年 yozn. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate ,UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        //print(peripherals)
        if let p = self.peripherals[indexPath.row]{
            
            if let name = p.name{
                
                cell.textLabel?.text = name
            }else{
                cell.textLabel?.text = p.identifier.uuidString
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.connectPeripheral = self.peripherals[indexPath.row]
        self.performSegue(withIdentifier: "ShowConnect", sender: nil)
//        centralManager?.connect(peripherals[indexPath.row]!, options: nil)
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBAction func scanAction(_ sender: Any) {
        self.centralManager?.delegate = self
        centralManager?.scanForPeripherals(withServices:nil, options: nil)
        
    }
    @IBAction func stopAction(_ sender: Any) {
        self.peripherals = []
        self.tableview.reloadData()
        centralManager?.stopScan()
    }
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral?] = []
    private var characteristic: CBCharacteristic?
    private var connectPeripheral:CBPeripheral?
    private var ServiceUUID1 = "180F"
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
//            let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey:
//                NSNumber(value: false)]
            //centralManager?.scanForPeripherals(withServices: nil, options: options)
//            central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
        }
    }
    //scan result
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("scan:\(self.peripherals.count)")
        //print(peripheral.name!)
        if !self.peripherals.contains(peripheral){
            self.peripherals.append(peripheral)
            self.tableview.reloadData()
        }
        
        
//        self.peripheral = peripheral
//        print(self.peripheral?.name)
//        print(self.peripheral?.identifier.uuidString)
        //print(self.peripheral?.name)
        // 根據外設名稱來過濾
        //        if (peripheral.name?.hasPrefix("WH"))! {
        //            central.connect(peripheral, options: nil)
        //        }
        //central.connect(peripheral, options: nil)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectPeripheral = peripheral
        peripheral.delegate = self
        
        peripheral.discoverServices(nil)
        print("連結成功")
        self.centralManager?.stopScan()
        
        
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let tag = sender as! Int
        if segue.identifier == "ShowConnect"{
            self.centralManager?.stopScan()
            let controller = segue.destination as! ConnectViewController
            controller.connectPeripheral = self.connectPeripheral
            controller.centralManager = self.centralManager
        }
        
    }


}

