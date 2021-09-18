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
    
    func command(method: String, port: String, user: String, password: String, completion: @escaping ((result: Any?, error: String?)) -> Void) {
        let nodeIp = "127.0.0.1:\(port)"
        let stringUrl = "http://\(user):\(password)@\(nodeIp)"
        guard let url = URL(string: stringUrl) else {
            completion((nil, "Error converting the url."))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"\(method)\",\"params\":[]}".data(using: .utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let urlContent = data else {
                completion((nil, error?.localizedDescription))
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: urlContent, options: .mutableLeaves) as? NSDictionary else {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 401:
                        completion((nil, "Looks like your rpc credentials are incorrect, please double check them. If you changed your rpc creds in your bitcoin.conf you need to restart your node for the changes to take effect."))
                    case 503:
                        completion(("", nil))
                    default:
                        completion((nil, "Unable to decode the response from your node, http status code: \(httpResponse.statusCode)"))
                    }
                } else {
                    completion((nil, "Unable to decode the response from your node..."))
                }
                return
            }
            
            #if DEBUG
            //print("json: \(json)")
            #endif
            
            guard let errorCheck = json["error"] as? NSDictionary else {
                completion((json["result"], nil))
                return
            }
            
            guard let errorMessage = errorCheck["message"] as? String else {
                completion((nil, "Uknown error from bitcoind"))
                return
            }
            
            completion((nil, errorMessage))
        }
        task.resume()
    }
}
