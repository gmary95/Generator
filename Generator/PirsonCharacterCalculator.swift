import Foundation

class PirsonCharacterCalculator {

    static public func calc(selection: Selection, classCount: Int) -> Double {
        var result = 0.0
//        var ni, nit: Double
        for i in 0 ..< classCount {
//            result += (pow(ni - nit, 2.0)/nit)
        }
        return result
    }
    
    static public func calcCharacteristics(alph: Double, classCount: Int) -> Double {
        return Quantil.PirsonQuantil(p: 1.0 - alph, v: Double(classCount - 1))
    }
}
