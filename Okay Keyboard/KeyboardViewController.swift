//
//  KeyboardViewController.swift
//  Okay Keyboard
//
//  Created by a on 18.07.2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeABCbtns()
    }
    
    private func makeABCbtns(){
        let abcBtnView = self.view!
      let list = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "\\"],
        ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"],
        [//"↑",
            "←", " ", "GO"],
      ]
      var groups = [UIStackView]()

      for i in list {
        let group = createButtons(named: i)
        let subStackView = UIStackView(arrangedSubviews: group)
        subStackView.axis = .horizontal
        subStackView.distribution = .fillProportionally
        subStackView.spacing = 2
        if i.contains(" ") {
            for (index, element) in subStackView.subviews.enumerated() {
                if index != 1 {
                    element.widthAnchor.constraint(equalTo: subStackView.subviews[1].widthAnchor, multiplier: 0.5).isActive = true
                }
            }
        }
        groups.append(subStackView)
      }

      let stackView = UIStackView(arrangedSubviews: groups)
      stackView.axis = .vertical
      stackView.distribution = .fillEqually
      stackView.spacing = 2
      stackView.translatesAutoresizingMaskIntoConstraints = false

      abcBtnView.addSubview(stackView)

      stackView.leadingAnchor.constraint (equalTo: abcBtnView.leadingAnchor,  constant: 0).isActive = true
      stackView.topAnchor.constraint     (equalTo: abcBtnView.topAnchor,      constant: 0).isActive = true
      stackView.trailingAnchor.constraint(equalTo: abcBtnView.trailingAnchor, constant: 0).isActive = true
      stackView.bottomAnchor.constraint  (equalTo: abcBtnView.bottomAnchor,   constant: 0).isActive = true
    }

    func createButtons(named: [String]) -> [UIButton]{
      return named.map { letter in
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(letter, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor( .black , for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
      }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let proxy = self.textDocumentProxy
        let key = sender.title(for: .normal)!.lowercased()
        switch key {
        case "←":
            proxy.deleteBackward()
        case "go":
            proxy.insertText("\n")
        default:
            proxy.insertText(key)
        }
    }
    
    override func viewWillLayoutSubviews() {
        print(self.needsInputModeSwitchKey)
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        print(self.textDocumentProxy.keyboardAppearance!)
    }

}
