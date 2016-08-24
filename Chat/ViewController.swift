//
//  ViewController.swift
//  Chat
//
//  Created by Jonathan on 8/24/16.
//  Copyright © 2016 NerdHouse. All rights reserved.
//

import UIKit
import Starscream
import Material
import Cartography

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var socket:WebSocket!
    
    var messages:[String] = []
    
    var myTextField:TextField = TextField()
    var send:FlatButton = FlatButton()
    var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(send)
        self.view.addSubview(myTextField)
        self.view.addSubview(tableView)
        
        
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.backgroundColor = MaterialColor.amber.accent3
        
        send.setTitle("Send", forState: UIControlState.Normal)
        send.setTitleColor(MaterialColor.blue.base, forState: UIControlState.Normal)
        myTextField.placeholder = "Type Here"
        
        send.addTarget(self, action: #selector(ViewController.sendMsg), forControlEvents: UIControlEvents.TouchUpInside)
        
        constrain(myTextField, send, tableView) { (_myTextField, _send,_tableView) in
            
            _myTextField.height == 50
            _myTextField.left == _send.right
            _myTextField.right == (_myTextField.superview?.right)!
            _myTextField.bottom == (_myTextField.superview?.bottom)!
            
            _send.height == 50
            _send.width == 100
            _send.left == (_send.superview?.left)!
            _send.bottom == (_myTextField.superview?.bottom)!
            
            _tableView.left == (_myTextField.superview?.left)!
            _tableView.right == (_myTextField.superview?.right)!
            _tableView.top == (_tableView.superview?.top)! + 20
            _tableView.bottom == _myTextField.top
            
        }
        
        socket = WebSocket(url: NSURL(string: "ws://192.168.1.153:8080/test")!)
        //websocketDidConnect
        socket.onConnect = {
            print("websocket is connected")
            
            
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: NSError?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
            
            self.messages.append(text)
            
            self.reload()
        }
        //websocketDidReceiveData
        socket.onData = { (data: NSData) in
            print("got some data: \(data.length)")
        }
        //you could do onPong as well.
        socket.connect()
    }
    
    func reload(){
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            self.tableView.reloadData()
        }
    }
    
    
    func sendMsg(){
        
        guard myTextField.text != "" else {
            
            print("text field is empty")
            
            return
        }
        
        self.socket.writeString(myTextField.text!)
        
        myTextField.text = ""
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = messages[indexPath.row]
        
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

