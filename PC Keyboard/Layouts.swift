//
//  Layouts.swift
//  Okay Keyboard
//
//  Created by a on 01.08.2021.
//

import Foundation

struct KeyOption {
    let red, green, blue: Double
    init(red: Double, green: Double, blue: Double) {
        self.red   = red
        self.green = green
        self.blue  = blue
    }
    init(white: Double) {
        red   = white
        green = white
        blue  = white
    }
}

extension Array {
    func unflat() -> [[Element]] {
        return self.map{[$0]}
    }
}

let EnglishLayout = [
    [
        ["1", "!"],
        ["2", "@"],
        ["3", "#"],
        ["4", "$"],
        ["5", "%"],
        ["6", "^"],
        ["7", "&"],
        ["8", "*"],
        ["9", "(", "-", "_"],
        ["0", ")", "=", "+"],
        ["Q", "`", "~"]
    ],
    ["W", "E", "R", "T", "Y", "U", "I"].unflat(),
    [
        ["O", "[", "{"],
        ["P", "]", "}"],
    ],
    ["A", "S", "D", "F", "G", "H", "J"].unflat(),
    [
        ["K", ";", ":"],
        ["L", "'", "\""],
        ["\\", "|"],
    ],
    ["Z", "X", "C", "V", "B", "N", "M"].unflat(),
    [
        [",", "<"],
        [".", ">"],
        ["/", "?"],
    ]
    
].flatMap({ $0 })
