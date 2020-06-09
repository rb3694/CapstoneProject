//
//  ComboChartViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/1/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ComboChartViewController: UIViewController, ChartViewDelegate {

    var selectedState : String?
    var selectedMetric : String?
    var ctData: [CTClient.CTData] = []
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<LastVisit>!
    var lastVisit: LastVisit?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var comboChartView: CombinedChartView!
    
    @IBOutlet weak var sevenDayTrendLabel: UILabel!
    @IBOutlet weak var lastVisitTrendLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK:  CoreData
    
    // Get a list of the user's predefined pins from CoreData
    fileprivate func setupFetchedResultsController() {
        let predicate = NSPredicate(format: "(state == %@) AND (metric = %@)", selectedState!, selectedMetric! )

        let fetchRequest:NSFetchRequest<LastVisit> = LastVisit.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "covid19Tracker" )
        // fetchedResultsController.delegate = self
        do {
            //print( "Performing fetch" )
            try fetchedResultsController.performFetch()
        } catch {
            fatalError( "The fetch could not be performed. \(error.localizedDescription)" )
        }
        
        if fetchedResultsController.fetchedObjects!.count > 0 {
            lastVisit = fetchedResultsController.fetchedObjects?.last
            /* ----------------- DEBUG CODE
            if let usersLastVisit = lastVisit {
                print( "LastVisit was on \(String(describing: usersLastVisit.date)) for \(String(describing: usersLastVisit.state)) \(String(describing: usersLastVisit.metric)) with a value of \(usersLastVisit.value)" )
            } else {
                print( "LastVisit is not defined" )
            }
            ----------------------- DEBUG CODE */
        } else {
            // print( "No fetched results" )
        }
    }

    fileprivate func displayAlert(_ title: String, message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Store last visit info in CoreData
    func saveLastVisit( date: String,  value: Int ) {
        // print( "Saving last visit at \(date), value: \(value)" )
        if lastVisit == nil {
            lastVisit = LastVisit( context: dataController.viewContext )
        }
        lastVisit?.metric = selectedMetric
        lastVisit?.state = selectedState
        lastVisit?.date = date
        lastVisit?.value = Int32( value )
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            displayAlert("CoreData Failed", message: "Unable to store last visit into CoreData: Error \(error.localizedDescription)")
        }
    }
    
    func isDeltaMetric(_ selectedMetric: String? ) -> Bool {
        if let selectedMetric = selectedMetric {
            if ( selectedMetric == CTClient.Metrics.Deaths ||
                 selectedMetric == CTClient.Metrics.Positives ||
                 selectedMetric == CTClient.Metrics.CumulativeICUs ||
                 selectedMetric == CTClient.Metrics.CumulativeVentilators ||
                 selectedMetric == CTClient.Metrics.CumulativeHospitalizations
               )
            {
                return true
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        // Initialize CoreData and load the model
        setupFetchedResultsController()

        var newText = ""
        if ( isDeltaMetric( selectedMetric ) ) {
            newText = " New"
        }
        titleLabel.text = (selectedState ?? "??") + newText + " Covid-19 " + (selectedMetric ?? "??")
        comboChartView.backgroundColor = .systemBlue
        comboChartView.rightAxis.enabled = false
        comboChartView.delegate = self
        
        let yAxis = comboChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12 )
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .yellow
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        let xAxis = comboChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .yellow
        xAxis.axisLineColor = .systemBlue
        
        // The next line is half of a workaround to keep the first (and last)
        // bar from being half as wide as the others.  Source: StackOverflow
        xAxis.axisMinimum = -0.5;
        
        comboChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Get the historical data for the selected state
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        CTClient.sharedInstance().getHistoricalData( selectedState! ) { ( result, error ) in
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            if error != nil {
                performUIUpdatesOnMain{
                    self.displayAlert( "HTTP Fetch failure", message: "Unable to retrieve historical data: \(String(describing: error))")
                }
            } else {
                let theData = result as! [AnyObject]
                var x = theData.count;
                while x > 0 {
                    x -= 1
                    let stateData = CTClient.CTData( theData[x] as! [String : AnyObject] )
                    self.ctData.append( stateData )
                }
            }
            performUIUpdatesOnMain {
                self.setData()
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // print( entry )
    }
    
    func setData() {
        let data = CombinedChartData()
        
        var barChartData: [BarChartDataEntry] = []
        var metricValues: [Int?] = []
        var lastMetricValue : Int?
        var lastMetricDate : String?
        var sevenDayTrend = 0
        var lastVisitedTrend = 0
        var lastVisitedIndex = -1   // Latest bar seen by user
        let xAxis = comboChartView.xAxis

        for x in 0..<ctData.count {
            if lastVisit?.date == ctData[x].date {
                lastVisitedIndex = x
                // print( "LastVisitedIndex is \(x)" )
            }
            var metricValue : Int? = ctData[x].valueForMetric( selectedMetric! )
            if x > 0 && metricValue != nil && lastMetricValue != nil && isDeltaMetric( selectedMetric ) {
                // This is a cumulative metric.
                // We don't want to show the ever increasing absolute value in the graph.
                // We want to show the change in value since the last value, to show the trend.
                metricValue = metricValue! - lastMetricValue!
            }
            if let checkmetricValue = metricValue {
                if checkmetricValue < 0 {
                    // The data must be bad.  You can't have a decrease in a cumulative metric.
                    // I have checked, and covid tracker does sometimes provide bogus numbers.
                    // Treat it like it was a non-reported value so the graph doesn't look weird
                    metricValue = nil
                }
            }
            if metricValue != nil {
                lastMetricValue = ctData[x].valueForMetric( selectedMetric! )
                lastMetricDate = ctData[x].date
            }
            metricValues.append( metricValue )
        }
        for x in 0..<metricValues.count {
            let metricValue = metricValues[x]
            if ( x > lastVisitedIndex ) {
                // This value is new since the user's last visit.  Display value as "upper" stacked bar.
                barChartData.append( BarChartDataEntry(x: Double(x), yValues: [0.0, Double( metricValue ?? 0 )] ) )
            } else {
                // User has seen this data before.  Display as "lower" stacked bar.
                barChartData.append( BarChartDataEntry(x: Double(x), yValues: [Double( metricValue ?? 0 ), 0.0] ) )
            }
        }
        let set1 = BarChartDataSet(entries: barChartData, label: selectedMetric! )
        set1.colors = [ChartColorTemplates.material()[0], ChartColorTemplates.material()[2]]
        set1.valueFont = .systemFont(ofSize: 10)
        set1.axisDependency = .left
        
        let barData = BarChartData(dataSets: [set1])
        
        // Here is the other half of the workaround to keep the last
        // bar from being half as wide as the others.  Source: StackOverflow
        xAxis.axisMaximum = Double(set1.count) - 0.5;

        var movingAverage: [ChartDataEntry] = []
        for x in 0..<set1.count {
            var accum = 0.0
            var count = 0.0
            var i = max( 0, x-6 )
            while i <= x {
                if ( metricValues[i] != nil ) {
                    accum = accum + Double( metricValues[i]! )
                    count = count + 1.0
                }
                i += 1
            }
            if ( count > 0 )
            {
                movingAverage.append( ChartDataEntry( x: barChartData[x].x, y: accum / count ))
            } else {
                movingAverage.append( ChartDataEntry( x: barChartData[x].x, y: 0.0 ))
            }
        }
        let set2 = LineChartDataSet( entries: movingAverage, label: "7-day Moving Average")
        set2.drawCirclesEnabled = false
        if movingAverage.count > 1
        {
            sevenDayTrend = Int( movingAverage[movingAverage.count - 1].y - movingAverage[movingAverage.count - 2].y )
        }
        if sevenDayTrend > 0 {
            sevenDayTrendLabel.text = "Increasing"
            sevenDayTrendLabel.textColor = .red
        } else if sevenDayTrend < 0 {
            sevenDayTrendLabel.text = "Decreasing"
            sevenDayTrendLabel.textColor = .green
        } else {
            sevenDayTrendLabel.text = "Stable"
            sevenDayTrendLabel.textColor = .black
        }
        
        if lastVisitedIndex > 0 {
            if let lastValue = metricValues[(metricValues.count) - 1] {
                if let prevValue = metricValues[lastVisitedIndex] {
                    lastVisitedTrend = Int( lastValue - prevValue )
                }
            }
        }
        if lastVisitedTrend > 0 {
            lastVisitTrendLabel.text = "Increasing"
            lastVisitTrendLabel.textColor = .red
        } else if lastVisitedTrend < 0 {
            lastVisitTrendLabel.text = "Decreasing"
            lastVisitTrendLabel.textColor = .green
        } else {
            lastVisitTrendLabel.text = "Stable"
            lastVisitTrendLabel.textColor = .black
        }

        set2.setColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        set2.lineWidth = 2.5
        set2.mode = .cubicBezier
        
        set2.axisDependency = .left
        let lineData = LineChartData(dataSet: set2)
        
        data.lineData = lineData
        data.barData = barData
        data.setDrawValues(false)
        
        comboChartView.data = data

        xAxis.valueFormatter = CustomXAxisFormatter( ctData: ctData )
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.forceLabelsEnabled = true
        
        if lastMetricDate != nil && lastMetricValue != nil {
            saveLastVisit(date: lastMetricDate!, value: lastMetricValue! )
        }
    }

}
