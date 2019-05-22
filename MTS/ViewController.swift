//
//  ViewController.swift
//  MTS
//
//  Created by Rand Dow on 4/29/19.
//  Copyright © 2019 Rand Dow. All rights reserved.
//

import UIKit
import Network

class ViewController: UIViewController {
    
    var client: MTSClient?
    
    var screenWidth: Int?
    var screenHeight: Int?
    
    let border = 5
    let topOffset = 88
    let bottomOffset = 20
    
    let inputHeight = 31    // standard height for UITextField and UIButton
    let inputWidth = 250
    let buttonWidth = 100
    let chBoxWidth = 22
    let interChk = 7
    let tlsLabWidth = 35
    let interButton = 20
    
    var tfURL: UITextField?
    var tfUser: UITextField?
    var tfPwd: UITextField?
    var tfRoomId: UITextField?
    var btConn: UIButton?
    var tlsLab: UIButton?
    var ckBox: UIButton?
    var btPing: UIButton?
    var btDisconn: UIButton?
    var tView: UITextView?
    
    var useTls = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loaditjjsfnrhng the view.
        self.view.backgroundColor = .lightGray
        let screenRect = UIScreen.main.bounds
        screenWidth = Int(screenRect.size.width)
        screenHeight = Int(screenRect.size.height)
        print(screenWidth!, screenHeight!)
        
        createSubviews()
        displayConnect()
    }
    
    @objc func buttonConnect(sender: UIButton!) {
       
        if (useTls) {
            Log("Connecting (with TLS) ...")
        } else {
            Log("Connecting (no TLS) ...")
        }
        
        client = MTSClient(log: Log, url: tfURL!.text!, mtsRcvr: mtsReceiver, connCB: connectCallback)
        if (useTls) {
            client!.WithTLS(certificate: nil)
        }
        client!.Connect()
    }
    
    func connectCallback()
    {
        let jsonEncoder = JSONEncoder()
        var jsonData: Data
        if (useTls) {
            // connected to FrontDeskServer -- get PP type stuff
            // let login = Login(user:tfUser!.text!, password:tfPwd!.text!, appId:AppId.RMSRmNd, appKey:Data())
            //        var jsonData : Data
            //        do {
            //            jsonData = try jsonEncoder.encode(login)
            //        } catch {
            //            print("json convert error")
            //        }
            //
            //        client!.send(mtsMessage)
            
        } else {
            // connected to RMSServer -- get Room NodeIds
            Log("get Room data")
            let rmReq = tfRoomId!.text
            do {
                jsonData = try jsonEncoder.encode(rmReq)
            } catch {
                Log("json convert error")
            }
//            let mtsRequest = MTSMessage(route: MTSRequest.RoomsMap, jwt: "", data: jsonData)
//            do {
//                jsonData = try jsonEncoder.encode(MTSRequest)
//            } catch {
//                Log("json convert error")
//            }
//            client!.sendAwait(jsonData)
        }
         displayConnected()
    }
    
    @objc func buttonPing(sender: UIButton!) {
        Log("Ping...")
       
    }
  
    @objc func buttonDisconnect(sender: UIButton!) {
        displayConnect()
        client?.Stop(status: "shutting down")
        Log("disconnected")
    }
    
    func mtsReceiver(_ mtsMessage: MTSMessage) {
        Log("mtsMessage \(mtsMessage)")
        let jsonDecoder = JSONDecoder()

        print(mtsMessage.Route)
        switch MTSRequest(rawValue: mtsMessage.Route)! {
        case .Login:
            break
        case .OplCommands:
            do {
                //let oplCommands = try jsonDecoder.decode(OPLCommands.self, from: mtsMessage.Json.data(using: .utf8)!)
            
//                for (key, value) in oplCommands.OPLLists {
//                    print("\(key) -> \(value)")
//                }
            } catch {
                Log("OPLCommands json convert error")
            }
            break
        default:
            break
        }
    }
    
    func Log(_ text: String) -> Void {
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        tView!.text += "\(dateFormatter.string(from: currentDateTime)) \(text)\n"
        print(text)
        let range = NSMakeRange(tView!.text.count - 1, 0)
        tView!.scrollRangeToVisible(range)
        self.reloadInputViews()
    }
    
    func createSubviews() {
        
        let inputOffset = (screenWidth! - inputWidth) / 2
        let buttonOffset = (screenWidth! - buttonWidth - interButton - buttonWidth) / 2
        let buttonOffset2 = (screenWidth! - chBoxWidth - interButton - tlsLabWidth - interButton - buttonWidth) / 2
        
        // connect to RMS Server
        tfURL = UITextField(frame: CGRect(x:inputOffset, y:topOffset+border, width:inputWidth, height:inputHeight))
        tfURL!.borderStyle = .roundedRect
        tfURL!.placeholder = "127.0.0.1:10002"
        tfURL!.text = "172.20.10.5:10001"
        //tfURL!.text = "172.20.10.5:10002"
        tfURL!.backgroundColor = UIColor.white
        tfURL!.textColor = UIColor.blue
        
        tfUser = UITextField(frame: CGRect(x:inputOffset, y:topOffset+2*border+inputHeight, width:inputWidth, height:inputHeight))
        tfUser!.borderStyle = .roundedRect
        tfUser!.text = "OnityTech"
        tfUser!.placeholder = "user"
        tfUser!.backgroundColor = UIColor.white
        tfUser!.textColor = UIColor.blue
        
        tfPwd = UITextField(frame: CGRect(x:inputOffset, y:topOffset+3*border+2*inputHeight, width:inputWidth, height:inputHeight))
        tfPwd!.borderStyle = .roundedRect
        tfPwd!.text = "password"
        tfPwd!.placeholder = "password"
        tfPwd!.backgroundColor = UIColor.white
        tfPwd!.textColor = UIColor.blue
        tfPwd!.isSecureTextEntry = true
        
        tfRoomId = UITextField(frame: CGRect(x:inputOffset, y:topOffset+4*border+3*inputHeight, width:inputWidth, height:inputHeight))
        tfRoomId!.borderStyle = .roundedRect
        tfRoomId!.text = "101"
        tfRoomId!.placeholder = "room id"
        tfRoomId!.backgroundColor = UIColor.white
        tfRoomId!.textColor = UIColor.blue
        
        
        ckBox = UIButton(frame: CGRect(x:buttonOffset2, y:topOffset+4*border+4*inputHeight, width: chBoxWidth, height:inputHeight))
        ckBox!.backgroundColor = .lightGray
        ckBox!.setTitleColor(.blue, for: .normal)
        displayChBox()
        ckBox!.addTarget(self, action: #selector(buttonCheck), for: .touchUpInside)
        
        tlsLab = UIButton(frame: CGRect(x:buttonOffset2+chBoxWidth+interChk, y:topOffset+4*border+4*inputHeight, width: tlsLabWidth, height:inputHeight))
        tlsLab!.backgroundColor = .lightGray
        tlsLab!.setTitleColor(.blue, for: .normal)
        tlsLab!.setTitle("TLS", for: .normal)
        tlsLab!.addTarget(self, action: #selector(buttonCheck), for: .touchUpInside)
      
        
        btConn = UIButton(frame: CGRect(x:buttonOffset2+chBoxWidth+interChk+tlsLabWidth+interButton, y:topOffset+4*border+4*inputHeight, width:buttonWidth, height:inputHeight))
        btConn!.backgroundColor = .lightGray
        btConn!.setTitleColor(.blue, for: .normal)
        btConn!.setTitle("Connect", for: .normal)
        btConn!.addTarget(self, action: #selector(buttonConnect), for: .touchUpInside)
        
        
        btPing = UIButton(frame: CGRect(x:buttonOffset, y:topOffset, width:buttonWidth, height:inputHeight))
        btPing!.backgroundColor = .lightGray
        btPing!.setTitleColor(.blue, for: .normal)
        btPing!.setTitle("Ping", for: .normal)
        btPing!.addTarget(self, action: #selector(buttonPing), for: .touchUpInside)
        
        btDisconn = UIButton(frame: CGRect(x:buttonOffset+buttonWidth+interButton, y:topOffset, width:buttonWidth, height:inputHeight))
        btDisconn!.backgroundColor = .lightGray
        btDisconn!.setTitleColor(.blue, for: .normal)
        btDisconn!.setTitle("Disconnect", for: .normal)
        btDisconn!.addTarget(self, action: #selector(buttonDisconnect), for: .touchUpInside)
        
        let myFrame = CGRect(x:0, y:0, width:1, height:1)
        tView = UITextView(frame: myFrame)
        tView!.backgroundColor = .lightGray
        tView!.text = "RMSRmNd Version 0.5\n"
    }
    
    func displayConnect() {
        let subViews = self.view.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        self.view.addSubview(tfURL!)
        self.view.addSubview(tfUser!)
        self.view.addSubview(tfPwd!)
        self.view.addSubview(tfRoomId!)
        self.view.addSubview(ckBox!)
        self.view.addSubview(tlsLab!)
        self.view.addSubview(btConn!)
        
        let myY = topOffset+4*border+5*inputHeight
        let myW = screenWidth!-2*border
        let myH = screenHeight!-myY-bottomOffset
        let myFrame = CGRect(x:border, y: myY, width: myW, height: myH)
        tView!.frame = myFrame
        self.view.addSubview(tView!)
    }
    
    func displayConnected() {
        let subViews = self.view.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        self.view.addSubview(btPing!)
        self.view.addSubview(btDisconn!)
        
        let myY = topOffset+inputHeight
        let myW = screenWidth!-2*border
        let myH = screenHeight!-myY-bottomOffset
        let myFrame = CGRect(x:border, y: myY, width: myW, height: myH)
        tView!.frame = myFrame
        self.view.addSubview(tView!)
    }
    
    @objc func buttonCheck(sender: UIButton) {
        useTls = !useTls
        displayChBox()
    }
    
    func displayChBox() {
        if (useTls) {
            ckBox!.setTitle("☑︎", for: .normal)
        } else {
            ckBox!.setTitle("☐", for: .normal)
        }
    }
}

