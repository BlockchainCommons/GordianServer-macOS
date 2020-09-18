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
    
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var spinnerDescription: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.alphaValue = 0
        spinnerDescription.alphaValue = 0
        getValues()
        setQR()
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "\(network)"
    }
    
    private func showSpinner() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.startAnimation(vc)
            vc.spinner.alphaValue = 1
            vc.spinnerDescription.alphaValue = 1
        }
    }
    
    private func hideSpinner() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.spinner.stopAnimation(vc)
            vc.spinner.alphaValue = 0
            vc.spinnerDescription.alphaValue = 0
        }
    }
    
    private func setQR() {
        var url = "btcstandup://\(rpcuser):\(rpcpassword)@\(torHostname):\(rpcport)/?label=\(nodeLabel)%20-%20\(network)"
        if network == "lightning" {
            url = "clightning-rpc://lightning:\(httpPass)@\(torHostname):1312/?label=Lightning"
        }
        imageView.frame = CGRect(x: 30, y: 30, width: 100, height: 100)
        imageView.image = getQRCode(textInput: url)
    }
    
    private func getValues() {
        let ud = UserDefaults.standard
        nodeLabel = ud.object(forKey: "nodeLabel") as? String ?? "StandUp%20Node"
        if nodeLabel.contains(" ") {
            nodeLabel = nodeLabel.replacingOccurrences(of: " ", with: "%20")
        }
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
    
    @IBAction func refreshHS(_ sender: Any) {
        actionAlert(message: "Refresh \(network) hidden service?", info: "This refreshes your hidden service so that any clients that were connected to your node will no longer be able to connect, it's a good idea to do this if for some reason you think someone may have access to your node if for example your phone was lost or stolen.") { [unowned vc = self] (response) in
            if response {
                vc.spinnerDescription.stringValue = "refreshing..."
                vc.showSpinner()
                vc.refreshHS {
                    vc.getHostname()
                }
            }
        }
    }
    
    private func refreshHS(completion: @escaping () -> Void) {
        DispatchQueue.main.async { [unowned vc = self] in
            var script:SCRIPT!
            switch vc.rpcport {
            case "1309":
                script = .refreshMainHS
            case "1310":
                script = .refreshTestHS
            case "1311":
                script = .refreshRegHS
            default:
                break
            }
            guard let path = Bundle.main.path(forResource: script.rawValue, ofType: "command") else {
                return
            }
            let stdOut = Pipe()
            let task = Process()
            task.launchPath = path
            task.standardOutput = stdOut
            task.launch()
            task.waitUntilExit()
            let data = stdOut.fileHandleForReading.readDataToEndOfFile()
            var result = ""
            if let output = String(data: data, encoding: .utf8) {
                #if DEBUG
                print("output: \(output)")
                #endif
                result += output
                vc.setLog(content: result)
                completion()
            }
        }
    }
    
    private func getHostname() {
        DispatchQueue.main.async { [unowned vc = self] in
            guard let path = Bundle.main.path(forResource: SCRIPT.getTorHostname.rawValue, ofType: "command") else {
                return
            }
            let stdOut = Pipe()
            let task = Process()
            task.launchPath = path
            task.standardOutput = stdOut
            task.launch()
            task.waitUntilExit()
            let data = stdOut.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                #if DEBUG
                print("output: \(output)")
                #endif
                let hostnames = output.split(separator: "\n")
                if hostnames.count == 3 {
                    switch vc.rpcport {
                    case "1309":
                        vc.torHostname = "\(hostnames[0])"
                    case "1310":
                        vc.torHostname = "\(hostnames[1])"
                    case "1311":
                        vc.torHostname = "\(hostnames[2])"
                    default:
                        break
                    }
                }
                vc.updateImage()
            }
        }
    }
    
    private func updateImage() {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.hideSpinner()
            let url = "btcstandup://\(vc.rpcuser):\(vc.rpcpassword)@\(vc.torHostname):\(vc.rpcport)/?label=\(vc.nodeLabel)%20-%20\(vc.network)"
            let newImage = vc.getQRCode(textInput: url)
            let transition = CATransition() //create transition
            transition.duration = 0.75 //set duration time in seconds
            transition.type = .fade //animation type
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            vc.imageView.layer?.add(transition, forKey: nil) //add animation to your imageView's layer
            vc.imageView.image = newImage //set the image
        }
    }
    
    private func setLog(content: String) {
        let lg = Log()
        lg.writeToLog(content: content)
    }
    
}
