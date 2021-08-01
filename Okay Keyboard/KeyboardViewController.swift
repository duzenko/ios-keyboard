//
//  KeyboardViewController.swift
//  Okay Keyboard
//
//  Created by a on 18.07.2021.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    var popUpView: UIView?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
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
            subStackView.spacing = 4
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
        stackView.spacing = 4
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
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onButtonLongPressed))
//        longTouchRecognizer.cancelsTouchesInView = false
        button.addGestureRecognizer(longTouchRecognizer)
        return button
      }
    }
    
    @objc func onButtonLongPressed (_ longPressGesture: UILongPressGestureRecognizer)
    {
        if (longPressGesture.state == .changed) {
            let tapLocation = longPressGesture.location(in: popUpView)
            let btnIndex = Int(tapLocation.x) / Int(longPressGesture.view!.frame.width)
            for (index, element) in popUpView!.subviews.enumerated() {
                element.backgroundColor = index == btnIndex ? UIColor.green : UIColor.white
            }
        }
        if (longPressGesture.state == .ended) {
            let proxy = self.textDocumentProxy
            for element in popUpView!.subviews {
                if(element.backgroundColor==UIColor.green) {
                    proxy.insertText((element as! UIButton).title(for: .normal)!)
                }
            }
            popUpView?.removeFromSuperview()
        }
        if (longPressGesture.state == .began)
        {
            guard let btn = longPressGesture.view as! UIButton? else { return }
            let tapLocation = longPressGesture.location(in: self.view)
            let w = btn.frame.width
            let h = btn.frame.height
            
            let popUpView=UIView(frame: CGRect(x: tapLocation.x-w, y: tapLocation.y-h*1.5, width: w*2, height: h))
            self.popUpView = popUpView
            popUpView.backgroundColor=UIColor.white
            
            let btn0: UIButton=UIButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
            btn0.setTitle(btn.title(for: .normal)!.uppercased(), for: .normal)
            btn0.setTitleColor(UIColor.black, for: .normal);
            btn0.layer.borderWidth=0.5
            btn0.layer.borderColor=UIColor.lightGray.cgColor
            
            popUpView.addSubview(btn0)
            
            let btn1: UIButton=UIButton(frame: CGRect(x: w, y: 0, width: w, height: h))
            btn1.setTitle(btn.title(for: .normal)!.lowercased(), for: .normal)
            btn1.setTitleColor(UIColor.black, for: .normal);
            btn1.layer.borderWidth=0.5
            btn1.layer.borderColor=UIColor.lightGray.cgColor
            
            popUpView.addSubview(btn1)
                
            self.view.addSubview(popUpView)
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let proxy = self.textDocumentProxy
        var key = sender.title(for: .normal)!.uppercased()
        switch key {
        case "←":
            proxy.deleteBackward()
        case "GO":
            proxy.insertText("\n")
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
        //print(self.needsInputModeSwitchKey)
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        print(textInput==nil)
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        print(self.textDocumentProxy.keyboardAppearance!)
        print(textInput==nil)
 }

}
