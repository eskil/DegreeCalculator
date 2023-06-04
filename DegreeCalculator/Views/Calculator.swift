//
//  Calculator.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/1/23.
//

import SwiftUI

struct Calculator: View {
    @EnvironmentObject var modelData: ModelData
    @State var padTop = 0.0
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView {
                    ScrollViewReader { value in
                        Text(modelData.entered)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(modelData.entries, id: \.self) { entry in
                            // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                            if let val = entry.nodes[0].value, let op = entry.op {
                                Text(val.description + " " + op.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if entry.nodes.count > 0 {
                                if let val = entry.nodes[1].value {
                                    Text(val.description + " " + "=")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.black)
                                        .padding(.trailing, 132)
                                        .padding(.leading, 0)
                                        .padding(.top, -14)
                                        .padding(.bottom, 0)
                                }
                            }
                            if let val = entry.value {
                                Text(val.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black)
                                    .padding(.trailing, 132)
                                    .padding(.leading, 0)
                                    .padding(.top, -14)
                                    .padding(.bottom, 0)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black)
                                    .padding(.trailing, 132)
                                    .padding(.leading, 0)
                                    .padding(.top, -18)
                                    .padding(.bottom, 0)
                            }
                        }
                        // https://stackoverflow.com/questions/58376681/swiftui-automatically-scroll-to-bottom-in-scrollview-bottom-first
                        .onChange(of: modelData.entries.count) { _ in
                            value.scrollTo(modelData.entries.count - 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.system(.largeTitle, design: .monospaced))
                    
                }
                //.frame(width: geo.size.width, height: geo.size.height/2)
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
                    CalculatorButton(label: "-", function: CalculatorFunction.SUBTRACT)
                }
                GridRow {
                    CalculatorButton(label: "1", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "2", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "3", function: CalculatorFunction.ENTRY)
                }
                GridRow {
                    CalculatorButton(label: "0", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: ".", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "°", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "=", function: CalculatorFunction.EQUAL)
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
                }
            }
            .padding([.bottom], 20)
            .background(Color.black)
        }
        .background(Color(UIColor.lightGray))

    }
}

struct Calculator_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 11 Pro", "iPhone 13 Pro", "iPhone 14 Pro", "iPhone SE (3rd generation)", "iPad (10th generation)"], id: \.self) { deviceName in
            Calculator()
                .environmentObject(ModelData())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
