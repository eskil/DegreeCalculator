//
//  ContentView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var modelData = ModelData()

    var body: some View {
        NavigationView {
            VStack {
                Calculator().environmentObject(modelData)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Intentionally empty for now.
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        modelData.exprMode = (modelData.exprMode == .DMS) ? .HMS : .DMS
                    }) {
                        HStack(spacing: 4) {
                            Text(modelData.exprMode == .DMS ? "DMS" : "HMS")
                                .font(.headline)
                            Image(systemName: "arrow.2.squarepath")
                        }
                        .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Toggle Mode")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
