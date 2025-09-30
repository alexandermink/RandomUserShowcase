import Foundation
import SwiftUI

extension Date {
    func asShortString() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }
}

extension Color {
    static var backgroundAccent: Color {
        Color(white: 0.97)
    }
}

func flagEmoji(from nat: String?) -> String {
    guard let nat = nat, nat.count == 2 else {
        return "🏳️"
    }
    let base: UInt32 = 127397
    var s = ""
    for v in nat.uppercased().unicodeScalars {
        if let scalar = UnicodeScalar(base + v.value) {
            s.unicodeScalars.append(scalar)
        }
    }
    return s
}
