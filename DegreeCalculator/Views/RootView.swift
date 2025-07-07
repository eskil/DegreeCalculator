//
//  RootView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct RootView: View {
    @StateObject var state = AppState()

    var body: some View {
        NavigationView {
            VStack {
                CalculatorView()
                    .environmentObject(state.dmsData)
                    .environmentObject(state.hmsData)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Intentionally empty for now.
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        state.mode = (state.mode == .DMS) ? .HMS : .DMS
                    }) {
                        HStack(spacing: 4) {
                            Text(state.mode == .DMS ? "DMS" : "HMS")
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
