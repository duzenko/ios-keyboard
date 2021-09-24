//
//  KeyboardViewController.swift
//  Okay Keyboard
//
//  Created by a on 18.07.2021.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        let hostingController = UIHostingController(rootView: SwiftUIView())
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        addChild(hostingController)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("keyPress"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        print(notification.name)
        switch notification.name.rawValue {
        case "keyPress":
            return onKeyPress(notification.userInfo!["key"]! as! String)
        default:
            break;
        }
    }
    
    func onKeyPress(_ title: String) {
        let proxy = self.textDocumentProxy
        if title=="⏎" {
            proxy.insertText("\n")
            return
        }
        var key = title[title.startIndex].uppercased()
        switch key {
        case "←":
//            timer?.invalidate()
//            timer = nil
            proxy.deleteBackward()
        default:
            if let contents = proxy.documentContextBeforeInput {
                outerLoop: for char in contents.reversed() {
                    switch char {
                    case " ":
                        break;
                    case ".", "\n":
                        break outerLoop
                    default:
                        key = key.lowercased()
                        break outerLoop
                    }
                }
            }
            proxy.insertText(key)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
    }

}
