//
//  AccessibilityAuthorization.swift
//  Rectangle
//
//  Created by Ryan Hanson on 6/11/19.
//  Copyright © 2019 Ryan Hanson. All rights reserved.
//

import Foundation
import Cocoa

class AccessibilityAuthorization {
    
    private var accessibilityWindowController: NSWindowController?
    
    public func checkAccessibility(completion: @escaping () -> Void) -> Bool {
//        let quickMenuWindowController = NSStoryboard(name: "Main", bundle: nil)
//            .instantiateController(withIdentifier: "QuickMenuWindowController") as? NSWindowController
//        guard let welcomeWindow = quickMenuWindowController?.window else { return false }
//        welcomeWindow.minSize = .init(width: 300, height: 300)
//////        welcomeWindow.delegate = self
////
////
//        NSApp.activate(ignoringOtherApps: true)
////
//        let response = NSApp.runModal(for: welcomeWindow)
//        return false
        
        
        if !AXIsProcessTrusted() {
            
            accessibilityWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AccessibilityWindowController") as? NSWindowController
            
            NSApp.activate(ignoringOtherApps: true)
            accessibilityWindowController?.showWindow(self)
            pollAccessibility(completion: completion)
            print("Doesn't work")
            return false
        } else {
            print("Works")
            return true
        }
    }
    
    private func pollAccessibility(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if AXIsProcessTrusted() {
                self.accessibilityWindowController?.close()
                self.accessibilityWindowController = nil
                completion()
            } else {
                self.pollAccessibility(completion: completion)
            }
        }
    }
    
    func showAuthorizationWindow() {
        if accessibilityWindowController?.window?.isMiniaturized == true {
            accessibilityWindowController?.window?.deminiaturize(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
