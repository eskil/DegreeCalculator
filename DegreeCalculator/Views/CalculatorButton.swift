//
//  CalculatorButton.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/2/23.
//

import SwiftUI

// AI prompt, "Write a swiftui function to mute a variable of type Color"
extension UIColor {
    func withMutedAdjustment(_ factor: Double) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Get the HSB components of the color
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            // Handle grays (low saturation)
            if saturation < 0.05 {
                let newBrightness = max(0.0, min(brightness * CGFloat(factor), 1.0))
                return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
            } else {
                // For non-grays, adjust saturation
                let newSaturation = max(0.0, min(saturation * CGFloat(factor), 1.0))
                return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
            }
        }
        
        return self // Return self if hue extraction fails
    }
}


struct CalculatorButton: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.isEnabled) var isEnabled

    var label: String
    var function: CalculatorFunction = CalculatorFunction.ENTRY
    var tripleTapFunction: CalculatorFunction?

    // This functions returns the default color of a button by it's function,
    // then `fg` mutes it if it's disbled.
    var enabled_fg: Color {
        switch function {
        case .ADD, .SUBTRACT, .DIV, .M360:
            return Color.black
        default:
            return Color.white
        }
    }
    
    var fg: Color {
        let result: Color = enabled_fg
        if (!isEnabled) {
            return Color(UIColor(result).withMutedAdjustment(0.4))
        }
        return result
    }
    
    // This functions returns the default color of a button by it's function,
    // then `bg` mutes it if it's disbled.
    var enabled_bg: Color {
        switch function {
        case .ALL_CLEAR:
            return Color.red
        case .CLEAR, .DELETE:
            return Color.orange
        case .ANS:
            return Color.brown
        case .EQUAL:
            return Color.green
        case .ADD, .SUBTRACT, .DIV, .M360:
            return Color.yellow
        default:
            return Color.gray
        }
    }
    
    var bg: Color {
        let result: Color = enabled_bg
        if (!isEnabled) {
            return Color(UIColor(result).withMutedAdjustment(0.4))
        }

        return result
    }
    var body: some View {
        Button(action: {
            modelData.callFunction(function, label: label)
        }) {
            Text(label)
                .font(.system(.largeTitle, design: .monospaced))
        }
        .buttonStyle(CalculatorButtonStyle(foregroundColor: fg, backgroundColor: bg))
        .onTapGesture(count: 3) {
            if let fn = tripleTapFunction {
                modelData.callFunction(fn, label: label)
            }
        }
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
