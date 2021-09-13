//
//  Extensions.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 9/13/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Foundation

extension String {
    var torVersion: String {
        /* Tor version 0.4.6.7.
        Tor is running on Darwin with Libevent 2.1.12-stable, OpenSSL 1.1.1l, Zlib 1.2.11, Liblzma N/A, Libzstd N/A and Unknown N/A as libc.
        Tor compiled with clang version 12.0.5
        */
        let lines = self.split(whereSeparator: \.isNewline)
        if lines.count > 0 {
            var version = "\(lines[0])"
            version = version.replacingOccurrences(of: "Tor version ", with: "")
            if version.hasSuffix(".") {
                return "v\(version.dropLast())"
            } else {
                return "v\(version)"
            }
        } else {
            return "parse error"
        }
    }
}
