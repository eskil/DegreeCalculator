//
//  CalculatorButtonStyle.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import Foundation
import SwiftUI

struct CalculatorButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color.gray
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
            .cornerRadius(4)
            .padding(4.0)
    }
}
