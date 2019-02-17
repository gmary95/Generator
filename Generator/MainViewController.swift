import Cocoa
import Charts

class MainViewController: NSViewController {
    @IBOutlet weak var correlogramChart: LineChartView!
    @IBOutlet weak var genSeriesTable: NSTableView!
    @IBOutlet weak var countTextField: NSTextFieldCell!
    @IBOutlet weak var classCountTextField: NSTextFieldCell!
    @IBOutlet weak var skewnessLabel: NSTextFieldCell!
    @IBOutlet weak var arithmeticMeanLabel: NSTextFieldCell!
    @IBOutlet weak var characteristicsTable: NSTableView!
    
    var selection: Selection!
    var regression = Array<Double>()
    let generator = Generator()
    var classCount = 0
    let alph = 0.5
    let varianceString = "Variance = "
    let arithmeticMeanString = "Arithmetic Mean = "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.correlogramChart.noDataTextColor = .white
        
        selection = Selection()
        skewnessLabel.title = varianceString
        arithmeticMeanLabel.title = arithmeticMeanString
    }
    
    @IBAction func generateRandomSeries(_ sender: Any) {
        selection = Selection()
        let count = Int(countTextField.title)
        classCount = Int(classCountTextField.title)!
        for _ in 0 ..< count! {
            let elem = generator.random(alph: alph)
            selection.append(item: elem)
            regression.append(generator.calcRegression(alph: alph, x: elem))
        }
        genSeriesTable.reloadData()
        
        skewnessLabel.title = varianceString + "\(selection.variance().rounded(toPlaces: 6))"
        arithmeticMeanLabel.title = arithmeticMeanString + "\(selection.arithmeticMean().rounded(toPlaces: 6))"
        
        let corrSet = CorrelationCalculator.getCorrelation(selection: selection)
        representCorrelogram(series: corrSet, chart: correlogramChart)
        
        characteristicsTable.reloadData()
    }
    
    func representCorrelogram(series: Array<Double>, chart: LineChartView){
        var corrChartSet = Array<ChartDataEntry>()
        for i in 0 ..< series.count {
            corrChartSet.append(ChartDataEntry(x: Double(i), y: 0))
            corrChartSet.append(ChartDataEntry(x: Double(i), y: series[i].rounded(toPlaces: 6)))
            corrChartSet.append(ChartDataEntry(x: Double(i + 1), y: series[i].rounded(toPlaces: 6)))
            corrChartSet.append(ChartDataEntry(x: Double(i + 1), y: 0))
        }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: corrChartSet, label: "Correlogram")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        dataSet.drawCirclesEnabled = false
        data.addDataSet(dataSet)
        
        var regresionSet = series.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: 0) }
        regresionSet.append(ChartDataEntry(x: Double(series.count), y: 0))
        
        let dataSetRegresion = LineChartDataSet(values: regresionSet, label: "")
        dataSetRegresion.colors = [NSUIColor.red]
        dataSetRegresion.valueColors = [NSUIColor.clear]
        dataSetRegresion.drawCirclesEnabled = false
        data.addDataSet(dataSetRegresion)
        
        chart.data = data
        
        chart.gridBackgroundColor = .red
        chart.legend.textColor = .white
        chart.xAxis.labelTextColor = .white
        chart.leftAxis.labelTextColor = .white
        chart.rightAxis.labelTextColor = .white
    }
    
}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == genSeriesTable {
            let numberOfRows:Int = selection.count
            return numberOfRows
        }
        return 1
    }
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersSelectionTable {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
    }
    
    fileprivate enum CellIdentifiersSpearmanTable {
        static let ValueCell = "ValueID"
        static let QuantilCell = "QuantilID"
        static let ResultCell = "ResultID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == genSeriesTable {
            return self.loadSelection(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == characteristicsTable {
            return self.loadPirsonTest(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    func loadSelection(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if selection.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(row + 1)"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(selection[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadPirsonTest(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if classCount != 0 {
            let x2 = PirsonCharacterCalculator.calc(selection: selection, classCount: classCount)
            let x2Q = PirsonCharacterCalculator.calcCharacteristics(alph: alph, classCount: classCount)
            if tableColumn == tableView.tableColumns[0] {
                text = "\(x2.rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSpearmanTable.ValueCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(x2Q.rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSpearmanTable.QuantilCell
            } else if tableColumn == tableView.tableColumns[2] {
                if x2 <= x2Q {
                    text = "Match"
                } else {
                    text = "Doesn't match"
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ResultCell
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
