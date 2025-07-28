//
//  SwiftUIView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/24/25.
//

import SwiftUI

struct DisplayLinesView: View {
    @ObservedObject var model: ObservableModelData

    var Underscore: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white)
            .padding(.trailing, 48)
            .padding(.leading, 48)
            .padding(.top, -14)
            .padding(.bottom, 0)
    }
 
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll_reader in
                ForEach(model.displayLinesCache, id: \.id) { line in
                    // https://sarunw.com/posts/how-to-make-swiftui-view-fill-container-width-and-height/
                    VStack {
                        if let op = line.trailingOperator {
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
                .onChange(of: model.displayLinesCache) { lines in
                    NSLog("change on entered lines count is \(lines.count)")
                    // The -1 is to scroll to id:5 when list has 6 elements - starts at 0.
                    // Alternatively, assign id:1, 2...
                    DispatchQueue.main.async {
                        NSLog("onChange scroll to bottom")
                        scroll_reader.scrollTo(l.count-1, anchor: .bottom)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        NSLog("onAppear scroll to bottom")
                        scroll_reader.scrollTo(model.displayLinesCache.count-1, anchor: .bottom)
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
