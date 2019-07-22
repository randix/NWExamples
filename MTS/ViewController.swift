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
    
    var firmware = Data()
    let fwSegmentSize = 16*1024
    var firmwareSize = 0
    
    // below are the UI stuff
    var screenWidth: Int?
    var screenHeight: Int?
    
    // MARK: - Properties: IBOutlets
    // TODO: - clean this up to IB's; or not worth it?
    
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
    
    // MARK: - Functions
    
    /// Do any additional setup after loading the view.
    private func decorateUI() {
        self.view.backgroundColor = .lightGray
        
        let screenRect = UIScreen.main.bounds
        screenWidth = Int(screenRect.size.width)
        screenHeight = Int(screenRect.size.height)
        
        print(screenWidth!, screenHeight!)
    }
    
    /// This action is called when connect button tapped.
    private func connectButtonAction() {
        if (useTls) {
            Log("Connecting (with TLS) ...")
        } else {
            Log("Connecting (no TLS) ...")
        }
        
        client = MTSClient(log: Log,
                           url: tfURL!.text!,
                           mtsConnect: mtsConnect,
                           mtsReceive: mtsReceive,
                           mtsDisconnect: mtsDisconnect,
                           mtsConvert: mtsConvertWait)
        
        if (useTls) { client?.withTLS(nil) }
        client?.connect()
    }

    // MARK: - Functions: IBAction
    
    @objc func buttonConnect(sender: UIButton!) {
        connectButtonAction()
    }

    // MARK: - Functions: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        decorateUI()
        createSubviews()
        displayConnect()
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
            
        case .MtsFirmware:
            let fw = try! decoder.decode(MtsFirmware.self, from: mtsMessage.data)
            Log("firmware: offset: \(fw.Offset)")
            firmware.append(fw.Data)
            firmwareSize += fw.SegmentSize
            if (fw.IsFinal) {
                Log("firmware size: \(firmware.count) real: \(firmwareSize)")
                return
            }
            let fwReq = MtsFirmwareReq(Offset: fw.Offset + fw.SegmentSize, MaximumSegmentSize: fwSegmentSize)
            let data = try! MTSConvert(fwReq)
            let mtsMessage = MTSMessage(route: MTSRequest.MtsFirmware, jwt: "jwt", data: data)
            self.client!.send(mtsMessage)
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
                let fwReq = MtsFirmwareReq(Offset: 0, MaximumSegmentSize: fwSegmentSize)
                let data = try! MTSConvert(fwReq)
                let mtsMessage = MTSMessage(route: MTSRequest.MtsFirmware, jwt: "jwt", data: data)
                self.client!.send(mtsMessage)
                
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
        
        let inputOffset = (screenWidth! - VCDimension.inputWidth) / 2
        let buttonOffset = (screenWidth! - VCDimension.buttonWidth - VCDimension.interButton - VCDimension.buttonWidth) / 2
        let buttonOffset2 = (screenWidth! - VCDimension.chBoxWidth - VCDimension.interButton - VCDimension.tlsLabWidth - VCDimension.interButton - VCDimension.buttonWidth) / 2
        
        // TODO: These cgrect's below should really be generated in a factory or just replaced with IB...
        
        // connect to RMS Server
        tfURL = UITextField(frame:
            CGRect(x: inputOffset,
                   y: VCDimension.topOffset + VCDimension.border,
                   width: VCDimension.inputWidth,
                   height: VCDimension.inputHeight))
        tfURL!.borderStyle = .roundedRect
        tfURL!.placeholder = "\(IPv4.defaultAddr):\(IPv4.defaultPort)"
        tfURL!.text = "\(IPv4.defaultAddr):\(IPv4.defaultPort)"
        tfURL!.backgroundColor = UIColor.white
        tfURL!.textColor = UIColor.blue
        
        tfUser = UITextField(frame:
            CGRect(x: inputOffset,
                   y: VCDimension.topOffset + 2 * VCDimension.border + VCDimension.inputHeight,
                   width: VCDimension.inputWidth,
                   height: VCDimension.inputHeight))
        tfUser!.borderStyle = .roundedRect
        tfUser!.text = "OnityTech"
        tfUser!.placeholder = "user"
        tfUser!.backgroundColor = UIColor.white
        tfUser!.textColor = UIColor.blue
        
        tfPwd = UITextField(frame:
            CGRect(x: inputOffset,
                   y: VCDimension.topOffset + 3 * VCDimension.border + 2 * VCDimension.inputHeight,
                   width: VCDimension.inputWidth,
                   height: VCDimension.inputHeight))
        tfPwd!.borderStyle = .roundedRect
        tfPwd!.text = "password"
        tfPwd!.placeholder = "password"
        tfPwd!.backgroundColor = UIColor.white
        tfPwd!.textColor = UIColor.blue
        tfPwd!.isSecureTextEntry = true
        
        tfRoomId = UITextField(frame:
            CGRect(x: inputOffset,
                   y:  VCDimension.topOffset + 4 * VCDimension.border + 3 * VCDimension.inputHeight,
                   width: VCDimension.inputWidth,
                   height: VCDimension.inputHeight))
        tfRoomId!.borderStyle = .roundedRect
        tfRoomId!.text = "101"
        tfRoomId!.placeholder = "room id"
        tfRoomId!.backgroundColor = UIColor.white
        tfRoomId!.textColor = UIColor.blue
        
        
        ckBox = UIButton(frame:
            CGRect(x: buttonOffset2,
                   y: VCDimension.topOffset + 4 * VCDimension.border + 4 * VCDimension.inputHeight,
                   width: VCDimension.chBoxWidth,
                   height: VCDimension.inputHeight))
        ckBox!.backgroundColor = .lightGray
        ckBox!.setTitleColor(.blue, for: .normal)
        displayChBox()
        ckBox!.addTarget(self, action: #selector(buttonCheck), for: .touchUpInside)
        
        tlsLab = UIButton(frame:
            CGRect(x: buttonOffset2 + VCDimension.chBoxWidth + VCDimension.interChk,
                   y: VCDimension.topOffset + 4 * VCDimension.border + 4 * VCDimension.inputHeight,
                   width: VCDimension.tlsLabWidth,
                   height: VCDimension.inputHeight))
        tlsLab!.backgroundColor = .lightGray
        tlsLab!.setTitleColor(.blue, for: .normal)
        tlsLab!.setTitle("TLS", for: .normal)
        tlsLab!.addTarget(self, action: #selector(buttonCheck), for: .touchUpInside)
      
        
        btConn = UIButton(frame:
            CGRect(x: buttonOffset2 + VCDimension.chBoxWidth + VCDimension.interChk + VCDimension.tlsLabWidth + VCDimension.interButton,
                   y: VCDimension.topOffset + 4 * VCDimension.border + 4 * VCDimension.inputHeight,
                   width: VCDimension.buttonWidth,
                   height: VCDimension.inputHeight))
        btConn!.backgroundColor = .lightGray
        btConn!.setTitleColor(.blue, for: .normal)
        btConn!.setTitle("Connect", for: .normal)
        btConn!.addTarget(self, action: #selector(buttonConnect), for: .touchUpInside)
        
        
        btPing = UIButton(frame:
            CGRect(x: buttonOffset,
                   y: VCDimension.topOffset,
                   width: VCDimension.buttonWidth,
                   height: VCDimension.inputHeight))
        btPing!.backgroundColor = .lightGray
        btPing!.setTitleColor(.blue, for: .normal)
        btPing!.setTitle("Ping", for: .normal)
        btPing!.addTarget(self, action: #selector(buttonPing), for: .touchUpInside)
        
        btDisconn = UIButton(frame:
            CGRect(x: buttonOffset + VCDimension.buttonWidth + VCDimension.interButton,
                   y: VCDimension.topOffset,
                   width: VCDimension.buttonWidth,
                   height: VCDimension.inputHeight))
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
        
        let myY = VCDimension.topOffset + 4 * VCDimension.border + 5 * VCDimension.inputHeight
        let myW = screenWidth! - 2 * VCDimension.border
        let myH = screenHeight! - myY - VCDimension.bottomOffset
        let myFrame = CGRect(x: VCDimension.border,
                             y: myY,
                             width: myW,
                             height: myH)
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
        
        let myY = VCDimension.topOffset + VCDimension.inputHeight
        let myW = screenWidth! - 2 * VCDimension.border
        let myH = screenHeight! - myY - VCDimension.bottomOffset
        let myFrame = CGRect(x: VCDimension.border,
                             y: myY,
                             width: myW,
                             height: myH)
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

