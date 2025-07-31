//
//  File.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/24/25.
//

import Foundation

/**
 Timer function used while ensuring everything is low latency for the UI.
 */
final class ExecutionTimer {
    private let label: String
    private let start: DispatchTime
    private let indent: Int

    init(_ label: String = "", indent: Int = 0) {
        self.label = label
        self.start = DispatchTime.now()
        self.indent = indent
    }

    deinit {
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds

        // Format time nicely
        let formatted = ExecutionTimer.formatTime(nanoTime)
        let indentedLabel = String(repeating: "\t", count: indent) + label
        print("\(indentedLabel) executed in \(formatted)")
    }

    private static func formatTime(_ nanoTime: UInt64) -> String {
        switch nanoTime {
        case 1_000_000_000...:
            let s = Double(nanoTime) / 1_000_000_000
            return String(format: "%.3f s", s)
        case 1_000_000...:
            let ms = Double(nanoTime) / 1_000_000
            return String(format: "%.3f ms", ms)
        case 1_000...:
            let us = Double(nanoTime) / 1_000
            return String(format: "%.3f µs", us)
        default:
            return "\(nanoTime) ns"
        }
    }
}
