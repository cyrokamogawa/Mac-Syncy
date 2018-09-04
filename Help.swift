//
//  Help.swift
//  Mac Syncy
//
//  Created by helpdesk on 8/22/18.
//  Copyright © 2018 helpdesk. All rights reserved.
//

import Cocoa

class Help: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //let link = NSTextField()
        link.isBezeled = false
        link.drawsBackground = false
        link.isEditable = false
        link.isSelectable = true
        link.allowsEditingTextAttributes = true
        let url = URL(string: "https://docs.google.com/document/d/13mS4KvlrrNTVosW7sAksc43dXCeRRmkDaOxop3BsHVc/edit?usp=sharing")
        let linkTextAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            NSAttributedStringKey.foregroundColor: NSColor.blue,
            NSAttributedStringKey.link: url as Any
        ]
        let string = "Mac Syncy User Manual"
        link.attributedStringValue = NSAttributedString(string: string, attributes: linkTextAttributes)
        //window.contentView?.addSubview(link)
    }
    
    @IBAction func dismissTabView(_ sender: NSButton) {
        dismissViewController(parent!)
    }

    @IBOutlet weak var helpText: NSTextField!
    @IBOutlet weak var link: NSTextField!
}
