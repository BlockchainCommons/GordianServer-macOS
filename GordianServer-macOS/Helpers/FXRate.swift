//
//  FXRate.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 10/7/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

class FXRate {
    static let sharedInstance = FXRate()
    private init() {}
    
    func getFxRate(completion: @escaping ((Double?)) -> Void) {
        let currency = UserDefaults.standard.object(forKey: "currency") as? String ?? "USD"
        let torClient = TorClient.sharedInstance
        let url = NSURL(string: "https://blockchain.info/ticker")
        let task = torClient.session.dataTask(with: url! as URL) { (data, response, error) -> Void in
            guard let urlContent = data,
                  let json = try? JSONSerialization.jsonObject(with: urlContent, options: [.mutableContainers]) as? [String : Any],
                  let data = json["\(currency)"] as? NSDictionary,
                  let rateCheck = data["15m"] as? Double else {
                completion(nil)
                return
            }
            completion(rateCheck)
        }
        task.resume()
    }
}
