//
//  KeyboardViewController.swift
//  Okay Keyboard
//
//  Created by a on 18.07.2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var row123: UIStackView!

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.row123 = UIStackView()
        self.row123.alignment = .fill
        self.row123.distribution = .fillEqually
        self.row123.spacing = 8.0
        
        for item in 1...10 {
            let btn = UIButton(type: .system)
            btn.setTitle(NSLocalizedString(String(item), comment: "123"), for: [])
            btn.translatesAutoresizingMaskIntoConstraints = false
            row123.addArrangedSubview(btn)
            
        }
        makeABCbtns()
    }
    
    private func makeABCbtns(){
        let abcBtnView = self.view!
      let list = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "\\"],
        ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"],
        ["↑", " ", "GO"],
      ]
      var groups = [UIStackView]()

      for i in list {
        let group = createButtons(named: i)
        let subStackView = UIStackView(arrangedSubviews: group)
        subStackView.axis = .horizontal
        subStackView.distribution = .fillEqually
        subStackView.spacing = 1
        groups.append(subStackView)
      }

      let stackView = UIStackView(arrangedSubviews: groups)
      stackView.axis = .vertical
      stackView.distribution = .fillEqually
      stackView.spacing = 1
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
        return button
      }
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = true //!self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
