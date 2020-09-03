//
//  WalletsViewController.swift
//  GordianServer-macOS
//
//  Created by Peter on 9/3/20.
//  Copyright © 2020 Peter. All rights reserved.
//

import Cocoa

class WalletsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var window: NSWindow?
    var wallets = [[String:String]]()
    var env = [String:String]()
    var index = 0
    var chain = ""
    let d = Defaults()
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setEnv()
        getWallets()
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "Wallets \(chain)"
    }
    
    enum CellIdentifiers {
      static let WalletNameCell = "WalletNameCellID"
    }
    
    func setEnv() {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir(), "CHAIN":chain, "COMMAND":"listwalletdir"]
        #if DEBUG
        print("env = \(env)")
        #endif
    }
    
    private func getWallets() {
        runScript(script: .rpc, env: env, args: [""]) { [weak self] (ws) in
            if ws != nil {
                for (i, wallet) in ws!.enumerated() {
                    let dict = wallet as? NSDictionary ?? [:]
                    var name = dict["name"] as? String ?? ""
                    if name == "" {
                        name = "Default wallet"
                    }
                    let w = ["name":name]
                    self?.wallets.append(w)
                    if i + 1 == ws!.count {
                        DispatchQueue.main.async { [weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return wallets.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

      var text: String = ""
      var cellIdentifier: String = ""

      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .long
      
      // 1
      let item = wallets[row]

      // 2
      if tableColumn == tableView.tableColumns[0] {
        text = item["name"] ?? "Default wallet"
        cellIdentifier = CellIdentifiers.WalletNameCell
      }

      // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = text
        return cell
      }
      return nil
    }
    
    private func runScript(script: SCRIPT, env: [String:String], args: [String], completion: @escaping ((NSArray?)) -> Void) {
        #if DEBUG
        print("script: \(script.rawValue)")
        #endif
        let resource = script.rawValue
        guard let path = Bundle.main.path(forResource: resource, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = env
        task.arguments = args
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errorData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var errorMessage = ""
        if let errorOutput = String(data: errorData, encoding: .utf8) {
            if errorOutput != "" {
                errorMessage += errorOutput
                setSimpleAlert(message: "Error", info: errorMessage, buttonLabel: "OK")
                completion((nil))
            }
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                if let wallets = dict["wallets"] as? NSArray {
                    completion((wallets))
                } else {
                    completion((nil))
                }
            } else {
                completion(nil)
            }
        } catch {
            completion((nil))
        }
    }
    
}
