//
//  NetworkUtil.swift
//  Blitz
//
//  Created by Tianyang Yu on 10/5/15.
//  Copyright © 2015 cs490. All rights reserved.
//

import Foundation

func request(jsonObject :[String: AnyObject]) -> [String: AnyObject]{
    let addr = "blitzproject.cs.purdue.edu"
    let port = 9066
    
    var inp :NSInputStream?
    var out :NSOutputStream?
    
    NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inp, outputStream: &out)
    
    let inputStream = inp!
    let outputStream = out!
    inputStream.open()
    outputStream.open()
    
    do{ // Try to convert jsonObject into String
        let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        NSLog("@NetworkUtil.swift: JSON String: " + jsonString)
        
        // Add "\n" to the end for socketServer(java)
        outputStream.write(jsonString+"\n", maxLength: jsonString.characters.count + 1)
        
        var buffer = [UInt8](count: 8, repeatedValue: 0)
        var res = ""
        var isWait :Bool = true
        while true {
            let result :Int = inputStream.read(&buffer, maxLength: buffer.count)
            let char = String(bytes: buffer, encoding: NSUTF8StringEncoding)!
            //print((char, result))
            if result == -1{
                // Connection fail
                break
            }
            if result == 0 && !isWait{
                break
            }
            if result > 0 {
                let index1 = char.endIndex.advancedBy(result-8)
                res += char.substringToIndex(index1)
                isWait = false;
            }
        }
        
        NSLog("@NetworkUtil.swift: Done: "+res)
        
        if let data = res.dataUsingEncoding(NSUTF8StringEncoding){
            let parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? Dictionary<String, AnyObject>
            
            if (parsedObject != nil) {
                
            }
            else {

            }
            return parsedObject!
        }
        return [ "success": false, "msg": "Error when use 'dataUsingEncoding'" ]
    }
    catch{
        return [ "success": false, "msg": "Error when use 'dataWithJSONObject/JSONObjectWithData'" ]
    }
}


// Not useful, just explore
func query(jsonObject :[String: AnyObject]) -> [[String: AnyObject]]{
    let addr = "blitzproject.cs.purdue.edu"
    let port = 9067
    
    var inp :NSInputStream?
    var out :NSOutputStream?
    
    NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inp, outputStream: &out)
    
    let inputStream = inp!
    let outputStream = out!
    inputStream.open()
    outputStream.open()
    
    do{ // Try to convert jsonObject into String
        let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        NSLog("@NetworkUtil.swift: JSON String: " + jsonString)
        
        // Add "\n" to the end for socketServer(java)
        outputStream.write(jsonString+"\n", maxLength: jsonString.characters.count + 1)
        
        var buffer = [UInt8](count: 8, repeatedValue: 0)
        var res = ""
        var isWait :Bool = true
        while true {
            let result :Int = inputStream.read(&buffer, maxLength: buffer.count)
            let char = String(bytes: buffer, encoding: NSUTF8StringEncoding)!
            //print((char, result))
            if result == -1{
                // Connection fail
                break
            }
            if result == 0 && !isWait{
                break
            }
            if result > 0 {
                let index1 = char.endIndex.advancedBy(result-8)
                res += char.substringToIndex(index1)
                isWait = false;
            }
        }
        
        NSLog("@NetworkUtil.swift: Done: "+res)
        
        if let data = res.dataUsingEncoding(NSUTF8StringEncoding){
            let parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [[String: AnyObject]]
            
            if (parsedObject != nil) {
                
            }
            else {
                
            }
            return parsedObject!
        }
        return [[ "success": false, "msg": "Error when use 'dataUsingEncoding'" ]]
    }
    catch{
        return [[ "success": false, "msg": "Error when use 'dataWithJSONObject/JSONObjectWithData'" ]]
    }
}


func response(jsonObject :[String: AnyObject]) -> [String: AnyObject]{
    let addr = "blitzproject.cs.purdue.edu"
    let port = 9069
    
    var inp :NSInputStream?
    var out :NSOutputStream?
    
    NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inp, outputStream: &out)
    
    let inputStream = inp!
    let outputStream = out!
    inputStream.open()
    outputStream.open()
    
    do{ // Try to convert jsonObject into String
        let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        NSLog("@NetworkUtil.swift - response(): INPUT JSON String = " + jsonString)
        
        // Add "\n" to the end for socketServer(java)
        outputStream.write(jsonString+"\n", maxLength: jsonString.characters.count + 1)
        
        var buffer = [UInt8](count: 8, repeatedValue: 0)
        var res = ""
        var isWait :Bool = true
        while true {
            let result :Int = inputStream.read(&buffer, maxLength: buffer.count)
            let char = String(bytes: buffer, encoding: NSUTF8StringEncoding)!
            //print((char, result))
            if result == -1{
                // Connection fail
                break
            }
            if result == 0 && !isWait{
                break
            }
            if result > 0 {
                let index1 = char.endIndex.advancedBy(result-8)
                res += char.substringToIndex(index1)
                isWait = false;
            }
        }
        
        NSLog("@NetworkUtil.swift - response(): OUTPUT JSON String = "+res)
        
        if let data = res.dataUsingEncoding(NSUTF8StringEncoding){
            let parsedObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? Dictionary<String, AnyObject>
            
            if (parsedObject != nil) {
                
            }
            else {
                
            }
            return parsedObject!
        }
        return [ "success": false, "msg": "Error when use 'dataUsingEncoding'" ]
    }
    catch{
        return [ "success": false, "msg": "Error when use 'dataWithJSONObject/JSONObjectWithData'" ]
    }
}