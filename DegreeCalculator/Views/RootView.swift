//
//  RootView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct RootView: View {
    @StateObject var appState = AppState()

    var body: some View {
        NavigationView {
            VStack {
                CalculatorView()
                    .environmentObject(appState.dmsData)
                    .environmentObject(appState.hmsData)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Intentionally empty for now.
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        appState.displayMode = (appState.displayMode == .DMS) ? .HMS : .DMS
                    }) {
                        HStack(spacing: 4) {
                            Text(appState.displayMode == .DMS ? "DMS" : "HMS")
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
