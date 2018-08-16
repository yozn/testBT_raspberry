//
//  touchViewController.swift
//  testbt_raspberry
//
//  Created by 劉祐炘 on 2018/8/11.
//  Copyright © 2018年 yozn. All rights reserved.
//

import UIKit

class touchViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var botView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.botView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.checkAction))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.checkAction))
        swipeDown.direction = .down
        swipeUp.direction = .up
        self.botView.addGestureRecognizer(swipeUp)
        self.botView.addGestureRecognizer(swipeDown)
        self.textLabel.text = "上拉醫療卡"
        self.textLabel.center.y = self.botView.frame.height/2
        print(self.textLabel.center)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func checkAction(sender:UISwipeGestureRecognizer){
        
        //let point = botView.center
        
        if sender.direction == .up {
            print("go up")
            UIView.animate(withDuration: 0.4){
                self.botView.frame.size.height = 600
                self.botView.center.y = self.view.center.y
                self.textLabel.center.y = self.view.center.y
                self.textLabel.text = "醫療卡"
                
            }
            
//            if point.y >= 150{
//                botView.center = CGPoint(x: botView.center.x, y: botView.center.y - 100)
//            }else{
//                botView.center = CGPoint(x: botView.center.x, y: 50)
//            }
        }else{
            UIView.animate(withDuration: 0.4){
                self.botView.frame.size.height = 254
                self.botView.center.y = self.view.bounds.height - 20 - self.botView.frame.height/2
                self.textLabel.center.y = self.botView.frame.height/2
                self.textLabel.text = "上拉醫療卡"
            }
        }
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
