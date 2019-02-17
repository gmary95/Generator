import Foundation

class Generator {
    func random(alph: Double) -> Double {
        let sig = Double.random(in: 0...1)
        return (-1.0/alph) * log(sig)
    }
    
    func calcRegression(alph: Double, x: Double) -> Double {
        return (1.0 - exp((-1.0 * alph * x)))
    }
}
