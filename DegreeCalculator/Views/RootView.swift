//  RootView.swifta
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct RootView: View {
    @StateObject var appState = AppState()
    @State private var currentMode: ModelData.ExprMode = .DMS

    // This is our toggle widget in the toolbar.
    var modeToggleButton: some View {
        Button(action: {
            let all = ModelData.ExprMode.allCases
            if let idx = all.firstIndex(of: currentMode) {
                let nextIdx = (idx + 1) % all.count
                currentMode = all[nextIdx]
            }
        }) {
            let all = ModelData.ExprMode.allCases
            let idx = all.firstIndex(of: currentMode) ?? 0

            HStack(spacing: 4) {
                Text(currentMode.label)
                    .font(.headline)
                Image(systemName: "arrow.2.squarepath")
                    .rotationEffect(.degrees(Double(idx) * 180))
                    .animation(.easeInOut(duration: 0.2), value: currentMode)
            }
            .foregroundColor(.blue)
        }
        .accessibilityLabel("Toggle Mode")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                /* This seems odd, but if I instead just do;
                 
                     CalculatorView()
                       .environmentObject(appState.models[currentMode]!)
                       .transition(.opacity.combined(with: .scale))
                 
                   the .transition(...) doesn't take effect. :shrug:
                 */
                switch currentMode {
                case .DMS:
                    CalculatorView()
                        .environmentObject(appState.models[ModelData.ExprMode.DMS]!)
                        .transition(.opacity.combined(with: .scale))
                case .HMS:
                    CalculatorView()
                        .environmentObject(appState.models[ModelData.ExprMode.HMS]!)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: currentMode)
            .toolbar {
                /*
                 I tried a picker as well
                 
                   Picker("Mode", selection: $currentMode) {
                      ForEach(ModelData.ExprMode.allCases, id: \.self) { mode in
                          Text(mode.label).tag(mode)
                      }
                   }
                   .pickerStyle(.segmented)
                 
                 but prefer the togglebuttons
                */
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Text("").hidden()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    modeToggleButton
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
