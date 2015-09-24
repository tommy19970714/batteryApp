//
//  ViewController.swift
//  batteryApp
//
//  Created by 冨平準喜 on 9/24/15.
//  Copyright © 2015 冨平準喜. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    //時間計測用の変数.
    var cnt : Float = 0
    //タイマー.
    var timer : NSTimer!
    
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    @IBOutlet weak var sendLabel: UILabel!
    
    //デバイスとバッテリー残量の宣言.
    let myDevice: UIDevice = UIDevice.currentDevice()
    
    //コアロケーション
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //バッテリー状態の監視.
        myDevice.batteryMonitoringEnabled = true
        
        
        //location managerの設定
        self.locationManager.delegate = self
        //距離のフィルタ
        locationManager.distanceFilter = 100.0
        //精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.locationManager.requestAlwaysAuthorization()
        }
        //位置情報の更新を開始.
        self.locationManager.startUpdatingLocation()

        
        
        //タイマーを作る.
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
        
        let sendObject = PFObject(className: "BatteryObject")
        sendObject["mode"] = "Start App"
        sendObject["percent"] = 0
        sendObject["time"] = 0
        sendObject.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if (success) {
                // The object has been saved.
                self.sendLabel.text = "success"
            } else {
                // There was a problem, check error.description
                self.sendLabel.text = "error"
            }
            
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func onUpdate(timer : NSTimer){
        
        let coordinate = locationManager.location?.coordinate
        print(coordinate?.latitude)
        print(coordinate?.longitude)
        
        
        cnt += 1
        
        //桁数を指定して文字列を作る.
        let str = "Time:".stringByAppendingFormat("%.1f",cnt)
        
        print(str)
        
        
        let myBatteryLevel = myDevice.batteryLevel
        let myBatteryState = myDevice.batteryState
        var nowState:String = ""
        
        switch (myBatteryState) {
            
        case .Full:
            self.view.backgroundColor = UIColor.cyanColor()
            nowState = "Full"
            
        case .Unplugged:
            self.view.backgroundColor = UIColor.redColor()
            nowState = "Unplugged"
            
        case .Charging:
            self.view.backgroundColor = UIColor.blueColor()
            nowState = "Charging"
            
        case .Unknown:
            self.view.backgroundColor = UIColor.grayColor()
            nowState = "Unknown"
        }
        percentLabel.text = "\(myBatteryLevel*100) %"
        modeLabel.text = nowState
        
        let sendObject = PFObject(className: "BatteryObject")
        sendObject["mode"] = nowState
        sendObject["percent"] = myBatteryLevel
        sendObject["time"] = cnt
        sendObject.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if (success) {
                // The object has been saved.
                self.sendLabel.text = "success"
            } else {
                // There was a problem, check error.description
                self.sendLabel.text = "error"
            }
            
            
        }
    }


}

