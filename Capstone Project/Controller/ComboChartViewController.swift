//
//  ComboChartViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/1/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import Charts

class ComboChartViewController: UIViewController, ChartViewDelegate {

    var selectedState : String?
    var selectedMetric : String?
    var sevenDayTrend = 0
    var lastVisitedTrend = 0
    var lastVisitedIndex = -1
    var ctData: [CTClient.CTData] = []

    //     @IBOutlet weak var comboChartView: CombinedChartView!
    // var oldcomboChartView: CombinedChartView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var comboChartView: CombinedChartView!
    
    @IBOutlet weak var sevenDayTrendLabel: UILabel!
    @IBOutlet weak var lastVisitTrendLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        titleLabel.text = (selectedState ?? "??") + " Covid-19 " + (selectedMetric ?? "??")
        comboChartView.backgroundColor = .systemBlue
        //comboChartView.centerInSuperview()
        //comboChartView.width(to: view)
        //comboChartView.heightToWidth(of: view)
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
        
        comboChartView.animate(xAxisDuration: 1.0)
        
        // Get the historical data for the selected state
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        CTClient.sharedInstance().getHistoricalData( selectedState! ) { ( result, error ) in
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
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
        print( entry )
    }
    
    func setData() {
        let data = CombinedChartData()
        
        var barChartData: [BarChartDataEntry] = []

        for x in 0..<ctData.count {
            barChartData.append( BarChartDataEntry( x: Double(x), y: Double( ctData[x].valueForMetric( selectedMetric! ) ?? 0 ) ) )
            print("x: \(x), y: \(barChartData[x].y)")
        }
        let set1 = BarChartDataSet(entries: barChartData, label: selectedMetric! )
        set1.setColor(UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1))
        //set1.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
        set1.valueFont = .systemFont(ofSize: 10)
        set1.axisDependency = .left
        //let groupSpace = 0.06
        //let barSpace = 0.02 // x2 dataset
        //let barWidth = 0.45 // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        
        let barData = BarChartData(dataSets: [set1])
        //barData.barWidth = barWidth * 2 // only using one bar here, two in example code
        
        // Here is the other half of the workaround to keep the last
        // bar from being half as wide as the others.  Source: StackOverflow
        comboChartView.xAxis.axisMaximum = Double(set1.count) - 0.5;

        //let set1 = LineChartDataSet(entries: chartData, label: "Hospitalizations")
        //set1.drawCirclesEnabled = false
        //set1.mode = .cubicBezier
        //set1.lineWidth = 3.0
        //set1.setColor( .white )
        //set1.fill = Fill( color: .white)
        //set1.fillAlpha = 0.8
        //set1.drawFilledEnabled = true
        // //set1.drawHorizontalHighlightIndicatorEnabled = false
        //set1.highlightColor = .systemRed

        var movingAverage: [ChartDataEntry] = []
        for x in 0..<set1.count {
            var accum = 0.0
            var count = 0.0
            var i = max( 0, x-6 )
            while i <= x {
                if ( ctData[x].valueForMetric( selectedMetric! ) != nil ) {
                    accum = accum + barChartData[i].y
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
//        set2.mode = .cubicBezier
//        set2.lineWidth = 3.0
//        set2.setColor( .red )
//        set2.highlightColor = .systemGreen
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
        if ( lastVisitedIndex > 0 )
        {
            lastVisitedTrend = Int( movingAverage[movingAverage.count - 1].y - movingAverage[lastVisitedIndex].y )
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
        //set2.setCircleColor(UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1))
        //set2.circleRadius = 5
        //set2.circleHoleRadius = 2.5
        //set2.fillColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        set2.mode = .cubicBezier
        //set2.drawValuesEnabled = true
        //set2.valueFont = .systemFont(ofSize: 10)
        //set2.valueTextColor = UIColor(red: 240/255, green: 238/255, blue: 70/255, alpha: 1)
        
        set2.axisDependency = .left
        let lineData = LineChartData(dataSet: set2)
        
        data.lineData = lineData
        data.barData = barData

        //let dataSets = [ set1, set2 ]
        //let data = LineChartData(dataSets: dataSets)
        data.setDrawValues(false)

        //let data2 = LineChartData(dataSet: set2)
        
        comboChartView.data = data
    }

    /* let barChartData: [BarChartDataEntry] = [
        BarChartDataEntry(x: 1.0, y: 0.0),
        BarChartDataEntry(x: 2.0, y: 0.0),
        BarChartDataEntry(x: 3.0, y: 0.0),
        BarChartDataEntry(x: 4.0, y: 1.0),
        BarChartDataEntry(x: 5.0, y: 2.0),
        BarChartDataEntry(x: 6.0, y: 3.0),
        BarChartDataEntry(x: 7.0, y: 4.0),
        BarChartDataEntry(x: 8.0, y: 5.0),
        BarChartDataEntry(x: 9.0, y: 10.0),
        BarChartDataEntry(x: 10.0, y: 20.0),
        BarChartDataEntry(x: 11.0, y: 30.0),
        BarChartDataEntry(x: 12.0, y: 40.0),
        BarChartDataEntry(x: 13.0, y: 80.0),
        BarChartDataEntry(x: 14.0, y: 140.0),
        BarChartDataEntry(x: 15.0, y: 160.0),
        BarChartDataEntry(x: 16.0, y: 170.0),
        BarChartDataEntry(x: 17.0, y: 185.0),
        BarChartDataEntry(x: 18.0, y: 195.0),
        BarChartDataEntry(x: 19.0, y: 200.0),
        BarChartDataEntry(x: 20.0, y: 201.0),
        BarChartDataEntry(x: 21.0, y: 202.0),
        BarChartDataEntry(x: 22.0, y: 205.0),
        BarChartDataEntry(x: 23.0, y: 206.0),
        BarChartDataEntry(x: 24.0, y: 209.0),
        BarChartDataEntry(x: 25.0, y: 210.0),
        BarChartDataEntry(x: 26.0, y: 208.0),
        BarChartDataEntry(x: 27.0, y: 205.0),
        BarChartDataEntry(x: 28.0, y: 200.0),
        BarChartDataEntry(x: 29.0, y: 205.0),
        BarChartDataEntry(x: 30.0, y: 192.0),
        BarChartDataEntry(x: 31.0, y: 185.0)
     ]
     */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
