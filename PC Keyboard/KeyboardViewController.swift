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
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("keyPreview"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        switch notification.name.rawValue {
        case "keyPress":
            return onKeyPress(notification.userInfo!["key"]! as! String, notification.userInfo!["autoCase"] as! Bool)
        case "keyPreview":
            return onKeyPreview(notification.userInfo!["key"] as! String?)
        default:
            break;
        }
    }

    var timer: Timer?;

    func onKeyPreview(_ title: String?) {
        if(title != "←") {
            timer?.invalidate()
            timer = nil
            return
        }
        if(timer != nil) {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
            let proxy = self.textDocumentProxy
            proxy.deleteBackward()
        })
    }
    
    func onKeyPress(_ title: String, _ autoCase: Bool) {
        let proxy = self.textDocumentProxy
        if title=="⏎" {
            proxy.insertText("\n")
            return
        }
        if title=="🌐" {
            self.advanceToNextInputMode()
            return
        }
        var key = title
        switch key {
        case "←":
            proxy.deleteBackward()
        default:
            if autoCase {
                if [.emailAddress, .URL, .webSearch].contains(proxy.keyboardType)  {
                    key = key.lowercased()
                } else {
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
