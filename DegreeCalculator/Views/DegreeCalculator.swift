//
//  DegreeCalculator.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/1/23.
//

import SwiftUI

struct DegreeCalculator: View {
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
                            if let val = entry.left, let op = entry.op {
                                Text(val.description + " " + op.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let val = entry.right {
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
                    Button(action: { modelData.clearAll() }) { Text("AC") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.red))
                    Button(action: { modelData.clear() }) { Text("C")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button(action: { modelData.delete() }) { Text("DEL")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button(action: { modelData.ans() }) { Text("ANS")}
                         .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.brown))
               }
                GridRow {
                    Button(action: { modelData.add("7") }) { Text("7") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("8") }) { Text("8") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("9") }) { Text("9") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("+") }) { Text("+") }
                        .buttonStyle(CalculatorButtonStyle(foregroundColor: Color.black, backgroundColor: Color.yellow))
               }
                GridRow {
                    Button(action: { modelData.add("4") }) { Text("4") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("5") }) { Text("5") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("6") }) { Text("6") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("-") }) { Text("-") }
                        .buttonStyle(CalculatorButtonStyle(foregroundColor: Color.black, backgroundColor: Color.yellow))
                }
                GridRow {
                    Button(action: { modelData.add("1") }) { Text("1") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("2") }) { Text("2") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("3") }) { Text("3") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("-") }) { Text("-") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.white))
                }
                GridRow {
                    Button(action: { modelData.add("0") }) { Text("0") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add(".") }) { Text(".") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.gray))
                    Button(action: { modelData.add("°") }) { Text("°") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.gray))
                    Button(action: { modelData.add("=") }) { Text("=") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.green))
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

struct DegreeCalculator_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 11 Pro", "iPhone 13 Pro", "iPhone 14 Pro", "iPhone SE (3rd generation)", "iPad (10th generation)"], id: \.self) { deviceName in
            DegreeCalculator()
                .environmentObject(ModelData())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
