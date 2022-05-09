//
//  QuickMenuViewController.swift
//  Rectangle
//
//  Created by Azat Kaiumov on 08.05.22.
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox.Events

typealias SuggestionCallback = (
    _ windowManager: WindowManager,
    _ executionParams: ExecutionParameters,
    _ calculationParams: WindowCalculationParameters,
    _ activeWindowId: Int,
    _ activeWindow: AccessibilityElement
) -> Void

struct Suggestion {
    var title: String
    var commandName: String
    var shortName: String
    var windowAction: WindowAction?
    var execute: SuggestionCallback
    
    static func ==(lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.commandName == rhs.commandName
    }
}

class QuickMenuViewController: NSViewController {
    
    var textField = NSTextField()
    var scrollView = NSScrollView()
    var collectionView = NSCollectionView()
    var flowLayout = NSCollectionViewFlowLayout()
    var keyDownMonitor: Any?
    
    var windowManager: WindowManager!
    var executionParams: ExecutionParameters!
    var calculationParams: WindowCalculationParameters!
    var activeWindow: AccessibilityElement!
    var activeWindowId: Int!
    
    var currentIndex = 0 {
        didSet {
            DispatchQueue.main.async {
                var indexes = Set<IndexPath>()
                
                for index in 0..<self.suggestions.count {
                    indexes.insert(IndexPath(item: index, section: 0))
                }
                self.collectionView.reloadItems(at: indexes)
                
                
                if self.currentIndex < self.suggestions.count {
                    self.collectionView.selectItems(
                        at: [IndexPath(item: self.currentIndex, section: 0)],
                        scrollPosition: .nearestHorizontalEdge
                    )
                }
            }
        }
    }
    
    static var baseSuggestions: [Suggestion] {
        var result: [Suggestion] = []
        
        for (index, screen) in NSScreen.screens.enumerated() {
            let maxScreen = Suggestion(
                title: "Screen \(index + 1)",
                commandName: "nextDisplay\(index + 1)",
                shortName: "\(index + 1)",
                windowAction: .nextDisplay,
                execute: {
                    windowManager, executionParams, calculationParams, activeWindowId, activeWindow in
                    
                    let params = ExecutionParameters(
                        .nextDisplay,
                        updateRestoreRect: executionParams.updateRestoreRect,
                        screen: executionParams.screen,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: index
                    )
                    
                    windowManager.execute(params)
                    
                    
                    let params2 = ExecutionParameters(
                        .maximize,
                        updateRestoreRect: false,
                        screen: nil,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: nil
                    )
                    
                    windowManager.execute(params2)
                }
            )
            
            let leftHalfScreen = Suggestion(
                title: "Screen \(index + 1) left",
                commandName: "maximize",
                shortName: "\(index + 1)1",
                windowAction: .maximize,
                execute: {
                    windowManager, executionParams, calculationParams, activeWindowId, activeWindow in
                    
                    let params = ExecutionParameters(
                        .nextDisplay,
                        updateRestoreRect: executionParams.updateRestoreRect,
                        screen: executionParams.screen,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: index
                    )
                    
                    windowManager.execute(params)
                    
                    
                    let params2 = ExecutionParameters(
                        .leftHalf,
                        updateRestoreRect: false,
                        screen: nil,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: nil
                    )
                    
                    windowManager.execute(params2)
                }
            )

            let rightHalfScreen = Suggestion(
                title: "Screen \(index + 1) right",
                commandName: "maximize",
                shortName: "\(index + 1)2",
                windowAction: .maximize,
                execute: {
                    windowManager, executionParams, calculationParams, activeWindowId, activeWindow in
                    
                    let params = ExecutionParameters(
                        .nextDisplay,
                        updateRestoreRect: executionParams.updateRestoreRect,
                        screen: executionParams.screen,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: index
                    )
                    
                    windowManager.execute(params)
                    
                    
                    let params2 = ExecutionParameters(
                        .rightHalf,
                        updateRestoreRect: false,
                        screen: nil,
                        windowElement: activeWindow,
                        windowId: activeWindowId,
                        source: executionParams.source,
                        targetScreenIndex: nil
                    )
                    
                    windowManager.execute(params2)
                }
            )
            
            result += [
                maxScreen,
                leftHalfScreen,
                rightHalfScreen
            ]
            
        }
        
//        result += [
//            Suggestion(
//                title: "Maximize",
//                commandName: "maximize",
//                shortName: "m",
//                windowAction: .maximize
//            ),
//
//            Suggestion(
//                title: "Smaller",
//                commandName: "smaller",
//                shortName: "s",
//                windowAction: .almostMaximize
//            )
//        ]
        
//        for item in WindowAction.active {
//            result.append(
//                Suggestion(
//                    title: item.name,
//                    commandName: item.name,
//                    shortName: item.name,
//                    windowAction: item
//                )
//            )
//        }
//
        return result
    }
    
    var suggestions = baseSuggestions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        setupViews()
        layout()
    }
    
    func setupViews() {
        
        textField.placeholderString = "Command..."
        if #available(macOS 11.0, *) {
            textField.font = .preferredFont(forTextStyle: .title1)
        }
        textField.becomeFirstResponder()
        textField.delegate = self
        
        view.addSubview(textField)
        
        setupCollectionView()
        
        scrollView.documentView = collectionView
        view.addSubview(scrollView)
    }
    
    func setupCollectionView() {
        
        collectionView.collectionViewLayout = flowLayout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false
        
        currentIndex = 0
        scrollView.layer?.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0)
        scrollView.layer?.borderColor = .white
        scrollView.layer?.borderWidth = 3
        
        collectionView.register(
            SuggestionItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SuggestionItem")
        )
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        attachKeyListener()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        detachKeyListener()
    }
    
    func layout() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizesSubviews = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: textField.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),
            
            collectionView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 10000),
        ])
    }
}

extension QuickMenuViewController: NSTextFieldDelegate {
    
    func filterSuggestions(text: String) {
        guard !text.isEmpty else {
            suggestions = Self.baseSuggestions
            collectionView.reloadData()
            return
        }
        
        var filteredSuggestions = [Suggestion]()
        
        Self.baseSuggestions.forEach { suggestion in
            if !filteredSuggestions.contains { $0 == suggestion } && suggestion.shortName == text {
                filteredSuggestions.append(suggestion)
            }
        }
        
        
        Self.baseSuggestions.forEach { suggestion in
            if !filteredSuggestions.contains { $0 == suggestion } && suggestion.title.starts(with: text) {
                filteredSuggestions.append(suggestion)
            }
        }
        
        
        Self.baseSuggestions.forEach { suggestion in
            if !filteredSuggestions.contains { $0 == suggestion } && suggestion.title.lowercased().starts(with: text.lowercased()) {
                filteredSuggestions.append(suggestion)
            }
        }
        
        Self.baseSuggestions.forEach { suggestion in
            if !filteredSuggestions.contains { $0 == suggestion } && suggestion.title.contains(text) {
                filteredSuggestions.append(suggestion)
            }
        }
        
        Self.baseSuggestions.forEach { suggestion in
            if !filteredSuggestions.contains { $0 == suggestion } && suggestion.title.lowercased().contains(text.lowercased()) {
                filteredSuggestions.append(suggestion)
            }
        }
        
        suggestions = filteredSuggestions
        collectionView.reloadData()
        
        if !suggestions.isEmpty {
            currentIndex = 0
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        print("obj \(textField.stringValue)")
        let trimmedValue = textField.stringValue.trimmingCharacters(in: .whitespaces)
        
        DispatchQueue.main.async {
            self.filterSuggestions(text: trimmedValue)
        }
    }
}

extension QuickMenuViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("SuggestionItem"),
            for: indexPath
        ) as! SuggestionItem
        
        let suggestion = suggestions[indexPath.item]
        item.itemView?.label.stringValue = "\(suggestion.title) - [\(suggestion.shortName)]"
        item.isSelected = indexPath.item == currentIndex
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
}

extension QuickMenuViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        currentIndex = indexPaths.first?.item ?? 0
        collectionView.reloadData()
    }
}


extension QuickMenuViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        return NSSize(width: collectionView.bounds.width - 40, height: 30)
    }
    
}

extension QuickMenuViewController {
    private func onCloseWindow() {
        view.window?.close()
    }
    
    private func onMoveToNextItem() {
        if currentIndex < suggestions.count - 1 {
            collectionView.reloadData()
            currentIndex += 1
        }
    }
    
    private func onMoveToPrevItem() {
        if currentIndex > 0 {
            collectionView.reloadData()
            currentIndex -= 1
        }
    }
    
    private func onExecuteCurrentCommand() {
        if currentIndex >= suggestions.count {
            return
        }
        
        let suggestion = suggestions[currentIndex]
        suggestion.execute(
            windowManager,
            executionParams,
            calculationParams,
            activeWindowId,
            activeWindow
        )
        
        
        activeWindow.bringToFront(force: true)
        onCloseWindow()
    }
    
    func attachKeyListener() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            event in
            
            switch Int(event.keyCode) {
            case kVK_Escape:
                self.activeWindow.bringToFront(force: true)
                self.onCloseWindow()
            case kVK_DownArrow:
                self.onMoveToNextItem()
                return nil
            case kVK_UpArrow:
                self.onMoveToPrevItem()
                return nil
            case kVK_Return:
                self.onExecuteCurrentCommand()
                return nil
            default:
                break
            }
            
            print(event)
            
            return event
        }
    }
    
    func detachKeyListener() {
        guard let keyDownMonitor = keyDownMonitor else {
            return
        }
        
        NSEvent.removeMonitor(keyDownMonitor)
    }
}
