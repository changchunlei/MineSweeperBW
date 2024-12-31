//
//  ContentView.swift
//  msgame
//
//  Created by chunlei on 30/12/2024.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedLevel: String? = nil
    
    var body: some View {
        if selectedLevel != nil {
            GameBoardView(selectedLevel: $selectedLevel)
        } else {
            LevelSelectionView(selectedLevel: $selectedLevel)
        }
    }
}

struct LevelSelectionView: View {
    let levels = ["Easy", "Normal", "Hard", "Master"]
    @Binding var selectedLevel: String?
    
    var body: some View {
        NavigationView {
            List(levels, id: \.self) { level in
                Button(action: {
                    selectedLevel = level
                }) {
                    Text(level)
                }
            }
            .navigationTitle("Select Level")
        }
    }
}


#Preview {
    ContentView()
}
