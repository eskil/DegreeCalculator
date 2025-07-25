//
//  SwiftUIView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/24/25.
//

import SwiftUI

struct DisplayLinesView: View {
    @ObservedObject var model: ModelData

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
                ForEach(model.displayLines(), id: \.id) { line in
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
                
                // https://stackoverflow.com/questions/58376681/swiftui-automatically-scroll-to-bottom-in-scrollview-bottom-first
                // FIXME: this causes "lines" to be calculated multiple times which is a waste. And doing a single "let lines = lines" earlier doesn't work, since .onChange likely has some wrapper to cache values and thus accesses it... blabla. In short, doing the onChange on lines is needed for some corner case where ANS needs to scoll (ie. entered is unchanges) and all in all, we compute lines 3-4 times on each keypress :-/
                // I could add a generation counter to the ModelData and +1 on each change, then monitor that... But this "is fine".
                .onChange(of: model.displayLines()) { lines in
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
}

struct DisplayLinesView_Previews: PreviewProvider {
    static func previewFor(deviceName: String, mode: ModelData.ExprMode) -> some View {
        let model = ModelData(mode: mode)
                
        return DisplayLinesView(model: model)
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
