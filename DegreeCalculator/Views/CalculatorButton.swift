//
//  CalculatorButton.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/2/23.
//

import SwiftUI


// AI prompt, "Write a swiftui function to mute a variable of type Color"
extension Color {
    func withMutedAdjustment(_ factor: Double) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        let color = UIColor(self)
        // Get the HSB components of the color
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            // Handle grays (low saturation)
            if saturation < 0.05 {
                let newBrightness = max(0.0, min(brightness * CGFloat(factor), 1.0))
                return Color(UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
            } else {
                // For non-grays, adjust saturation
                let newSaturation = max(0.0, min(saturation * CGFloat(factor), 1.0))
                return Color(UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha))
            }
        }

        return self
    }
}


struct CalculatorButton: View {
    @EnvironmentObject var modelData: ObservableModelData
    @Environment(\.isEnabled) var isEnabled

    var label: String
    var function: CalculatorFunction = CalculatorFunction.ENTRY
    var tripleTapFunction: CalculatorFunction?
    @State private var isProcessing = false
    @State private var showError = false
    
    // This functions returns the default color of a button by it's function,
    // then `foregroundColor` mutes it if it's disbled.
    var enabledForegroundColor: Color {
        switch function {
        case .ADD, .SUBTRACT, .DIV, .M360:
            return Color.black
        default:
            return Color.white
        }
    }
    
    var foregroundColor: Color {
        if (!isEnabled) {
            return enabledForegroundColor.withMutedAdjustment(0.4)
        }
        return enabledForegroundColor
    }
    
    // This functions returns the default color of a button by it's function,
    // then `backgroundColor` mutes it if it's disbled.
    var enabledBackgroundColor: Color {
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
    
    var backgroundColor: Color {
        if !isEnabled {
            return enabledBackgroundColor.withMutedAdjustment(0.4)
        }
        if showError {
            return Color.red
        }
        return enabledBackgroundColor
    }
    
    private func flashRed() {
        showError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showError = false
        }
    }
    
    // buttonContent is the button base view, `body` then optionally
    // attaches a ontap modifier.
    private func buttonContent() -> some View {
        Button(
            action: {
                let _ = ExecutionTimer("thread: \(Thread.current): button \(function) label: \(label)")

                isProcessing = true
                Task {
                    do {
                        try modelData.callFunction(function, label: label)
                    } catch ModelData.InputError.tooLong {
                        flashRed()
                    }
                    isProcessing = false
                }
            }
        ) {
            Text(label)
                .font(.system(.largeTitle, design: .monospaced))
        }
        .buttonStyle(CalculatorButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor))
        .disabled(isProcessing)
        .opacity(isProcessing ? 0.3 : 1.0)
        .accessibilityIdentifier("button_\(label)")
    }
    
    var body: some View {
        let content = buttonContent()
        if let fn = tripleTapFunction {
            content.onTapGesture(count: 3) {
                let _ = ExecutionTimer("thread: \(Thread.current): 3tap button \(fn) label: \(label)")
                
                isProcessing = true
                Task {
                    do {
                        try modelData.callFunction(fn, label: label)
                    } catch ModelData.InputError.tooLong {
                        flashRed()
                    }
                    isProcessing = false                }
            }
        } else {
            content
        }
    }
}

struct CalculatorButton_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 11 Pro", "iPhone 13 Pro", "iPhone 14 Pro", "iPhone SE (3rd generation)", "iPad (10th generation)"], id: \.self) { deviceName in
            VStack(spacing: 1) {
                Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        CalculatorButton(label: "C", function: .CLEAR)
                        CalculatorButton(label: "+", function: .ADD)
                        CalculatorButton(label: "0")
                    }
                }
                .frame(height: 80)
            }
            .padding()
            .background(Color.black)
            .environmentObject(ObservableModelData(mode: .DMS))
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
}
