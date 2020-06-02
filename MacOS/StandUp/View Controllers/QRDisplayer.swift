//
//  QRDisplayer.swift
//  StandUp
//
//  Created by Peter on 07/10/19.
//  Copyright © 2019 Blockchain Commons, LLC
//

import Cocoa

class QRDisplayer: NSViewController {
    
    var rpcpassword = ""
    var rpcuser = ""
    var rpcport = ""
    var torHostname = ""
    var nodeLabel = ""
    var network = ""
    
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
    
    @IBAction func backAction(_ sender: Any) {
        DispatchQueue.main.async { [unowned vc = self] in
            vc.dismiss(vc)
        }
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
        let url = "btcstandup://\(rpcuser):\(rpcpassword)@\(torHostname):\(rpcport)/?label=\(nodeLabel)%20-%20\(network)"
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
        actionAlert(message: "Refresh Hidden Service?", info: "This refreshes your hidden service so that any clients that were connected to your node will no longer be able to connect, it's a good idea to do this if for some reason you think someone may have access to your node if for example your phone was lost or stolen.") { [unowned vc = self] (response) in
            if response {
                vc.showSpinner()
                vc.refreshHS {
                    vc.getHostname()
                }
            }
        }
    }
    
    private func refreshHS(completion: @escaping () -> Void) {
        guard let path = Bundle.main.path(forResource: SCRIPT.refreshHS.rawValue, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var result = ""
        if let output = String(data: data, encoding: .utf8) {
            #if DEBUG
            print("output: \(output)")
            #endif
            result += output
            setLog(content: result)
            completion()
        }
        if let errorOutput = String(data: errData, encoding: .utf8) {
            #if DEBUG
            print("error: \(errorOutput)")
            #endif
            result += errorOutput
            setSimpleAlert(message: "Error", info: result, buttonLabel: "OK")
            completion()
        }
    }
    
    private func getHostname() {
        guard let path = Bundle.main.path(forResource: SCRIPT.getTorHostname.rawValue, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var result = ""
        if let output = String(data: data, encoding: .utf8) {
            #if DEBUG
            print("output: \(output)")
            #endif
            result += output
            torHostname = result
            updateImage()
        }
        if let errorOutput = String(data: errData, encoding: .utf8) {
            #if DEBUG
            print("error: \(errorOutput)")
            #endif
            result += errorOutput
            hideSpinner()
            setSimpleAlert(message: "Error", info: "There was an error getting your new hostname: \(result)", buttonLabel: "OK")
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
