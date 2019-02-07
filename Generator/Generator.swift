import Foundation

class Generator {
    func random(alph: Float) -> Float {
        let sig = Float.random(in: 0...1)
        return (-1.0/alph) * log(sig)
    }
}
