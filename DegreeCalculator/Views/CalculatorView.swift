//
//  Calculator.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/1/23.
//

import SwiftUI


struct CalculatorView: View {
    @EnvironmentObject var modelData: ModelData
    @State var padTop = 0.0
    @State var padRight = 0.0

    var lines: [DisplayLine] {
        NSLog("Expressions changed, recomputing lines")
        let result = modelData.displayLines()
        NSLog("computed lines modelData intOnly is \(modelData.intOnly)")
        NSLog("computed lines")
        for line in result {
            NSLog("\tline \(line)")
        }
        return result
    }
    
    var Underscore: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white)
            .padding(.trailing, 48)
            .padding(.leading, 48)
            .padding(.top, -14)
            .padding(.bottom, 0)
    }
    
    private func hmsBody() -> some View {
        VStack {
            GeometryReader { geo in
                DisplayLinesView(model: modelData)
                //.frame(width: geo.size.width, height: geo.size.height/2)
                .font(.system(.largeTitle, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20.0)
            }
            
            Divider()
            
            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    CalculatorButton(label: "AC", function: CalculatorFunction.ALL_CLEAR)
                    CalculatorButton(label: "C", function: CalculatorFunction.CLEAR)
                    CalculatorButton(label: "DEL", function: CalculatorFunction.DELETE)
                    CalculatorButton(label: "ANS", function: CalculatorFunction.ANS)
                        .disabled(modelData.intOnly)
                }
                GridRow {
                    CalculatorButton(label: "7", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "8", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "9", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "+", function: CalculatorFunction.ADD)
                }
                GridRow {
                    CalculatorButton(label: "4", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "5", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "6", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "-",
                                     function: CalculatorFunction.SUBTRACT,
                                     tripleTapFunction: CalculatorFunction.M360)
                }
                GridRow {
                    CalculatorButton(label: "1", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "2", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "3", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "/", function: CalculatorFunction.DIV)
                }
                GridRow {
                    CalculatorButton(label: "0", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "h", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.intOnly)
                    CalculatorButton(label: "m", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.intOnly)
                    CalculatorButton(label: "=", function: CalculatorFunction.EQUAL)
#if false // double up size of button, but since we added /, we don't do that.
                        .background(
                            GeometryReader { geo in
                                /* See https://stackoverflow.com/a/68291983/21866895
                                 for how the Geometry reader here is done.
                                 It reads the Button's height and then padds by that (negative) to move up.
                                 The extra -1.0 seems to be needed.
                                 */
                                Color.clear.onAppear {
                                    if padTop == .zero {
                                        padTop = -geo.size.height-1.0
                                    }
                                }
                            }
                        )
                        .padding(.top, padTop)
#endif
                }
            }
            .padding([.bottom], 20)
            .background(Color.black)
        }
        .background(.black) //Color(UIColor.lightGray))
    }
  
    private func dmsBody() -> some View {
        VStack {
            GeometryReader { geo in
                DisplayLinesView(model: modelData)
                //.frame(width: geo.size.width, height: geo.size.height/2)
                .font(.system(.largeTitle, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20.0)
            }

            Divider()
            
            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    CalculatorButton(label: "AC", function: CalculatorFunction.ALL_CLEAR)
                    CalculatorButton(label: "C", function: CalculatorFunction.CLEAR)
                    CalculatorButton(label: "DEL", function: CalculatorFunction.DELETE)
                    CalculatorButton(label: "ANS", function: CalculatorFunction.ANS)
                        .disabled(modelData.intOnly)
                }
                GridRow {
                    CalculatorButton(label: "7", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "8", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "9", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "+", function: CalculatorFunction.ADD)
                }
                GridRow {
                    CalculatorButton(label: "4", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "5", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "6", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "-",
                                     function: CalculatorFunction.SUBTRACT,
                                     tripleTapFunction: CalculatorFunction.M360)
                }
                GridRow {
                    CalculatorButton(label: "1", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "2", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "3", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "/", function: CalculatorFunction.DIV)
                }
                GridRow {
                    CalculatorButton(label: "0", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "°", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.intOnly)
                    CalculatorButton(label: "'", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.intOnly)
                    CalculatorButton(label: "=", function: CalculatorFunction.EQUAL)
#if false // double up size of button
                        .background(
                            GeometryReader { geo in
                                /* See https://stackoverflow.com/a/68291983/21866895
                                 for how the Geometry reader here is done.
                                 It reads the Button's height and then padds by that (negative) to move up.
                                 The extra -1.0 seems to be needed.
                                 */
                                Color.clear.onAppear {
                                    padTop = -geo.size.height-1.0
                                }
                            }
                        )
                        .padding(.top, padTop)
#endif
                }
            }
            .padding([.bottom], 20)
            .background(Color.black)
        }
        .background(.black) //Color(UIColor.lightGray))
    }
    
    var body: some View {
        switch modelData.exprMode {
        case .DMS:
            return AnyView(dmsBody())
        case .HMS:
            return AnyView(hmsBody())
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static func previewFor(deviceName: String, mode: ModelData.ExprMode) -> some View {
        let model = ModelData(mode: mode)
                
        return CalculatorView()
            .environmentObject(model)
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName + " - \(mode)")
    }
    
    static var previews: some View {
        Group {
            ForEach(["iPhone 16 Pro", "iPhone 11 Pro", "iPhone 13 Pro", "iPhone 14 Pro", "iPhone SE (3rd generation)", "iPad (10th generation)"], id: \.self) { deviceName in
                previewFor(deviceName: deviceName, mode: .DMS)
                previewFor(deviceName: deviceName, mode: .HMS)
            }
        }
    }
}
