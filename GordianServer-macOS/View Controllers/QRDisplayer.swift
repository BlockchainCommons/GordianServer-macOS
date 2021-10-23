//
//  QRDisplayer.swift
//  StandUp
//
//  Created by Peter on 07/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class QRDisplayer: NSViewController {
    
    var window: NSWindow?
    var rpcpassword = ""
    var rpcuser = ""
    var rpcport = ""
    var torHostname = ""
    var nodeLabel = ""
    var network = ""
    var httpPass = ""
    var url = ""
    
    @IBOutlet var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setQR()
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "\(network)"
    }
    
    @IBAction func copyAction(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(url, forType: .string)
        simpleAlert(message: "Copied ✓", info: "", buttonLabel: "OK")
    }
    
    
    private func setQR() {
        let chain = UserDefaults.standard.object(forKey: "chain") as? String ?? "main"
        network = chain
        
        switch chain {
        case "main":
            rpcport = "8332"
        case "test":
            rpcport = "18332"
        case "regtest":
            rpcport = "18334"
        case "signet":
            rpcport = "38332"
        default:
            break
        }
        
        guard let host = TorClient.sharedInstance.rpcHostname() else {
            simpleAlert(message: "No hostname found..", info: "Please ensure Tor is running. If you can not resolve this issue please let us know about it.", buttonLabel: "OK")
            return
        }
        
        torHostname = host.replacingOccurrences(of: "\n", with: "")
        
        rpcuser = UserDefaults.standard.object(forKey: "rpcuser") as? String ?? "user"
        rpcpassword = UserDefaults.standard.object(forKey: "rpcpassword") as? String ?? "password"
        
        nodeLabel = Host.current().localizedName?.replacingOccurrences(of: " ", with: "%20") ?? "Gordian%20Server"
        nodeLabel = nodeLabel.replacingOccurrences(of: "’", with: "")
        
        url = "btcstandup://\(rpcuser):\(rpcpassword)@\(torHostname):\(rpcport)/?label=\(nodeLabel)%20-%20\(network)"
        imageView.frame = CGRect(x: 30, y: 30, width: 100, height: 100)
        imageView.image = getQRCode(textInput: url)
    }
    
    private func getQRCode(textInput: String) -> NSImage {
        let data = textInput.data(using: .ascii)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter!.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let output = filter?.outputImage?.transformed(by: transform)
        let colorParameters = [
            "inputColor0": CIColor(color: NSColor.black), // Foreground
            "inputColor1": CIColor(color: NSColor.white) // Background
        ]
        let colored = (output!.applyingFilter("CIFalseColor", parameters: colorParameters as [String : Any]))
        let rep = NSCIImageRep(ciImage: colored)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
}


