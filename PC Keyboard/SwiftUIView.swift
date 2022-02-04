//
//  SwiftUIView.swift
//  PC Keyboard
//
//  Created by a on 19.09.2021.
//

import SwiftUI

let englishLayout = getEnglishLayout()
let ctrlRow = ["←", " ", "🌐", "⏎"].filter({ s in
    if UIDevice.current.userInterfaceIdiom == .phone && s == "🌐" {
        return false
    }
    return true
}).unflat();

class PopupInfo: ObservableObject {
    @Published var options: [String]?
    @Published var selectedOption: String?
}
let popup = PopupInfo.init()
var popupTimer: Timer?

struct KeyButton: View {
    let keyOptions: [String]
    let darkBackground = UIColor.init(white: 1, alpha: 0.3)
    var maxWidth: CGFloat = .infinity
    var isCtrlKey: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var didTap: Bool = false
    
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
            .background(Color(colorScheme == .dark ? (didTap ? .lightGray : darkBackground) : (didTap ? .lightGray : .white) ))
        .padding(2)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if popup.options != nil {
                        let popupOptions = popup.options!
                        let dx = (value.location.x - value.startLocation.x + 8) / 25;
                        var selIndex = Int(dx.rounded(.down)) % popupOptions.count
                        selIndex = (selIndex + popupOptions.count) % popupOptions.count
                        popup.selectedOption = popupOptions[selIndex]
                    }
                    if(didTap) {
                        return
                    }
                    didTap = true
                    NotificationCenter.default.post(name: Notification.Name("keyPreview"), object: nil, userInfo: ["key":keyOptions.first!])
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

    let optionBackground = UIColor.init(white: 0, alpha: 0.3)

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ForEach(0..<englishLayout.count) { row in
                    KeyRow(rowKeys: englishLayout[row]).frame(maxHeight: .infinity)
                }
                KeyRow(rowKeys: ctrlRow).frame(maxWidth: 444, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            if(previewKey != nil) {
                if(popup.options != nil) {
                    HStack(spacing:0) {
                        ForEach(popup.options!, id: \.self) {option in
                            Text(option)
                                .padding(6)
                                .foregroundColor(.white)
                                .font(Font.body.weight(option == popup.selectedOption ? .bold : .medium))
                                .background(Color(option == popup.selectedOption ? (colorScheme == .dark ? .black : .black ) : optionBackground))
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
