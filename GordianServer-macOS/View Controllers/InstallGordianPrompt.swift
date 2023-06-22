//
//  InstallGordianPrompt.swift
//  GordianServer-macOS
//
//  Created by Peter Denton on 10/5/21.
//  Copyright © 2021 Peter. All rights reserved.
//

import Cocoa

class InstallGordianPrompt: NSViewController, NSWindowDelegate {
    
    var window: NSWindow?
    var version = ""
    var macosURL = ""
    var defaults = Defaults.shared
    var doneBlock: ((Bool) -> Void)?
    var initialLoad = false
    
    @IBOutlet weak var headerOutlet: NSTextField!
    @IBOutlet weak var bodyOutlet: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setHeaderText()
        initialLoad = true
    }
    
    override func viewDidAppear() {
        if initialLoad {
            window = self.view.window!
            self.view.window?.title = "Installer"
            initialLoad = false
        }
        
        defaults.setDefaults { [weak self] in
            guard let self = self else { return }
            
            self.setBodyText()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.window?.performClose(self)
            self.doneBlock!(false)
        }
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "segueToAdvancedSettings", sender: self)
        }
    }
    
    @IBAction func installAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.window?.performClose(self)
            self.doneBlock!(true)
        }
    }
    
    private func setHeaderText() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.headerOutlet.stringValue = "Install Bitcoin Core v\(self.version)?"
        }
    }
    
    private func setBodyText() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let pruned = self.defaults.prune
            let txindex = self.defaults.txindex
            let directory = self.defaults.dataDir
            let blockdir = self.defaults.blocksDir
            let pruneInGb = Double(pruned) / 954.0
            let rounded = Double(round(100 * pruneInGb) / 100)
                        
            var bodyText = """
                            Gordian Server will download Bitcoin Core from \(self.macosURL)
                            
                            A directory will be created at ~/.gordian which holds the Bitcoin Core binaries, pgp keys for the Bitcoin Core developers along with their signatures so they can be verified before installation.
                            
                            Tor is integrated into the app so as to not interfere with other apps which utilize Tor. Tor files can be found in ~/.gordian apart from the torrc file which will be located at ~/.torrc
                            
                            Gordian Server will check for existing Bitcoin Core data and the configuration file at \(directory)
                            
                            Gordian Server will use \(blockdir) to store the blockchain.
                            
                            Advanced users may select a custom data directory, blocks directory and blockchain size by clicking "Advanced Settings" below.
                            
                            """
            
            if pruned != 0 {
                bodyText += """
                    
                    Your node will be pruned to \(rounded) gb, you may edit this by selecting "Advanced Settings".
                    
                    """
            } else if txindex == 1{
                bodyText += """
                    
                    Your node will download and index the entire blockchain, this can take up 400 gb of disk space. You may edit this by selecting "Advanced Settings".
                    
                    """
            }
            
            let path = URL(fileURLWithPath: "\(directory)/bitcoin.conf")
            
            if let _ = try? String(contentsOf: path, encoding: .utf8) {
                
                bodyText += """
                    
                    ⚠️ You have an existing Bitcoin Core configuration file in \(directory). Gordian Server will check it for rpc credentials and add them if they are missing along with Tor related settings, existing settings will not be edited.
                    """
               
            }
            
            self.bodyOutlet.stringValue = bodyText
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? Settings {
            vc.doneBlock = { [weak self] response in
                guard let self = self else { return }
                
                self.setBodyText()
            }
        }
    }
    
    
}
