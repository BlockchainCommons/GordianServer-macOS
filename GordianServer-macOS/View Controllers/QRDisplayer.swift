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
        
        var url = "btcstandup://\(rpcuser):\(rpcpassword)@\(torHostname):\(rpcport)/?label=\(nodeLabel)%20-%20\(network)"
        if network == "lightning" {
            url = "clightning-rpc://lightning:\(httpPass)@\(torHostname):8080/?label=Lightning"
        }
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
    
    @IBAction func refreshHS(_ sender: Any) {
        actionAlert(message: "Refresh \(network) hidden service?", info: "This refreshes your hidden service so that any clients that were connected to your node will no longer be able to connect, it's a good idea to do this if for some reason you think someone may have access to your node if for example your phone was lost or stolen.") { [unowned vc = self] (response) in
            if response {
                vc.spinnerDescription.stringValue = "refreshing..."
                vc.showSpinner()
//                vc.refreshHS {
//                    vc.getHostname()
//                }
                
                let path = "\(TorClient.sharedInstance.torPath())/host/bitcoin/\(self.network)/"
                
                do {
                    try FileManager.default.removeItem(atPath: path)
                        
                    TorClient.sharedInstance.resign()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        TorClient.sharedInstance.start(delegate: self)
                    }
                    
                } catch {
                    simpleAlert(message: "There was an issue...", info: "Your hidden service was not refreshed. Please let us know about this bug.", buttonLabel: "OK")
                }
            }
        }
    }
    
//    private func refreshHS(completion: @escaping () -> Void) {
//        DispatchQueue.main.async { [unowned vc = self] in
//            var script:SCRIPT!
//            switch vc.rpcport {
//            case "8332":
//                script = .refreshMainHS
//            case "18332":
//                script = .refreshTestHS
//            case "18334":
//                script = .refreshRegHS
//            case "38332":
//                script = .refreshSignetHS
//            default:
//                break
//            }
//            guard let path = Bundle.main.path(forResource: script.rawValue, ofType: "command") else {
//                return
//            }
//            let stdOut = Pipe()
//            let task = Process()
//            task.launchPath = path
//            task.standardOutput = stdOut
//            task.launch()
//            task.waitUntilExit()
//            let data = stdOut.fileHandleForReading.readDataToEndOfFile()
//            var result = ""
//            if let output = String(data: data, encoding: .utf8) {
//                #if DEBUG
//                print("output: \(output)")
//                #endif
//                result += output
//                vc.setLog(content: result)
//                completion()
//            }
//        }
//    }
    
//    private func getHostname() {
//        DispatchQueue.main.async { [unowned vc = self] in
//            guard let path = Bundle.main.path(forResource: SCRIPT.getTorHostname.rawValue, ofType: "command") else {
//                return
//            }
//            let stdOut = Pipe()
//            let task = Process()
//            task.launchPath = path
//            task.standardOutput = stdOut
//            task.launch()
//            task.waitUntilExit()
//            let data = stdOut.fileHandleForReading.readDataToEndOfFile()
//            if let output = String(data: data, encoding: .utf8) {
//                #if DEBUG
//                print("output: \(output)")
//                #endif
//                let hostnames = output.split(separator: "\n")
//                if hostnames.count == 4 {
//                    switch vc.rpcport {
//                    case "8332":
//                        UserDefaults.standard.setValue("mainHostname", forKey: "\(hostnames[0])")
//                        vc.torHostname = "\(hostnames[3])"
//                        DispatchQueue.main.async {
//                            vc.updateImage()
//                        }
//                    case "18332":
//                        UserDefaults.standard.setValue("testHostname", forKey: "\(hostnames[1])")
//                        vc.torHostname = "\(hostnames[3])"
//                        DispatchQueue.main.async {
//                            vc.updateImage()
//                        }
//                    case "18334":
//                        UserDefaults.standard.setValue("regHostname", forKey: "\(hostnames[2])")
//                        vc.torHostname = "\(hostnames[3])"
//                        DispatchQueue.main.async {
//                            vc.updateImage()
//                        }
//                    case "38332":
//                        UserDefaults.standard.setValue("signetHostname", forKey: "\(hostnames[3])")
//                        vc.torHostname = "\(hostnames[3])"
//                        DispatchQueue.main.async {
//                            vc.updateImage()
//                        }
//                    default:
//                        break
//                    }
//
//                }
//            }
//        }
//    }
    
//    private func updateImage() {
//        DispatchQueue.main.async { [unowned vc = self] in
//            vc.hideSpinner()
//            let url = "btcstandup://\(vc.rpcuser):\(vc.rpcpassword)@\(vc.torHostname):\(vc.rpcport)/?label=\(vc.nodeLabel)%20-%20\(vc.network)"
//            let newImage = vc.getQRCode(textInput: url)
//            let transition = CATransition() //create transition
//            transition.duration = 0.75 //set duration time in seconds
//            transition.type = .fade //animation type
//            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            vc.imageView.layer?.add(transition, forKey: nil) //add animation to your imageView's layer
//            vc.imageView.image = newImage //set the image
//        }
//    }
    
//    private func setLog(content: String) {
//        Log.writeToLog(content: content)
//    }
    
}

extension QRDisplayer: OnionManagerDelegate {
    
    func torConnProgress(_ progress: Int) {
        self.showSpinner()
    }
    
    func torConnFinished() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.hideSpinner()
            self.setQR()
        }
    }
    
    func torConnDifficulties() {
        self.hideSpinner()
        simpleAlert(message: "Tor connection issue.", info: "We are having trouble restarting Tor. Your hidden service will not refresh until Tor reboots successfully.", buttonLabel: "OK")
    }
}
