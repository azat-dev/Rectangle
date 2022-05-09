//
//  SuggestionItem.swift
//  Rectangle
//
//  Created by Azat Kaiumov on 08.05.22.
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Foundation

extension NSView {
    var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

class SuggestionItem: NSCollectionViewItem {
    
    var itemView: SuggestionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
    }
    
    override func loadView() {
        itemView = SuggestionView()
        view = itemView!
        isSelected = isSelected
    }
    
    override var isSelected: Bool {
      didSet {
          if isSelected {
              view.backgroundColor = .blue
          } else {
              view.backgroundColor = .clear
          }
      }
    }
}
