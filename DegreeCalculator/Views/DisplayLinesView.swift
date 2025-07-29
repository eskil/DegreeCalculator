//
//  SwiftUIView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/24/25.
//

import SwiftUI

struct DisplayLinesView: View {
    @ObservedObject var model: ObservableModelData
    @State private var previousLastLineID: Int? = nil

    // Draw a thin line
    var Underscore: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white)
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
                                    .foregroundColor(.white)
                                Underscore
                            case "==":
                                Text(line.value + " ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                DoubleUnderscore
                            default:
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
        .padding(20.0)
    }
}

struct DisplayLinesView_Previews: PreviewProvider {
    static func previewFor(deviceName: String, mode: ModelData.ExprMode) -> some View {
        let md = ObservableModelData(mode: mode)

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        md.callFunction(CalculatorFunction.EQUAL, label: "")

        return DisplayLinesView(model: md)
            .background(Color.black)
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
