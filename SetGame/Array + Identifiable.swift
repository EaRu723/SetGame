//
//  Array + Identifiable.swift
//  SetGame
//
//  Created by Andrea Russo on 11/19/23.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
