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
        var groups = [UIStackView]()
        
        for row in 0...4 {
            var rowKeys: [[String]] = ["←", " ", "GO"].unflat()
            if row<4 {
                let rowStart = row*10
                let rowEnd = row*10+10
                rowKeys = Array(EnglishLayout[rowStart..<rowEnd])
            }
            let group = createButtons(rowKeys, row<4)
            let subStackView = UIStackView(arrangedSubviews: group)
            subStackView.axis = .horizontal
            subStackView.distribution = .fillProportionally
            subStackView.spacing = 4
            if row == 4 {
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

    func createButtons(_ named: [[String]], _ withOptions: Bool) -> [UIButton] {
      return named.map { symbols in
        let attributedString = NSMutableAttributedString(string:"\(symbols[0])")
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 9.0)]
        if withOptions {
            let gString = NSMutableAttributedString(string:"\n", attributes:attrs)
            attributedString.append(gString)
            for (index, symbol) in symbols.enumerated() {
                if index==0 {
                    continue
                }
                let gString = NSMutableAttributedString(string:symbol, attributes:attrs)
                attributedString.append(gString)
            }
        }
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor( .black , for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onButtonLongPressed))
        button.addGestureRecognizer(longTouchRecognizer)
        return button
      }
    }
    
    @objc func onButtonLongPressed (_ longPressGesture: UILongPressGestureRecognizer)
    {
        if (longPressGesture.state == .changed && popUpView != nil) {
            let tapLocation = longPressGesture.location(in: popUpView)
            let btnIndex = Int(tapLocation.x) / Int(longPressGesture.view!.frame.width)
            for (index, element) in popUpView!.subviews.enumerated() {
                element.backgroundColor = index == btnIndex ? UIColor.green : UIColor.white
            }
        }
        if (longPressGesture.state == .ended && popUpView != nil) {
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
            var options: [String] = []
            let x = btn.attributedTitle(for: .normal)!.string
            let symbol = "\(x[x.startIndex])"
            for key in EnglishLayout {
                if key[0] == symbol {
                    options = key
                    break
                }
            }
            if options.isEmpty {
                return
            }
            let lowerCase = options[0].lowercased()
            if lowerCase != options[0] {
                options.insert(lowerCase, at: 1)
            }
            
            let tapLocation = longPressGesture.location(in: self.view)
            let w = btn.frame.width
            let h = btn.frame.height
            
            let popUpView=UIView(frame: CGRect(x: tapLocation.x-w*CGFloat(options.count)/2, y: tapLocation.y-h*1.5, width: w*CGFloat(options.count), height: h))
            self.popUpView = popUpView
            popUpView.backgroundColor=UIColor.white
            
            for (index, option) in options.enumerated() {
                let btn0: UIButton=UIButton(frame: CGRect(x: CGFloat(index)*w, y: 0, width: w, height: h))
                btn0.setTitle(option, for: .normal)
                btn0.setTitleColor(UIColor.black, for: .normal);
                btn0.layer.borderWidth=0.5
                btn0.layer.borderColor=UIColor.lightGray.cgColor
                
                popUpView.addSubview(btn0)
            }
                           
            self.view.addSubview(popUpView)
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let proxy = self.textDocumentProxy
        let title = sender.attributedTitle(for: .normal)!.string
        if title=="GO" {
            proxy.insertText("\n")
            return
        }
        var key = title[title.startIndex].uppercased()
        switch key {
        case "←":
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
