//
//  MakeRPCCall.swift
//  StandUp
//
//  Created by Peter on 03/06/20.
//  Copyright © 2020 Peter. All rights reserved.
//

import Foundation

class MakeRpcCall {
    
    static let shared = MakeRpcCall()
    lazy var session = URLSession(configuration: .default)
    
    func command(method: String, param: String, port: String, user: String, password: String, completion: @escaping ((Any?)) -> Void) {
        let nodeIp = "127.0.0.1:\(port)"
        let stringUrl = "http://\(user):\(password)@\(nodeIp)"
        guard let url = URL(string: stringUrl) else {
            completion((nil))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"\(method)\",\"params\":[\(param)]}".data(using: .utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                completion((nil))
            } else {
                if let urlContent = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                        print("error: \((json["error"] as? NSDictionary))")
                        if (json["error"] as? NSDictionary) != nil {
                            completion((nil))
                        } else {
                            print("jsonResult: \(json["result"] as Any)")
                            completion(((json["result"] as Any)))
                        }
                    } catch {
                        completion((nil))
                    }
                }
            }
        }
        task.resume()
    }
}
