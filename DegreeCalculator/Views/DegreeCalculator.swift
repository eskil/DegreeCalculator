//
//  DegreeCalculator.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/1/23.
//

import SwiftUI

struct DegreeCalculator: View {
    @EnvironmentObject var modelData: ModelData

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
                    Button(action: { modelData.send(self) }) { Text("AC") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.red))
                    Button { } label: { Text("C")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button { } label: { Text("DEL")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button { } label: { Text("+/-")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.brown))
               }
                GridRow {
                    Button(action: { modelData.add("7") }) { Text("7") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("8") }) { Text("8") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("9") }) { Text("9") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("ANS")}
                         .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.brown))
               }
                GridRow {
                    Button(action: { modelData.add("4") }) { Text("4") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("5") }) { Text("5") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("6") }) { Text("6") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("+") }) { Text("+") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.yellow))
                }
                GridRow {
                    Button(action: { modelData.add("1") }) { Text("1") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("2") }) { Text("2") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("3") }) { Text("3") }
                        .buttonStyle(CalculatorButtonStyle())
                    Button(action: { modelData.add("-") }) { Text("-") }
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.yellow))
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
                }
                
            }
            .padding([.bottom], 20)
        }
    }
}

struct DegreeCalculator_Previews: PreviewProvider {
    static var previews: some View {
        DegreeCalculator()
            .environmentObject(ModelData())
    }
}
