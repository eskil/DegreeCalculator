//
//  CalculatorButtonStyle.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import Foundation
import SwiftUI

struct CalculatorButtonStyle: ButtonStyle {
    var foregroundColor: Color = Color.white
    var backgroundColor: Color = Color.gray
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .cornerRadius(3)
            .padding(1.0)
    }
}
