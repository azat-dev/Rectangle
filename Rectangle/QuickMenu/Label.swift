//
//  Label.swift
//  Rectangle
//
//  Created by Azat Kaiumov on 08.05.22.
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Foundation
import AppKit

open class Label: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
    }
}
