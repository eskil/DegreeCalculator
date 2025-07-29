//
//  AppState.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/6/25.
//

import SwiftUI

// The RootView instantiates the appstate.
@MainActor
final class AppState: ObservableObject {
    // We create an map of mode to observable model for each
    // expression mode. This generalises supporting multiple modes
    // even if we only do HMS and DMS right now.
    @Published var models: [ModelData.ExprMode: ObservableModelData] = [:]
    
    init() {
        for mode in ModelData.ExprMode.allCases {
            models[mode] = ObservableModelData(mode: mode)
        }
    }
}
