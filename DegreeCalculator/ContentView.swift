//
//  ContentView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct ContentView: View {
    @State var modelData = ModelData()
    // This is used as a copy of modelData.exprMode. That seems wrong.
    // I suspect a onChange could be used.
    @State private var exprMode: ModelData.ExprMode = .DMS
    
    private func switchMode() {
        modelData.exprMode = (modelData.exprMode == .DMS) ? .HMS : .DMS
        exprMode = modelData.exprMode
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Calculator().environmentObject(modelData)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        modelData.exprMode = (modelData.exprMode == .DMS) ? .HMS : .DMS
                        exprMode = modelData.exprMode
                    }) {
                        Text(exprMode == .DMS ? "DMS" : "HMS")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Image(systemName: "arrow.2.squarepath")
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
