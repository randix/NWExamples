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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        var button = UIButton(frame: CGRect(x: 30, y: 100, width: 200, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(buttonConnectFD), for: .touchUpInside)
        self.view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 240, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(buttonLogin), for: .touchUpInside)
        self.view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 30, y: 200, width: 200, height: 50))
        button.backgroundColor = .green
        button.setTitle("GetOplCommands", for: .normal)
        button.addTarget(self, action: #selector(buttonGetOplCommands), for: .touchUpInside)
        self.view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 240, y: 200, width: 100, height: 50))
        button.backgroundColor = .gray
        button.setTitle("Enroll", for: .normal)
        button.addTarget(self, action: #selector(buttonEnrollRMS), for: .touchUpInside)
        self.view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 20, y: 300, width: 210, height: 50))
        button.backgroundColor = .green
        button.setTitle("GetOplCommands2", for: .normal)
        button.addTarget(self, action: #selector(buttonGetOplCommands2), for: .touchUpInside)
        self.view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 240, y: 300, width: 100, height: 50))
        button.backgroundColor = .gray
        button.setTitle("Enroll", for: .normal)
        button.addTarget(self, action: #selector(buttonEnrollRMSRmNd), for: .touchUpInside)
        self.view.addSubview(button)
        
        print("Hello")
    }
    
    @objc func buttonConnectFD(sender: UIButton!) {
        print("connect FD")
        client = MTSClient(hostname: "172.20.10.5", port: 10001, mtsReceiver: mtsReceiver).Connect()
    }
    
    @objc func buttonLogin(sender: UIButton!)
    {
        let login = Login(user:"user", password:"password")
        let jsonEncoder = JSONEncoder()
        var json : String = ""
        do {
            let jsonData = try jsonEncoder.encode(login)
            json = String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch {
            print("json convert error")
        }
        let mtsMessage = MTSMessage(route:.Login, messageType:.Request, json:json)
        do {
            let jsonData = try jsonEncoder.encode(mtsMessage)
            json = String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch {
            print("json convert error")
        }
        print(json)
        client!.send(json.data(using: String.Encoding.utf8)!)
    }
    
    @objc func buttonGetOplCommands(sender: UIButton!)
    {
        let jsonEncoder = JSONEncoder()
        var json : String = ""
        let mtsMessage = MTSMessage(route:.OplCommands, messageType:.Request, json:"")
        do {
            let jsonData = try jsonEncoder.encode(mtsMessage)
            json = String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch {
            print("json convert error")
        }
        print(json)
        client!.send(json.data(using: String.Encoding.utf8)!)
    }
    
    @objc func buttonGetOplCommands2(sender: UIButton!)
    {
        let jsonEncoder = JSONEncoder()
        var json : String = ""
        let mtsMessage = MTSMessage(route:.OplCommands, messageType:.Request, json:"")
        do {
            let jsonData = try jsonEncoder.encode(mtsMessage)
            json = String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch {
            print("json convert error")
        }
        print(json)
        let oplCommands = client!.sendAwait(json.data(using: String.Encoding.utf8)!) as! OPLCommands
        for (key, value) in oplCommands.OPLLists {
            print("\(key) -> \(value)")
        }
        print("got synchronously")
    }
    
    @objc func buttonEnrollRMS(sender: UIButton!)
    {
        print("enroll RMS (with MTS)")
    }
    
    @objc func buttonConnectRMSRmNd(sender: UIButton!)
    {
        print("connect RMSRmNd (with OPL)")
    }
    @objc func buttonEnrollRMSRmNd(sender: UIButton!)
    {
        print("enroll RMSRmNd (with OPL)")
    }
    
    func mtsReceiver(_ mtsMessage: MTSMessage) {
        print("mtsMessage \(mtsMessage)")
        let jsonDecoder = JSONDecoder()

        print(mtsMessage.Route)
        switch MTSRequest(rawValue: mtsMessage.Route)! {
        case .Login:
            break
        case .OplCommands:
            do {
                let oplCommands = try jsonDecoder.decode(OPLCommands.self, from: mtsMessage.Json.data(using: .utf8)!)
            
                for (key, value) in oplCommands.OPLLists {
                    print("\(key) -> \(value)")
                }
            } catch {
                print("OPLCommands json convert error")
            }
            break
        default:
            break
        }
    }
}

