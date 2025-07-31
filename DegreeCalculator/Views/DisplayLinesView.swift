//
//  SwiftUIView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/24/25.
//

import SwiftUI

struct DisplayLinesView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var model: ObservableModelData
    // Track last `DisplayLine` id shown. We scroll to the bottom
    // when `ObservableModelData`'s `displayLines`'s last id is different.
    @State private var previousLastLineID: Int? = nil

    var textColor: Color {
        return colorScheme == .dark ? .white : .black
    }

    var activeTextColor: Color {
        return colorScheme == .dark ? .yellow : .blue
    }

    // Draw a thin line
    var Underscore: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(textColor)
            .padding(.trailing, 48)
            .padding(.leading, 48)
            .padding(.top, -14)
            .padding(.bottom, 0)
    }
 
    // Guess what...
    var DoubleUnderscore: some View {
        VStack(spacing: 6) {
            Underscore
            Underscore
        }
    }
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollReader in
                ForEach(model.displayLines, id: \.id) { line in
                    LazyVStack {
                        if let op = line.trailingOperator {
                            switch op {
                            case "=":
                                Text(line.value + " " + op)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(textColor)
                                Underscore
                            case "==":
                                Text(line.value + " ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(textColor)
                                DoubleUnderscore
                            default:
                                Text(line.value + " " + op)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(textColor)
                            }
                        } else {
                            Text(line.value)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(activeTextColor)
                        }
                    }
                    .id(line.id)
                }                
                .onChange(of: model.displayLines) { lines in
                    guard let last = lines.last else { return }
                    if last.id != previousLastLineID {
                        scrollReader.scrollTo(last.id, anchor: .bottom)
                        previousLastLineID = last.id
                    }
                }
                .onAppear {
                    guard let last = model.displayLines.last else { return }
                    if last.id != previousLastLineID {
                        withAnimation(.easeOut(duration: 0.0)) {
                            scrollReader.scrollTo(last.id, anchor: .bottom)
                        }
                        previousLastLineID = last.id
                    }
                }
            }
            .transaction { $0.animation = nil }
        }
        .transaction { $0.animation = nil }
        //.frame(width: geo.size.width, height: geo.size.height/2)
        .font(.system(.largeTitle, design: .monospaced))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.top], 10.0)
        .padding([.bottom], 0)
    }
}

struct DisplayLinesView_Previews: PreviewProvider {
    static func previewFor(deviceName: String, mode: ModelData.ExprMode) -> some View {
        let md = ObservableModelData(mode: mode)

        do {
            try md.callFunction(CalculatorFunction.ENTRY, label: "1")
            try md.callFunction(CalculatorFunction.ADD, label: "")
            try md.callFunction(CalculatorFunction.ENTRY, label: "2")
            try md.callFunction(CalculatorFunction.EQUAL, label: "")
        } catch {
            NSLog("Bad input: \(error)")
        }
            
        return DisplayLinesView(model: md)
            .background(.black)
            .previewLayout(.sizeThatFits)
            .padding()
            .environmentObject(md)
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName + " - \(mode)")
    }
    
    static var previews: some View {
        Group {
            ForEach(["iPhone 16 Pro", "iPad (10th generation)"], id: \.self) { deviceName in
                previewFor(deviceName: deviceName, mode: .DMS)
                previewFor(deviceName: deviceName, mode: .HMS)
            }
        }
    }
}
