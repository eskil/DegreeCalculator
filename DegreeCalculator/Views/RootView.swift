//
//  RootView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct RootView: View {
    @StateObject var appState = AppState()
    @State private var showingFirst = true
    @Namespace private var animationNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showingFirst {
                    CalculatorView()
                        .environmentObject(appState.dmsData)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    CalculatorView()
                        .environmentObject(appState.hmsData)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showingFirst)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Intentionally empty for now.
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFirst.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(showingFirst ? "DMS" : "HMS")
                                .font(.headline)
                            Image(systemName: "arrow.2.squarepath")
                                .rotationEffect(.degrees(showingFirst ? 0 : 180))
                                .animation(.easeInOut(duration: 0.2), value: showingFirst)
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
