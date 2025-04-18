//
//  ContentView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

/* Controls whether we're doing degrees-minutes-seconds math or hours-minutes-seconds
 */
enum CalculatorMode {
    case DMS
    case HMS
}

struct ContentView: View {
    @State var modelData = ModelData()
    @State private var mode: CalculatorMode = .DMS

    var body: some View {
        NavigationView {
            VStack {
                Calculator(mode: mode).environmentObject(modelData)
            }
            .navigationTitle("Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mode = (mode == .DMS) ? .HMS : .DMS
                    }) {
                        Image(systemName: "arrow.2.squarepath")
                            .accessibilityLabel("Toggle Mode")
                    }
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
