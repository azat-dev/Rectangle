//
//  SuggestionItemView.swift
//  Rectangle
//
//  Created by Azat Kaiumov on 08.05.22.
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Foundation
import AppKit

class SuggestionView: NSView {
    var label = Label()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setupViews()
        layout()
    }
    
    func setupViews() {
        //        label.stringValue = "Label"
        addSubview(label)
    }
    
    override func layout() {
        label.translatesAutoresizingMaskIntoConstraints = true
        label.autoresizingMask = [.width, .height]
    }
}
