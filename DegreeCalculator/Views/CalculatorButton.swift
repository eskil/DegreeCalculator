//
//  CalculatorButton.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/2/23.
//

import SwiftUI

struct CalculatorButton: View {
    @EnvironmentObject var modelData: ModelData
    var label: String
    var function: CalculatorFunction = CalculatorFunction.ENTRY

    var fg: Color {
        switch function {
        case .ADD, .SUBTRACT:
            return Color.black
        default:
            return Color.white
        }
    }
    var bg: Color {
        switch function {
        case .ALL_CLEAR:
            return Color.red
        case .CLEAR, .DELETE:
            return Color.orange
        case .ANS:
            return Color.brown
        case .EQUAL:
            return Color.green
        case .ADD, .SUBTRACT:
            return Color.yellow
        default:
            return Color.gray
        }
    }
    var body: some View {
        Button(action: {
            modelData.callFunction(function, label: label)
        }) {
            Text(label)
        }
        .buttonStyle(CalculatorButtonStyle(foregroundColor: fg, backgroundColor: bg))
    }
}

struct CalculatorButton_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 11 Pro", "iPhone 13 Pro", "iPhone 14 Pro", "iPhone SE (3rd generation)", "iPad (10th generation)"], id: \.self) { deviceName in
            CalculatorButton(label: "Y")
                .environmentObject(ModelData())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
