import Foundation

public class VariationalSeriesNode {
    public var value: Double
    public var frequency: Int
    public var relativeFrequency: Double
    public var empiricalDistributionFunction: Double
    
    public init() {
        self.value = 0.0
        self.frequency = 0
        self.relativeFrequency = 0.0
        self.empiricalDistributionFunction = 0.0
    }
    public init(value: Double) {
        self.value = value
        self.frequency = 0
        self.relativeFrequency = 0.0
        self.empiricalDistributionFunction = 0.0
    }
}

public class VariationalSeriesClass {
    public var min: Double
    public var max: Double
    public var frequency: Int
    public var relativeFrequency: Double
    public var empiricalDistributionFunction: Double
    
    
    public init(min: Double, max: Double, fr: Int, rfr: Double, edf: Double) {
        self.min = min
        self.max = max
        self.frequency = fr
        self.relativeFrequency = rfr
        self.empiricalDistributionFunction = edf
    }
}


public class VariationalSeries {
    public var series: SortedDictionary<Double, VariationalSeriesNode>
    public var valuesCount: Int
    
    public init() {
        series = SortedDictionary<Double, VariationalSeriesNode>()
        valuesCount = 0
    }
    
    private func update() {
        for node in series.values {
            node.relativeFrequency = (Double(node.frequency) / Double(valuesCount))
        }
        
        series[0].1.empiricalDistributionFunction = 0.0
        for i in 1 ..< series.count {
            series[i].1.empiricalDistributionFunction =
                series[i - 1].1.empiricalDistributionFunction + series[i].1.relativeFrequency
        }
    }
    
    public func add(value: Double, count: Int){
        if (count < 1) {
            print("Count should a posistive integer value!")
            return
        }
        
        valuesCount += count
        
        if series.keys.contains(value) == false {
            series.append((value, VariationalSeriesNode(value: value)))
        }
        
        series[value]!.frequency += count
        
        update()
    }
    
    public func add(values: Dictionary<Double, Int>) {
        for value in values {
            if (value.value > 0) {
                if (series.keys.contains(value.key) == false) {
                    series.append((value.key, VariationalSeriesNode(value: value.key)))
                }
                
                series[value.key]!.frequency += value.value
                valuesCount += value.value
            }
        }
        
        update()
    }
    
    
    public func splitIntoClasses(count: Int) -> Array<VariationalSeriesClass> {
    var result = Array<VariationalSeriesClass>()
        var classWidth: Double = ((series[series.count - 1].0 - series[0].0) / Double(count))
        var min: Double = 0
    var max: Double = series[0].0
    var classFr = 0
    var classRfr: Double = 0
    var classEdf: Double = 0
    var j = 0
    
    for i in 0 ..< (count - 1) {
    min = max
    max = min + classWidth
    classFr = 0
    
    for (; ((j < series.Count) && ((series.ElementAt(j).Key < max))); j++)
    {
    classFr += series.ElementAt(j).Value.frequency;
    }
    
    classRfr = (double)classFr / (double)valuesCount;
    classEdf = classEdf + classRfr;
    classRfr = Program.Round(classRfr);
    classEdf = Program.Round(classEdf);
    result.Add(new VariationalSeriesClass(min, max, classFr, classRfr, classEdf));
    }
    
    min = max;
    max = series.ElementAt(series.Count - 1).Key;
    classFr = 0;
    for (; j < series.Count; j++)
    {
    classFr += series.ElementAt(j).Value.frequency;
    }
    classRfr = (double)classFr / (double)valuesCount;
    classEdf = classEdf + classRfr;
    classRfr = Program.Round(classRfr);
    classEdf = Program.Round(classEdf);
    result.Add(new VariationalSeriesClass(min, max, classFr, classRfr, classEdf));
    
    return result
    }
    
    public func splitIntoClasses() -> Array<VariationalSeriesClass> {
        return splitIntoClasses(count: recomendedClassesCount())
    }
    
    public func recomendedClassesCount() -> Int {
        var result: Int
        
        if (valuesCount < 100) {
            result = Int(sqrt(Double(valuesCount)))
        } else {
            result = Int(pow(Double(valuesCount), 1.0 / 3.0))
        }
        
        if (result % 2 == 0) {
            result += 1
            
        }
        
        return result
    }
}

