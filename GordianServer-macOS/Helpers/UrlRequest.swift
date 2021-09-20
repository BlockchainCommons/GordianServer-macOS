//
//  UrlRequest.swift
//  StandUp
//
//  Created by Peter on 19/11/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Foundation

class FetchLatestRelease {
        
    class func get(completion: @escaping ((dict:NSDictionary?, error:String?)) -> Void) {
        let url = "https://api.github.com/repos/bitcoin/bitcoin/releases"
        guard let destination = URL(string: url) else { return }
        let request = URLRequest(url: destination)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let data = data {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                            if jsonArray.count > 0 {
                                if let latestTag = jsonArray[0] as? NSDictionary {
                                    if let version = latestTag["tag_name"] as? String {
                                        let processedVersion = version.replacingOccurrences(of: "v", with: "")
                                        let dict = [
                                            "version":"\(processedVersion)",
                                            "binaryPrefix":"bitcoin-\(processedVersion)",
                                            "macosBinary":"bitcoin-\(processedVersion)-osx64.tar.gz",
                                            "macosURL":"https://bitcoincore.org/bin/bitcoin-core-\(processedVersion)/bitcoin-\(processedVersion)-osx64.tar.gz",
                                            "shaURL":"https://bitcoincore.org/bin/bitcoin-core-\(processedVersion)/SHA256SUMS",
                                            "shasumsSignedUrl":"https://bitcoincore.org/bin/bitcoin-core-\(processedVersion)/SHA256SUMS.asc"
                                        ] as NSDictionary
                                        completion((dict, nil))
                                    }
                                }
                            } else {
                                completion((nil, "There seems to be an issue fetching the latest tagged release of Bitcoin Core from: \(url)\n\nThe response is empty."))
                            }
                        } else {
                            completion((nil, "Error fetching latest tagged release from: \(url)"))
                        }
                    } catch {
                        completion((nil, "Error fetching latest tagged Bitcoin Core release from: \(url)"))
                    }
                } else {
                    completion((nil, "There seems to be an issue fetching the latest tagged release of Bitcoin Core from: \(url)\n\nThe response is empty."))
                }
            } else {
                completion((nil, error!.localizedDescription))
            }
        }
        task.resume()
    }
}
