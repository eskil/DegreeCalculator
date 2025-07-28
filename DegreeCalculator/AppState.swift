//
//  AppState.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/6/25.
//

import SwiftUI


final class AppState: ObservableObject {
    @Published public var dmsData = ObservableModelData(mode: .DMS)
    @Published public var hmsData = ObservableModelData(mode: .HMS)
}
