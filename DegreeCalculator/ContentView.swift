//
//  ContentView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView {
                    ScrollViewReader { value in
                        ForEach(modelData.entries, id: \.self) { entry in
                            // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                            Text(entry)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            /*
                             Text("––––––––––––")
                             .frame(maxWidth: .infinity, alignment: .leading)
                             Text("‗‗‗‗‗‗‗‗‗‗‗‗‗")
                             .frame(maxWidth: .infinity, alignment: .leading)
                             */
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
                    Button { } label: { Text("AC")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.red))
                    Button { } label: { Text("C")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button { } label: { Text("DEL")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.orange))
                    Button { } label: { Text("+/-")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.brown))
               }
                GridRow {
                    Button { } label: { Text("7")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("8")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("9")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("ANS")}
                         .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.brown))
               }
                GridRow {
                    Button { } label: { Text("4")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("5")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("6")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("+")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.yellow))

                }
                GridRow {
                    Button { } label: { Text("1")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("2")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("3")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text("-")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.yellow))
                }
                GridRow {
                    Button { } label: { Text("0")}
                        .buttonStyle(CalculatorButtonStyle())
                    Button { } label: { Text(".")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.gray))
                    Button { } label: { Text("°")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.gray))
                    Button { } label: { Text("=")}
                        .buttonStyle(CalculatorButtonStyle(backgroundColor: Color.green))
                }
                
            }
            .padding([.bottom], 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
