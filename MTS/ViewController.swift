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
    var useTls = true

    // RMSRmNd Data
    var roomToNodeIds: MtsRoomToNodeIds?
    
    // PP MTS Test data
    var loginResponse: MtsLoginResponse?
    var jwt: String?
    var loginWithCertDone = false
    var roomMap: [MtsRoomToNodeIds]?
    
    // below are the UI stuff
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
        
        client = MTSClient(log: Log, url: tfURL!.text!, mtsConnect: mtsConnect, mtsReceive: mtsReceive, mtsDisconnect: mtsDisconnect, mtsConvert: mtsConvertWait)
        if (useTls) {
            client!.withTLS(nil)
        }
        client!.connect()
    }
    
    // called when the connection is established
    func mtsConnect(_ client: MTSClient)
    {
        var mtsMessage: MTSMessage
        if (useTls) {
            Log("login to FrontDeskServer as Portable Programmer")
            // connected to FrontDeskServer -- get PP type stuff
            let login = MtsLogin(user:tfUser!.text!, password:tfPwd!.text!, appId:AppId.RMSRmNd, appKey:Data())
            let data = try! MTSConvert(login)
            mtsMessage = MTSMessage(route: MTSRequest.MtsLogin, jwt: "jwt", data: data)
            if let lr = loginResponse {
                if lr.ClientCertificate != nil {
                    loginWithCertDone = true
                }
            }
            //let loginResponse =  self.client!.sendWait(mtsMessage) as! MtsLoginResponse
            
        } else {
            // connected to RMSServer -- get Room NodeIds
            Log("connect to RMSServer and get room nodeIds")
            let data = try! MTSConvert(MtsRoom(tfRoomId!.text!))
            mtsMessage = MTSMessage(route: MTSRequest.MtsRoomsMap, jwt: "jwt", data: data)
        }
        self.client!.send(mtsMessage)
        displayConnected()
    }
    
    func mtsDisconnect(_ client: MTSClient) {
        Log("Disconnected")
    }
    
    // This is the main driver of the RoomNode app
    // The PP will have a UI
    func mtsReceive(_ client: MTSClient, _ mtsMessage: MTSMessage) {
        Log("receive \(mtsMessage)")
        let decoder = JSONDecoder()
        
        // OPL                  = 1   <->
        // Login                = 2    ->
        // LoginResponse        = 3   <-
        // CommunicationKeyReq  = 4    ->
        // PPCommunicationKeys  = 5   <-
        // RMSCommunicationKeys = 6   <-
        // RoomsMap             = 7   <->
        // OplCommands          = 8   <->
        // Firmware             = 9   <->
        switch MTSRequest(rawValue: mtsMessage.route)! {
            
        case .MtsOPL:
            // keep track of Routing here - forward or process the messages
            // PP -- probably not get here (coming from BT)
            
            // RMSRmNd -- this is the main thing here
            
            break
            
        case .MtsLoginResponse:
            jwt = mtsMessage.jwt
            let lr = try! decoder.decode(MtsLoginResponse.self, from: mtsMessage.data)
            loginResponse = lr
            if !loginWithCertDone && loginResponse!.ClientCertificate != nil {
                // TODO -- PP
                self.client!.stop("have cert")
                // 2: new client
                self.client = MTSClient(log: Log, url: tfURL!.text!, mtsConnect: mtsConnect, mtsReceive: mtsReceive, mtsDisconnect: mtsDisconnect, mtsConvert: mtsConvertWait)
                    .withTLS(loginResponse!.ClientCertificate)
                self.client!.connect()
                return
            }
            if roomMap == nil {
                // get room map
                let mtsMessage = MTSMessage(route: MTSRequest.MtsRoomsMap, jwt: "jwt", data: Data())
                self.client!.send(mtsMessage)
                return
            }
            break
            
        case .MtsCommunicationKeys:
            //let ppCommunicationKeys = try! decoder.decode(PPCommunicationKeys.self, from: mtsMessage.Data)
            // TODO -- PP
            
            break
            
        case .MtsRoomsMap:
            let json = String(data: mtsMessage.data, encoding: .utf8)!
            print("json=\(json)")
            let roomToNodeIdsResponse = try! decoder.decode([MtsRoomToNodeIds].self, from: mtsMessage.data)
            print("\(roomToNodeIdsResponse)")
            if (useTls) {
                // TODO -- PP
                roomMap = roomToNodeIdsResponse
                
                // TODO -- now get the keys
                
                // TODO -- get the firmware
                
            } else {
                roomToNodeIds = roomToNodeIdsResponse[0]
                for nodeId in roomToNodeIds!.NodeIds {
                    Log("NodeId: \(nodeId)")
                }
            }
            break
            
        case .MtsOplCommands:
            //let oplCommands = try! decoder.decode(OPLCommands.self, from: mtsMessage.Data)
            // TODO -- PP
            
            break
            
        default:
            Log("Unknown Route: \(mtsMessage.route)")
            break
        }
    }
    
    @objc func buttonPing(sender: UIButton!) {
        Log("Ping...")
    }
  
    @objc func buttonDisconnect(sender: UIButton!) {
        displayConnect()
        client?.stop("shutting down")
        Log("disconnected")
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
        tfURL!.placeholder = "127.0.0.1:10001"
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
        tView!.text = "RMSRmNd Version 0.6\n"
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

