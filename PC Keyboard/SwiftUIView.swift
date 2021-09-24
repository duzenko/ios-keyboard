//
//  SwiftUIView.swift
//  PC Keyboard
//
//  Created by a on 19.09.2021.
//

import SwiftUI

let englishLayout = getEnglishLayout()

func getLayoutRow(_ row: Int) -> [[String]] {
    if row<4 {
        let rowStart = row*10
        let rowEnd = row*10+10
        return Array(englishLayout[rowStart..<rowEnd])
    }
    return ["←", " ", "⏎"].unflat()
}

struct KeyButton: View {
    let keyOptions: [String]
    
    var body: some View {
        Button(action: {
            print("action")
        }, label: {
            ZStack(alignment: .bottomTrailing) {
                Text(keyOptions.first!).frame(maxWidth: .infinity, maxHeight: .infinity).offset(x: -4, y: -4)
                if(keyOptions.count>1) {
                    Text(keyOptions.joined().dropFirst()).font(.system(size: 11, weight: .bold)).offset(x: -2, y: -2)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(        DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    print("onChanged", value)
                                }
                                .onEnded { x in
                                    print("onEnded", x)
                                })
        }).foregroundColor(Color.black)
    }
}

struct KeyRow: View {
    let rowKeys: [[String]]
    
    @State
    private var height: CGFloat = .zero // < calculable height
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(rowKeys, id: \.self) {rowKey in
                if (rowKeys.count>3) {
                    KeyButton (keyOptions: rowKey).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(.white)).border(Color.gray, width: 1)
                        //.aspectRatio(0.5, contentMode: .fill)
                } else {
                    KeyButton (keyOptions: rowKey).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(.white)).border(Color.gray, width: 1)
                }
            }
        }.alignmentGuide(.top, computeValue: { d in
            DispatchQueue.main.async { // << dynamically detected - needs to be async !!
                self.height = max(d.height, self.height)
            }
            return d[.top]
        })
    }
}

struct SwiftUIView: View {
    
    var popUpView: UIView?
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<5) { row in
                KeyRow(rowKeys: getLayoutRow(row)).frame(maxHeight: .infinity)
            }
        }.padding(2)
    }
    
    func makeButtonRows() {
//        let abcBtnView = self
//        var groups = [UIStackView]()
//
//        for row in 0...4 {
//            subStackView.distribution = .fillProportionally
//            subStackView.spacing = 4
//            if row == 4 {
//                for (index, element) in subStackView.subviews.enumerated() {
//                    if index != 1 {
//                        element.widthAnchor.constraint(equalTo: subStackView.subviews[1].widthAnchor, multiplier: 0.5).isActive = true
//                    }
//                }
//            }
//            groups.append(subStackView)
//        }
        
//        let stackView = UIStackView(arrangedSubviews: groups)
//        stackView.axis = .vertical
//        stackView.distribution = .fillEqually
//        stackView.spacing = 4
//        stackView.translatesAutoresizingMaskIntoConstraints = false

//        stackView.leadingAnchor.constraint (equalTo: abcBtnView.leadingAnchor,  constant: 0).isActive = true
//        stackView.topAnchor.constraint     (equalTo: abcBtnView.topAnchor,      constant: 0).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: abcBtnView.trailingAnchor, constant: 0).isActive = true
//        stackView.bottomAnchor.constraint  (equalTo: abcBtnView.bottomAnchor,   constant: 0).isActive = true
        
//        return stackView
    }
    
    /*func createButton(_ symbols: [String], _ withOptions: Bool) -> UIButton {
        let attributedString = NSMutableAttributedString(string:"\(symbols[0])", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)])
        if withOptions {
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11.0)]
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
        button.addTarget(self, action: #selector(buttonUpAction), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonDownAction), for: .touchDown)
        if(withOptions) {
            let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onButtonLongPressed))
            button.addGestureRecognizer(longTouchRecognizer)
            button.contentEdgeInsets = UIEdgeInsets.init(top: -0, left: 0, bottom: -0, right: 0)
        }
        button.tag = withOptions ? 0 : symbols.first == "←" ? 2 : 1;
        return button
    }

    func createButtons(_ named: [[String]], _ withOptions: Bool) -> [UIButton] {
      return named.map { symbols in
        return createButton(symbols, withOptions)
      }
    }
    
    var timer: Timer?;
    
    @objc func buttonDownAction(btn: UIButton!) {
        btn.backgroundColor = .lightGray
        if(btn.tag == 2) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
                let proxy = self.textDocumentProxy
                proxy.deleteBackward()
            })
        }
        if(btn.tag >= 1) {
            return;
        }
        popUpView?.removeFromSuperview()
        let xy = btn.convert(btn.bounds.origin, to: self.view)
        let w = btn.frame.width
        let h = btn.frame.height
        let x = xy.x
        let y = xy.y > h ? xy.y-h : h*3
        let popUpView=UIView(frame: CGRect(x: x, y: y, width: w, height: h))
        self.popUpView = popUpView
        popUpView.backgroundColor=UIColor.white
        let btn0: UIButton=UIButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
        let title = btn.attributedTitle(for: .normal)!.string
        btn0.setTitle(title, for: .normal)
        btn0.setTitleColor(.white, for: .normal)
        btn0.backgroundColor = .black
        btn0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        popUpView.addSubview(btn0)
        self.view.addSubview(popUpView)
    }
    
    func showOptions(_ longPressGesture: UILongPressGestureRecognizer) {
        guard let btn = longPressGesture.view as! UIButton? else { return }
        var options: [String] = []
        let title = btn.attributedTitle(for: .normal)!.string
        let symbol = "\(title[title.startIndex])"
        for key in englishLayout {
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
        let tmp = CGFloat(options.count)
        let xOffset = w*tmp/2;
        let x = max(0, tapLocation.x-xOffset)
        let y = tapLocation.y > h*1.5 ? tapLocation.y-h*1.5 : h*3
        popUpView?.removeFromSuperview()
        let popUpView=UIView(frame: CGRect(x: x, y: y, width: w*CGFloat(options.count), height: h))
        self.popUpView = popUpView
        popUpView.backgroundColor = .black
        
        for (index, option) in options.enumerated() {
            let btn0: UIButton=UIButton(frame: CGRect(x: CGFloat(index)*w, y: 0, width: w, height: h))
            btn0.setTitle(option, for: .normal)
            btn0.setTitleColor(UIColor.white, for: .normal)
            btn0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btn0.layer.borderWidth=0.5
            btn0.layer.borderColor=UIColor.lightGray.cgColor
            popUpView.addSubview(btn0)
        }
                       
        self.view.addSubview(popUpView)
    }
    
    @objc func onButtonLongPressed (_ longPressGesture: UILongPressGestureRecognizer)
    {
        if (longPressGesture.state == .changed && popUpView != nil) {
            let tapLocation = longPressGesture.location(in: popUpView)
            let btnIndex = Int(tapLocation.x) / Int(longPressGesture.view!.frame.width)
            for (index, element) in popUpView!.subviews.enumerated() {
                element.backgroundColor = index == btnIndex ? .darkGray : .clear
            }
        }
        if (longPressGesture.state == .ended && popUpView != nil) {
            guard let btn = longPressGesture.view as! UIButton? else { return }
            btn.backgroundColor = .white
            let proxy = self.textDocumentProxy
            for element in popUpView!.subviews {
                if(element.backgroundColor == .darkGray) {
                    proxy.insertText((element as! UIButton).title(for: .normal)!)
                }
            }
            popUpView?.removeFromSuperview()
        }
        if (longPressGesture.state == .began) {
            showOptions(longPressGesture)
        }
    }
    
    @objc func buttonUpAction(sender: UIButton!) {
        sender.backgroundColor = .white
        popUpView?.removeFromSuperview()
        let proxy = self.textDocumentProxy
        let title = sender.attributedTitle(for: .normal)!.string
        if title=="⏎" {
            proxy.insertText("\n")
            return
        }
        var key = title[title.startIndex].uppercased()
        switch key {
        case "←":
            timer?.invalidate()
            timer = nil
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
    }*/
    

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
