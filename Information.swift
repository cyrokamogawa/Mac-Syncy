//
//  Information.swift
//  Mac Syncy
//
//  Created by helpdesk on 8/22/18.
//  Copyright © 2018 helpdesk. All rights reserved.
//

import Cocoa

class Information: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBAction func dismissTabView(_ sender: NSButton) {
        dismissViewController(parent!)
    }
}
