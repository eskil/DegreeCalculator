//
//  Value.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/4/25.
//

import Foundation

struct Value: Codable, Hashable, CustomStringConvertible {
    enum ValueType: Codable, Hashable {
        case empty
        case integer(Int)
        case dms(degrees: Int, minutes: Decimal)
        case hms(hours: Int, minutes: Int, seconds: Int)
    }
    
    var type: ValueType = .empty
    
    init() {
        self.type = .empty
    }
    
    init(integer: Int) {
        self.type = .integer(integer)
    }
    
    init(degrees: Int, minutes: Decimal) {
        self.type = .dms(degrees: degrees, minutes: minutes)
    }
    
    init(hours: Int, minutes: Int, seconds: Int) {
        self.type = .hms(hours: hours, minutes: minutes, seconds: seconds)
    }
    
    public var description: String {
        switch type {
        case .empty:
            return "n/a"
            
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
    
    func normalise() -> Value {
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
             141° and /2 would yield 70°30'0.
             
             while degrees >= 360 {
             degrees -= 360
             }
             */
            return Value(degrees: degrees, minutes: minutes)
            
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
            return Value(hours: hours, minutes: minutes, seconds: seconds)
            
        default:
            return self
        }
    }

    func adding(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        case (.integer(let a), .integer(let b)):
            return Value(integer: a + b)
            
        case (.dms(let ldeg, let lmin), .dms(let rdeg, let rmin)):
            return Value(degrees: ldeg + rdeg, minutes: lmin + rmin).normalise()
            
        case (.hms(let lh, let lm, let ls), .hms(let rh, let rm, let rs)):
            return Value(hours: lh + rh, minutes: lm + rm, seconds: ls + rs).normalise()

        default:
            return nil
        }
    }
 
    func subtracting(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        case (.integer(let a), .integer(let b)):
            return Value(integer: a - b)
            
        case (.dms(let ldeg, let lmin), .dms(let rdeg, let rmin)):
            return Value(degrees: ldeg - rdeg, minutes: lmin-rmin).normalise()
            
        case (.hms(let lh, let lm, let ls), .hms(let rh, let rm, let rs)):
            return Value(hours: lh-rh, minutes: lm-rm, seconds: ls-rs).normalise()

        default:
            return nil
        }
    }
    
    func dividing(_ other: Value) -> Value? {
        switch (self.type, other.type) {
        case (_, .integer(let denom)) where denom != 0:
            switch(self.type) {
            case .integer(let v):
                return Value(integer: v / denom)
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
                    scale: 1, // One decimal place
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
