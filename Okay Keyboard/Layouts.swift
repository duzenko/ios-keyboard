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
    func unflattening(dim: Int = 1) -> [[Element]] {
        let hasRemainder = !count.isMultiple(of: dim)
        
        var result = [[Element]]()
        let size = count / dim
        result.reserveCapacity(size + (hasRemainder ? 1 : 0))
        for i in 0..<size {
            result.append(Array(self[i*dim..<(i + 1) * dim]))
        }
        if hasRemainder {
            result.append(Array(self[(size * dim)...]))
        }
        return result
    }
}


let EnglishLayout = [
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
] + ["W", "E", "R", "T", "Y", "U", "I"].unflattening() + [
    ["O", "[", "{"],
    ["P", "]", "}"],
] + ["A", "S", "D", "F", "G", "H", "J"].unflattening() + [
    ["K", ";", ":"],
    ["L", "'", "\""],
    ["\\", "|"],
] + ["Z", "X", "C", "V", "B", "N", "M"].unflattening() + [
    [",", "<"],
    [".", ">"],
    ["/", "?"],
]
