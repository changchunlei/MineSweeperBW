//
//  ActiveAlert.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//

enum ActiveAlert {
    case gameOver
    case gameWon
    var id: Int {
        hashValue
    }
}
