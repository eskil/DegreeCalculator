//
//  AppState.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/6/25.
//

import SwiftUI


@MainActor
final class AppState: ObservableObject {
    @Published public var dmsData: ObservableModelData
    @Published public var hmsData: ObservableModelData
    
    init() {
        self.dmsData = ObservableModelData(mode: .DMS)
        self.hmsData = ObservableModelData(mode: .HMS)
    }
}
