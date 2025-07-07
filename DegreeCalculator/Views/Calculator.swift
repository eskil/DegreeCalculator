//
//  Calculator.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 6/1/23.
//

import SwiftUI

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self
        }
    }
}

struct Calculator: View {
    @EnvironmentObject var modelData: ModelData
    @State var padTop = 0.0
    @State var padRight = 0.0

    struct Line: Hashable {
        var id = 0
        var value: String
        var op: String?
    }
    
    var lines: [Line] {
        NSLog("Expressions changed, recomputing lines")
        var result: [Line] = []
        modelData.expressions.forEach { entry in
            var line: Line = Line(value: "")
            var tmp: [Line] = []

            // In order traverse the tree and add the left side value to "line", then the op
            // and emit that line.
            entry.inOrder { expr in
                switch expr {
                case .value(let v):
                    line.value = v.description.leftPadding(toLength: 11, withPad: " ")
                case .binary(let op, _, _):
                    line.op = op.description
                    tmp.append(Line(value: line.value, op: line.op))
                    line = Line(value: "")
                }
            }
            // Finally, if there's a result on the entry, add that since the expression is "proper and done". Otherwise just add the line being worked on.
            // I'm not feeling this, I feel like maybe the "line" should start with the entered string.
            if let result = entry.value {
                tmp.append(Line(value: line.value, op: "="))
                tmp.append(Line(value: result.description.leftPadding(toLength: 11, withPad: " "), op: "=="))
            }

            result = result + tmp
        }
        result = result + [Line(value: modelData.inputStack, op: nil)]
        for index in result.indices {
            result[index].id = index
        }
        NSLog("computed lines \(result)")
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
                ScrollView {
                    ScrollViewReader { scroll_reader in
                        ForEach(lines, id: \.id) { line in
                            // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                            VStack {
                                if let op = line.op {
                                    if op == "=" {
                                        // FIXME: this view could be generalised
                                        Text(line.value + " " + op)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        Underscore
                                    } else if op == "==" {
                                        Text(line.value + " ")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        Underscore
                                        Underscore
                                    } else {
                                        Text(line.value + " " + op)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        
                                    }
                                } else {
                                    Text(line.value)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.yellow)
                                }
                            }
                            .id(line.id)
                        }
                        
                        // https://stackoverflow.com/questions/58376681/swiftui-automatically-scroll-to-bottom-in-scrollview-bottom-first
                        // FIXME: this causes "lines" to be calculated multiple times which is a waste. And doing a single "let lines = lines" earlier doesn't work, since .onChange likely has some wrapper to cache values and thus accesses it... blabla. In short, doing the onChange on lines is needed for some corner case where ANS needs to scoll (ie. entered is unchanges) and all in all, we compute lines 3-4 times on each keypress :-/
                        // I could add a generation counter to the ModelData and +1 on each change, then monitor that... But this "is fine".
                        .onChange(of: lines) { _ in
                            NSLog("change on entered lines count is \(lines.count)")
                            // The -1 is to scroll to id:5 when list has 6 elements - starts at 0.
                            // Alternatively, assign id:1, 2...
                            scroll_reader.scrollTo(lines.count-1, anchor: .bottom)
                        }
                    }
                }
                //.frame(width: geo.size.width, height: geo.size.height/2)
                .font(.system(.largeTitle, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20.0)
            }
            // Divider()
            
            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    CalculatorButton(label: "AC", function: CalculatorFunction.ALL_CLEAR)
                    CalculatorButton(label: "C", function: CalculatorFunction.CLEAR)
                    CalculatorButton(label: "DEL", function: CalculatorFunction.DELETE)
                    CalculatorButton(label: "ANS", function: CalculatorFunction.ANS)
                        .disabled(modelData.disableDegreesAndMinutes)
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
                        .disabled(modelData.disableDegreesAndMinutes)
                    CalculatorButton(label: "m", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.disableDegreesAndMinutes)
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
                ScrollView {
                    ScrollViewReader { scroll_reader in
                        ForEach(lines, id: \.id) { line in
                            // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                            VStack {
                                if let op = line.op {
                                    if op == "=" {
                                        // FIXME: this view could be generalised
                                        Text(line.value + " " + op)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        Underscore
                                    } else if op == "==" {
                                        Text(line.value + " ")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        Underscore
                                        Underscore
                                    } else {
                                        Text(line.value + " " + op)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.white)
                                        
                                    }
                                } else {
                                    Text(line.value)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.yellow)
                                }
                            }
                            .id(line.id)
                        }
                        
                        // https://stackoverflow.com/questions/58376681/swiftui-automatically-scroll-to-bottom-in-scrollview-bottom-first
                        // FIXME: this causes "lines" to be calculated multiple times which is a waste. And doing a single "let lines = lines" earlier doesn't work, since .onChange likely has some wrapper to cache values and thus accesses it... blabla. In short, doing the onChange on lines is needed for some corner case where ANS needs to scoll (ie. entered is unchanges) and all in all, we compute lines 3-4 times on each keypress :-/
                        // I could add a generation counter to the ModelData and +1 on each change, then monitor that... But this "is fine".
                        .onChange(of: lines) { _ in
                            NSLog("change on entered lines count is \(lines.count)")
                            // The -1 is to scroll to id:5 when list has 6 elements - starts at 0.
                            // Alternatively, assign id:1, 2...
                            scroll_reader.scrollTo(lines.count-1, anchor: .bottom)
                        }
                    }
                }
                //.frame(width: geo.size.width, height: geo.size.height/2)
                .font(.system(.largeTitle, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20.0)
            }
            // Divider()
            
            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                GridRow {
                    CalculatorButton(label: "AC", function: CalculatorFunction.ALL_CLEAR)
                    CalculatorButton(label: "C", function: CalculatorFunction.CLEAR)
                    CalculatorButton(label: "DEL", function: CalculatorFunction.DELETE)
                    CalculatorButton(label: "ANS", function: CalculatorFunction.ANS)
                        .disabled(modelData.disableDegreesAndMinutes)
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
                        .disabled(modelData.disableDegreesAndMinutes)
                    CalculatorButton(label: "'", function: CalculatorFunction.ENTRY)
                        .disabled(modelData.disableDegreesAndMinutes)
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

struct Calculator_Previews: PreviewProvider {
    static func previewFor(deviceName: String, mode: ModelData.ExprMode) -> some View {
        let model = ModelData()
        model.exprMode = mode
        
        let hmsModel = ModelData()
        hmsModel.exprMode = .HMS
        
        return Calculator()
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
