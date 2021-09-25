//
//  Layouts.swift
//  Okay Keyboard
//
//  Created by a on 01.08.2021.
//

import Foundation

extension Array {
    func unflat() -> [[Element]] {
        return self.map{[$0]}
    }
}

func getEnglishLayout() -> [[[String]]] {
    let qwerty = ["Q", "W", "E", "R", "T", "Y", "U", "I"].unflat()
    let asdfghj = ["A", "S", "D", "F", "G", "H", "J"].unflat()
    let zxcvbnm = ["Z", "X", "C", "V", "B", "N", "M"].unflat()
    return [
        [
            ["1", "!", "`", "~"],
            ["2", "@"],
            ["3", "#"],
            ["4", "$"],
            ["5", "%"],
            ["6", "^"],
            ["7", "&"],
            ["8", "*"],
            ["9", "(", "-", "_"],
            ["0", ")", "=", "+"],
        ],
        qwerty + [
            ["O", "[", "{"],
            ["P", "]", "}"]
        ],
        asdfghj + [
            ["K", ";", ":"],
            ["L", "'", "\""],
            ["\\", "|"],
        ],
        zxcvbnm + [
            [",", "<"],
            [".", ">"],
            ["/", "?"],
        ]
    ]
}
