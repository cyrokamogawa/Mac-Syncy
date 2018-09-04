//
//  ViewController.swift
//  MacSyncy
//
//  Created by helpdesk on 5/1/18.
//  Copyright © 2018 helpdesk. All rights reserved.
//

// TODO:
// Bug fixes:
/* After performing a backup, the app will have to be quit to perform another backup. If one tries to perform a backup immediately following another backup, it won't go through*/
// Features:
// Progress bar (not sure if possible)
// 'Pause backup' button (create a script to send CTRL+Z to pause rsync)
// Update the Help section with all the information in the Google Doc

import Cocoa
import Foundation
import AppKit

class ViewController: NSViewController {
    
    var sourcePath: String?
    var destinationPath: String?
    
    var previousSourceFilename: String = ""
    var previousDestinationFilename: String = ""
    
    //@IBOutlet weak var sourceImageView: NSImageView!
    //@IBOutlet weak var destinationImageView: NSImageView!
    @IBOutlet weak var sourceButton: NSButton!
    @IBOutlet weak var destinationButton: NSButton!
    @IBOutlet weak var backupButton: NSButton!
    @IBOutlet weak var cancelBackupButton: NSButton!
    @IBOutlet weak var stopText: NSTextField!
    
    @IBOutlet weak var selectSourceLabel: NSTextField!
    @IBOutlet weak var selectDestinationLabel: NSTextField!
    @IBOutlet weak var previousBackupLabel: NSTextField!
    
    // Indeterminate progress bar
    @IBOutlet weak var indProgressBar: NSProgressIndicator!
    // Determinate progress bar (non-functional)
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var hasSource = false
    var hasDestination = false
    
    var process:Process!
    var outputTimer: Timer?
    let pipe = Pipe()
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        enableBackupButton()
        cancelBackupButton.isHidden = true
        progressBar.isHidden = true
        indProgressBar.isHidden = true
    }
    
    func enableBackupButton() {
        if (hasSource && hasDestination) {
            backupButton.isEnabled = true
        } else {
            backupButton.isEnabled = false
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // Select a source
    @IBAction func sourceButtonPressed(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a source directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                // Path of the directory
                let path = result!.path
                sourcePath = path
                let fileName = result!.lastPathComponent
                
                // Change image and fileName displayed
                sourceButton.image = NSImage(named: NSImage.Name(rawValue: "fileSelected"))
                selectSourceLabel.stringValue = fileName
                previousSourceFilename = fileName
                hasSource = true
                enableBackupButton()
            }
        }
        // Pressed cancel while selecting source
        else {
            return
        }
    }
    
    // Select a destination
    @IBAction func destinationButtonPressed(_ sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a destination directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                // Path of the directory
                let path = result!.path
                destinationPath = path
                let fileName = result!.lastPathComponent
                
                // Change image displayed
                destinationButton.image = NSImage(named: NSImage.Name(rawValue: "fileSelected"))
                selectDestinationLabel.stringValue = fileName
                previousDestinationFilename = fileName
                hasDestination = true
                enableBackupButton()
            }
        }
        // Pressed cancel while selecting destination
        else {
            return
        }
    }
    
    // Pressed backup
    @IBAction func startBackup(_ sender: NSButton) {
        
        if sourcePath != nil && destinationPath != nil {
            indProgressBar.isHidden = false
            cancelBackupButton.isHidden = false
            stopText.stringValue = "Stop"
            sender.isEnabled = false
            
            // Path and directory for the backup script
            let path = "/bin/bash"
            let workDir = "/Users/helpdesk/Desktop/Mac Syncy scripts"
            // Arguments to the backup script
            let arguments = ["backup.sh", sourcePath, destinationPath]
            
            // Initiate the backup as a Process
            process = Process.init()
            process.launchPath = path
            process.arguments = (arguments as! [String]) // parentheses silence warning
            process.currentDirectoryPath = workDir
            process.standardOutput = pipe
            
            // Call to start the progress bar, which is not currently functional
            //startProgressBar()
            
            // Prepare the Process for running
            self.process.launch()
            
            previousBackupLabel.stringValue = "Transferring   \(previousSourceFilename)   to   \(previousDestinationFilename)"
            self.indProgressBar.startAnimation(self)
            
            // We open a new thread to run the backup so that the GUI can remain functional on the main thread
            DispatchQueue.global().async {
                // This runs in a worker thread, so the UI remains responsive
                
                // Start the script
                self.process.waitUntilExit()
                
                DispatchQueue.main.async {
                    // In the main thread:
                    if let timer = self.outputTimer {
                        timer.invalidate()
                        self.outputTimer = nil
                    }
                    
                    // *** BACKUP HAS COMPLETED ***
                    
                    // ----------------------------------------
                    // TEMPORARY CODE:
                    // Until the consecutive backups bug is fixed, display a message and close the app as soon as the backup finishes
                    self.indProgressBar.stopAnimation(self)
                    let alert = NSAlert.init()
                    alert.messageText = "Backup has completed. Mac Syncy will now close. Byeeeee."
                    alert.runModal()
                    self.ExitNow(sender: self)
                    // ----------------------------------------
                    
                    // Reset the button images and file labels
                    self.sourceButton.image = NSImage(named: NSImage.Name(rawValue: "emptyFolder"))
                    self.destinationButton.image = NSImage(named: NSImage.Name(rawValue: "emptyFolder"))
                    self.selectSourceLabel.stringValue = "None Selected"
                    self.self.selectDestinationLabel.stringValue = "None Selected"
                    self.previousBackupLabel.stringValue = "You have successfully transferred   \(self.previousSourceFilename)   to   \(self.previousDestinationFilename)"
                    self.hasSource = false
                    self.hasDestination = false
                    self.enableBackupButton()
                    self.cancelBackupButton.isEnabled = false
                }
            }
        }
        // If no source or destination, display error message
        else {
            let alert = NSAlert.init()
            if sourcePath == nil {
                alert.messageText = "Please select a source directory"
            }
            else {
                alert.messageText = "Please select a destination directory"
            }
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    // Pressed Cancel button during backup
    @IBAction func cancelBackup(_ sender: NSButton) {
        
        // Since the backup is using a separate Process (rsync, through Terminal), we have to cancel it through rsync's Cancel function
        // We do this with a new script
        let path = "/bin/bash"
        let workDir = "/Users/helpdesk/Desktop/Mac Syncy scripts"
        let arguments = ["cancel.sh"]
        
        process = Process.init()
        process.launchPath = path
        process.arguments = arguments
        process.currentDirectoryPath = workDir
        
        self.process.launch()
        DispatchQueue.global().async {
            // This runs in a worker thread, so the UI remains responsive
            self.process.waitUntilExit()
            DispatchQueue.main.async {
                // Main thread:
                if let timer = self.outputTimer {
                    timer.invalidate()
                    self.outputTimer = nil
                }
            }
        }
    }
    
    /*
     - Unfortunately, we were unable to get the progress bar working.
     - To get a progress bar working, you would have to read rsync's verbose output
     using the -v flag (which is already in the script)
     - This function would run on the worker thread so that the GUI can keep running
     on the main thread and continue taking input (e.g., cancel backup)
     - The worker thread would have to constantly read the output and look for the words
     "to-check" (see the  testLine  variable in this function for an example)
     - We would then parse this line, looking for only the numbers after "to-check"
     because this is the current progress
     - Once we retrieve these values, we convert them to doubles and update the progressBar
     with the result of dividing them
     - After finishing updating the progress bar's value, it will have to go back to
     reading the output to look for the next value
     */
    @objc func startProgressBar() {
        
        progressBar.isHidden = false
        // Constant variable used for testing
        let testLine = "614375636 100%   34.40MB/s    0:00:17 (xfer#1, to-check=176/183)"
        
        // Retrieve the current progress from the current line
        // Remove words/values before "to-check"
        var split = testLine.split(separator: " ")
        var currentProgress = String(split.suffix(1).joined(separator: [" "]))
        // Remove the words "to-check="
        currentProgress.removeFirst(9)
        // Remove the ending ")"
        currentProgress.removeLast(1)
        
        // Split the current progress into divisor and dividend
        split = currentProgress.split(separator: "/")
        // These "let" statements will probably have to change to "var" once the
        // program is reading and updating data constantly
        let divisorStr = String(split.prefix(1).joined(separator: ["/"]))
        let divisor = Double(divisorStr)
        let dividendStr = String(split.suffix(1).joined(separator: ["/"]))
        let dividend = Double(dividendStr)
        
        // The following if-else blocks are for debugging the error that follows them
        // These if-else blocks tell us whether or not the variables "divisor" and
        // "dividend" contain values
        // It turns out they do, so I have no idea why I was getting the error
        if let number = divisor {
            print("Contains a value! It is \(number)!")
        } else {
            print("Doesn’t contain a number")
        }
        if let number = dividend {
            print("Contains a value! It is \(number)!")
        } else {
            print("Doesn’t contain a number")
        }
        // ERROR HERE
        // Update progress bar value
        progressBar.doubleValue = Double(dividend! / divisor!)
        
        /* TODO:
         1. Fix the error
         2. Confirm that the progress bar is able to update and display the correct value
         3. Get the thread to read the Process' output continuously
         4. After reading a value, update the progress bar
         5. Go back to reading output
         6. Repeat until the Process exits
        */
        
        /* At the very least, if you can't get a progress bar working, you can probably just read and print out the current status (e.g. 100/179) that you are retrieving from the transfer progress */
    }
    
    // Close the application
    @IBAction func ExitNow(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
}
