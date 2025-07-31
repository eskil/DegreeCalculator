//
//  Value.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/4/25.
//

import Foundation

/**
 `Value`s contain the base values that make up `Expr`essions.
 Operations (add/subtract etc) are performed here.
 */
struct Value: Codable, Hashable, CustomStringConvertible {
    /**
     `ValueType` are the various types of values supported.
     Each enum has associated values per type.
     */
    enum ValueType: Codable, Hashable {
        case empty
        case integer(Int)
        case dms(degrees: Int, minutes: Decimal)
        case hms(hours: Int, minutes: Int, seconds: Int)
    }
    
    /**
     Provide hint to `init(parsing:)` methods as to how to parse the given string.
     Use `.detect` to try and infer the value from the strong.
     */
    enum ValueTypeHint {
        case empty
        case integer
        case dms
        case hms
        case detect
    }
    
    /**
     Exception enum for parser errors.
     NOTE: `Value.init(parsing:)` that throws this is not used in the code. It's
     left here as a curiosum.
     */
    enum ValueParseError: Error, CustomStringConvertible, Equatable {
        case emptyInput
        case invalidInteger(String)
        case invalidDMS(String)
        case invalidHMS(String)
        case unsupportedFormat(String)

        var description: String {
            switch self {
            case .emptyInput:
                return "The input string is empty."
            case .invalidInteger(let s):
                return "Could not parse integer from input: '\(s)'"
            case .invalidDMS(let s):
                return "Could not parse DMS from input: '\(s)'"
            case .invalidHMS(let s):
                return "Could not parse HMS from input: '\(s)'"
            case .unsupportedFormat(let s):
                return "Input does not match any known format: '\(s)'"
            }
        }
    }
    
    /**
     The type of the enum, and the default is empty.
     */
    var type: ValueType = .empty
    
    private init(type: ValueType) {
        self.type = type
    }

    
    init() {
        self = Value(type: .empty)
    }
    
    init(integer: Int) {
        self = Value(type: .integer(integer))
    }
    
    init(degrees: Int, minutes: Decimal) {
        self = Value(type: .dms(degrees: degrees, minutes: minutes)).normalised()
    }
    
    init(hours: Int, minutes: Int, seconds: Int) {
        self = Value(type: .hms(hours: hours, minutes: minutes, seconds: seconds)).normalised()
    }
    
    /**
     Attempt to parse the given string, optionally using a hint.
     */
    init?(parsing string: String, hint: ValueTypeHint = .detect) {
        let actualHint = (hint == .detect) ? Value.detectHint(parsing: string) : hint
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        switch actualHint {
        case .empty:
            guard trimmed.isEmpty else { return nil }
            self = Value()
        case .integer:
            guard let intVal = Int(trimmed) else { return nil }
            self = Value(integer: intVal)
        case .dms:
            guard let val = Self.parseDMS(trimmed) else { return nil }
            self = val
        case .hms:
            guard let val = Self.parseHMS(trimmed) else { return nil }
            self = val
        case .detect:
            return nil  // detect case is unreachable due to replacement above
        }
    }

    /** Sketch fallback to init?, which falls back to empty values or fails */
    init(parsing string: String, hint: ValueTypeHint = .detect, fallbackToEmpty: Bool = false) throws {
        let actualHint = (hint == .detect) ? Self.detectHint(parsing: string) : hint
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        switch actualHint {
        case .empty:
            if trimmed.isEmpty {
                self = Value()
            } else if fallbackToEmpty {
                self = Value()
            } else {
                throw ValueParseError.unsupportedFormat(string)
            }

        case .integer:
            if let intVal = Int(trimmed) {
                self = Value(integer: intVal)
            } else if fallbackToEmpty {
                self = Value()
            } else {
                throw ValueParseError.invalidInteger(string)
            }

        case .dms:
            if let val = Self.parseDMS(trimmed) {
                self = val
            } else if fallbackToEmpty {
                self = Value()
            } else {
                throw ValueParseError.invalidDMS(string)
            }

        case .hms:
            if let val = Self.parseHMS(trimmed) {
                self = val
            } else if fallbackToEmpty {
                self = Value()
            } else {
                throw ValueParseError.invalidHMS(string)
            }

        case .detect:
            // detect case is unreachable due to replacement above
            throw ValueParseError.unsupportedFormat(string)
        }
    }

    static func parseDMS(_ input: String) -> Value? {
        // ChatGPT generated
        let pattern = #"(?:(?<deg>\d*)°)?\s*(?:(?<min>\d+))?'?\s*(?:(?<sec>\d))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let nsrange = NSRange(input.startIndex..<input.endIndex, in: input)
        guard let match = regex.firstMatch(in: input, options: [], range: nsrange) else { return nil }

        func getIntOrZero(_ name: String) -> Int {
            let range = match.range(withName: name)
            if let r = Range(range, in: input) {
                return Int(input[r]) ?? 0
            }
            return 0
        }

        let deg = getIntOrZero("deg")
        let min = getIntOrZero("min")
        let sec = getIntOrZero("sec")
        let totalMinutes = Decimal(min) + Decimal(sec) / 10

        return Value(degrees: deg, minutes: totalMinutes)
    }

    static func parseHMS(_ input: String) -> Value? {
        // ChatGPT generated
        let pattern = #"(?:(?<hr>\d*)h)?\s*(?:(?<min>\d*)m)?\s*(?:(?<sec>\d+))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let nsrange = NSRange(input.startIndex..<input.endIndex, in: input)
        guard let match = regex.firstMatch(in: input, options: [], range: nsrange) else { return nil }

        func getIntOrZero(_ name: String) -> Int {
            let range = match.range(withName: name)
            if let r = Range(range, in: input), !input[r].isEmpty {
                return Int(input[r]) ?? 0
            }
            return 0
        }

        let hr = getIntOrZero("hr")
        let min = getIntOrZero("min")
        let sec = getIntOrZero("sec")

        return Value(hours: hr, minutes: min, seconds: sec)
    }
    
    /**
     Detect how to parse the string. Checks for presence of eg. degree or hour-minute symbols.
     */
    static func detectHint(parsing input: String) -> Value.ValueTypeHint {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .empty
        }
        if trimmed.contains("°") || trimmed.contains("'") {
            return .dms
        }
        if trimmed.contains("h") || trimmed.contains("m") {
            return .hms
        }
        if Int(trimmed) != nil {
            return .integer
        }
        return .empty  // fallback
    }
    
    public var description: String {
        switch type {
        case .empty:
            return "<empty>"
            
        case .integer(let value):
            return String(value)
            
        case .dms(let deg, let min):
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumIntegerDigits = 2
            formatter.minimumIntegerDigits = 2
            formatter.decimalSeparator = "'"
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1

            let minStr = formatter.string(from: min as NSNumber) ?? "\(min)"
            return "\(deg)°\(minStr)"
            
        case .hms(let h, let m, let s):
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximumIntegerDigits = 2
            formatter.minimumIntegerDigits = 2
            formatter.decimalSeparator = ""
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0

            
            let mStr = formatter.string(from: m as NSNumber) ?? "\(m)"
            let sStr = formatter.string(from: s as NSNumber) ?? "\(s)"
            return "\(h)h\(mStr)m\(sStr)s"
        }
    }
    
    /**
     Normalise the value.
     Examples
     - 61 seconds is 1 minute 1 second.
     - 61 minutes is 1 degree/hour 1 minutes
     */
    mutating func normalise() -> Self {
        switch type {
        case .dms(let d, let m):
            var degrees = d
            var minutes = m
            
            while minutes >= 60.0 {
                degrees += 1
                minutes -= 60.0
            }
            while minutes < 0.0  {
                minutes += 60.0
                degrees -= 1
            }
            while degrees < 0 {
                degrees += 360
            }
            /*
             NOTE: disable auto overflow subtractions as we add -360 button
             instead. This allows adding eg. 250° + 251°= 501° to divide
             by 2 to get 250°30'0. If we still did this, 501 would become
             141° and /2 would yield 70°30'0. We do not want that.
             
             while degrees >= 360 {
             degrees -= 360
             }
             */
            type =  .dms(degrees: degrees, minutes: minutes)
            
        case .hms(let h, let m, let s):
            var hours = h
            var minutes = m
            var seconds = s
            
            while seconds >= 60 {
                minutes += 1
                seconds -= 60
            }
            while seconds < 0 {
                minutes -= 1
                seconds += 60
            }
            while minutes >= 60 {
                hours += 1
                minutes -= 60
            }
            while minutes < 0  {
                hours -= 1
                minutes += 60
            }
            type = .hms(hours: hours, minutes: minutes, seconds: seconds)
        default:
            break
        }
        return self
    }

    /**
     Non-mutating version of normalise.
     */
    func normalised() -> Value {
        var copy = self
        _ = copy.normalise()
        return copy
    }

    func adding(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        case (.integer(let a), .integer(let b)):
            return Value(integer: a + b)
            
        case (.dms(let ldeg, let lmin), .dms(let rdeg, let rmin)):
            return Value(degrees: ldeg + rdeg, minutes: lmin + rmin).normalised()
            
        case (.hms(let lh, let lm, let ls), .hms(let rh, let rm, let rs)):
            return Value(hours: lh + rh, minutes: lm + rm, seconds: ls + rs).normalised()

        default:
            return nil
        }
    }
 
    func subtracting(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        case (.integer(let a), .integer(let b)):
            return Value(integer: a - b)
            
        case (.dms(let ldeg, let lmin), .dms(let rdeg, let rmin)):
            return Value(degrees: ldeg - rdeg, minutes: lmin-rmin).normalised()
            
        case (.hms(let lh, let lm, let ls), .hms(let rh, let rm, let rs)):
            return Value(hours: lh-rh, minutes: lm-rm, seconds: ls-rs).normalised()

        default:
            return nil
        }
    }
    
    func dividing(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        // Use pattern matching here to ensure we only use
        // a denominator that's an integer and it's > 0
        case (_, .integer(let denom)) where denom != 0:
            // Now match on the numerator type
            switch(self.type) {
            case .integer(let v):
                let roundingBehavior = NSDecimalNumberHandler(
                    roundingMode: NSDecimalNumber.RoundingMode.plain,
                    scale: 0, // Round to integer
                    raiseOnExactness: false,
                    raiseOnOverflow: false,
                    raiseOnUnderflow: false,
                    raiseOnDivideByZero: false
                )
                
                let unrounded = NSDecimalNumber(decimal: Decimal(v) / Decimal(denom))
                let rounded = unrounded.rounding(accordingToBehavior: roundingBehavior)
                
                return Value(integer: rounded.intValue)
                
            case .dms(let deg, let min):
                let roundingBehavior = NSDecimalNumberHandler(
                    roundingMode: NSDecimalNumber.RoundingMode.plain,
                    scale: 1, // One decimal place
                    raiseOnExactness: false,
                    raiseOnOverflow: false,
                    raiseOnUnderflow: false,
                    raiseOnDivideByZero: false
                )
                
                let full_minutes = Decimal(deg * 60) + min
                let unrounded = NSDecimalNumber(decimal: full_minutes / Decimal(denom))
                let rounded = unrounded.rounding(accordingToBehavior: roundingBehavior)
                
                let degrees = rounded.intValue / 60
                let minutes = rounded.decimalValue - Decimal(degrees * 60)
                
                return Value(degrees: degrees, minutes: minutes)
                
            case .hms(let h, let m, let s):
                let roundingBehavior = NSDecimalNumberHandler(
                    roundingMode: NSDecimalNumber.RoundingMode.plain,
                    scale: 0, // Round to integer
                    raiseOnExactness: false,
                    raiseOnOverflow: false,
                    raiseOnUnderflow: false,
                    raiseOnDivideByZero: false
                )
                
                let full_seconds = Decimal(h * 3600) + Decimal(m * 60) + Decimal(s)
                let unrounded = NSDecimalNumber(decimal: full_seconds / Decimal(denom))
                let rounded = unrounded.rounding(accordingToBehavior: roundingBehavior)
                
                let hours = rounded.intValue / 3600
                let minutes = (rounded.intValue - hours * 3600) / 60
                let seconds = rounded.intValue - hours * 3600 - minutes * 60
                
                return Value(hours: hours, minutes: minutes, seconds: seconds)
                
            default:
                return nil
            }

        default:
            return nil
        }
    }
}
