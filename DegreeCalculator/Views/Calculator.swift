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
    
    struct Line: Hashable {
        var id = 0
        var value: String
        var op: String?
    }
    
    var lines: [Line] {
        var result: [Line] = []
        modelData.entries.forEach { entry in
            var line: Line = Line(value: "")
            var tmp: [Line] = []

            // In order traverse the tree and add the left side value to "line", then the op
            // and emit that line.
            entry.inOrder { expr in
                if let v = expr.v {
                    line.value = v.description
                }
                if let op = expr.op {
                    line.op = op.description
                    tmp.append(Line(value: line.value, op: line.op))
                    line = Line(value: "")
                }
            }
            // Finally, if there's a result on the entry, add that since the expression is "proper and done". Otherwise just add the line being worked on.
            // I'm not feeling this, I feel like maybe the "line" should start with the entered string.
            if let result = entry.value {
                tmp.append(Line(value: line.value, op: "="))
                tmp.append(Line(value: result.description, op: "=="))
            } else {
                // tmp.append(Line(value: line.value))
            }

            result = result + tmp
        }
        result = result + [Line(value: modelData.entered, op: nil)]
        for index in result.indices {
            result[index].id = index
        }
        return result
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView {
                    ScrollViewReader { scroll_reader in
                        ForEach(lines, id: \.id) { line in
                            // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                            if let op = line.op {
                                if op == "=" {
                                    Text(line.value + " " + op)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.black)
                                        .padding(.trailing, 132)
                                        .padding(.leading, 0)
                                        .padding(.top, -14)
                                        .padding(.bottom, 0)
                                } else if op == "==" {
                                    Text(line.value + " ")
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
                                        .padding(.top, -14)
                                        .padding(.bottom, 0)
                                } else {
                                    Text(line.value + " " + op)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                Text(line.value)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        /*
                        // https://stackoverflow.com/questions/58376681/swiftui-automatically-scroll-to-bottom-in-scrollview-bottom-first
                        .onChange(of: lines.count) { _ in
                            scroll_reader.scrollTo(lines.count, anchor: .bottom)
                        }
                         */
                    }
                }
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
                    CalculatorButton(label: "°", function: CalculatorFunction.ENTRY)
                    CalculatorButton(label: "'", function: CalculatorFunction.ENTRY)
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
