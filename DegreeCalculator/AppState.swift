//
//  AppState.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/6/25.
//

import SwiftUI


final class AppState: ObservableObject {
    @Published public var dmsData = ModelData(mode: .DMS)
    @Published public var hmsData = ModelData(mode: .HMS)
    @Published public var mode: ModelData.ExprMode = .DMS

}
