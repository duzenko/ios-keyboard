//
//  SwiftUIView.swift
//  PC Keyboard
//
//  Created by a on 19.09.2021.
//

import SwiftUI

let englishLayout = getEnglishLayout()
let ctrlRow = ["←", " ", "⏎"].unflat();

class PopupInfo: ObservableObject {
    @Published var options: [String]?
    @Published var selectedOption: String?
}
let popup = PopupInfo.init()
var popupTimer: Timer?

struct KeyButton: View {
    let keyOptions: [String]
    var maxWidth: CGFloat = .infinity
    var isCtrlKey: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
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
            .background(Color(colorScheme == .dark ? (didTap ? .darkGray : .black) : (didTap ? .lightGray : .white) ))
        .padding(2)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if popup.options != nil {
                        let dx = (value.location.x - value.startLocation.x + 8) / 16;
                        var selIndex = Int(dx.rounded(.down)) % keyOptions.count
//                        print( dx, selIndex, (selIndex + keyOptions.count) % keyOptions.count )
                        selIndex = (selIndex + keyOptions.count) % keyOptions.count
                        popup.selectedOption = keyOptions[selIndex]
                    }
                    if(didTap) {
                        return
                    }
                    didTap = true
                    NotificationCenter.default.post(name: Notification.Name("keyPreview"), object: nil, userInfo: ["key":keyOptions.first!])
//                    print("onChanged", value)
                    if !isCtrlKey {
                        popupTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { (_) in
                            let first = keyOptions.first!
                            popup.options = keyOptions
                            if first != first.lowercased() {
                                popup.options?.insert(first.lowercased(), at: 1)
                            }
                            popup.selectedOption = keyOptions[0]
                        })
                    }
                }
                .onEnded { value in
                    NotificationCenter.default.post(name: Notification.Name("keyPreview"), object: nil, userInfo: [:])
                    let keyPressInfo: [String: Any] = [
                        "key": popup.selectedOption ?? keyOptions.first!,
                        "autoCase": popup.selectedOption == nil,
                    ]
                    NotificationCenter.default.post(name: Notification.Name("keyPress"), object: nil, userInfo: keyPressInfo)
                    didTap = false
                    popup.options = nil
                    popup.selectedOption = nil
                    popupTimer?.invalidate()
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
                    KeyButton (keyOptions: rowKey, maxWidth: rowKey.first == " " ? .infinity : 66, isCtrlKey: rowKeys.count < 3)
                }
            }
    }
}

struct SwiftUIView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var previewKey: String?
    @ObservedObject var viewModel : PopupInfo = popup
    
    let pubPreview = NotificationCenter.default
            .publisher(for: NSNotification.Name("keyPreview"))

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ForEach(0..<englishLayout.count) { row in
                    KeyRow(rowKeys: englishLayout[row]).frame(maxHeight: .infinity)
                }
                KeyRow(rowKeys: ctrlRow).frame(maxHeight: .infinity)
            }
            .background(colorScheme == .dark ? Color(.darkGray) : Color.init(red: 212.0/255, green: 214.0/255, blue: 221.0/255))
            if(previewKey != nil) {
                if(popup.options != nil) {
                    HStack(spacing:0) {
                        ForEach(popup.options!, id: \.self) {option in
                            Text(option)
                                .padding(6)
                                .foregroundColor(.white)
                                .font(Font.body.weight(option == popup.selectedOption ? .bold : .medium))
                                .background(Color(option == popup.selectedOption ? (colorScheme == .dark ? .gray : .black ) : .darkGray))
                        }
                    }.offset(y: -5)
                } else {
                    HStack {
                        Text(previewKey!).foregroundColor(.white).padding(6).background(Color(.darkGray))
                    }.offset(y: -5)
                }
            }
        }
        .onReceive(pubPreview) { (output) in
            let key = output.userInfo!["key"] as! String?
            if key == " " {
                return
            }
            previewKey = key
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
