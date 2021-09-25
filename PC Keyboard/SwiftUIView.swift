//
//  SwiftUIView.swift
//  PC Keyboard
//
//  Created by a on 19.09.2021.
//

import SwiftUI

let englishLayout = getEnglishLayout()
let ctrlRow = ["←", " ", "⏎"].unflat();

struct KeyButton: View {
    let keyOptions: [String]
    var maxWidth: CGFloat = .infinity
    
    @State private var didTap:Bool = false
    
    var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Text(keyOptions.first!)
                    .frame(maxWidth: maxWidth, maxHeight: .infinity)
                    .offset(x: -4, y: -4)
                if(keyOptions.count>1) {
                    Text(keyOptions.joined(separator: " ").dropFirst()).font(.system(size: 12))
                        .offset(x: -2, y: -2)
                }
            }
        .background(Color(didTap ? .lightGray : .white))
        .padding(2)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    didTap = true
                    NotificationCenter.default.post(name: Notification.Name("keyPreview"), object: nil, userInfo: ["key":keyOptions.first!])
//                    print("onChanged", value)
                }
                .onEnded { value in
                    didTap = false
                    NotificationCenter.default.post(name: Notification.Name("keyPreview"), object: nil, userInfo: [:])
                    NotificationCenter.default.post(name: Notification.Name("keyPress"), object: nil, userInfo: ["key":keyOptions.first!])
//                    print("onEnded", value)
                }
        )
    }
}

struct KeyRow: View {
    let rowKeys: [[String]]
    
    @State
    private var height: CGFloat = .zero // < calculable height
    
    var body: some View {
            HStack(spacing: 0) {
                ForEach(rowKeys, id: \.self) {rowKey in
                    KeyButton (keyOptions: rowKey, maxWidth: rowKey.first == " " ? .infinity : 66)
                }
            }
    }
}

struct SwiftUIView: View {
    
    @State private var previewKey: String?

    let pub = NotificationCenter.default
            .publisher(for: NSNotification.Name("keyPreview"))
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ForEach(0..<englishLayout.count) { row in
                    KeyRow(rowKeys: englishLayout[row]).frame(maxHeight: .infinity)
                }
                KeyRow(rowKeys: ctrlRow).frame(maxHeight: .infinity)
            }
            .background(Color.init(red: 212.0/255, green: 214.0/255, blue: 221.0/255))
            if(previewKey != nil) {
                Text(previewKey!).foregroundColor(.white).padding(6).offset(y: -3).background(Color(.darkGray))
            }
        }
        .onReceive(pub) { (output) in
//            print(output)
            previewKey = output.userInfo!["key"] as! String?
        }
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
  
    
    @objc func buttonDownAction(btn: UIButton!) {
        btn.backgroundColor = .lightGray
        if(btn.tag == 2) {
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
    }*/
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
