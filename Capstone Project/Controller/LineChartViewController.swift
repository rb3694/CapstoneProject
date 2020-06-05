//
//  LineChartViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 5/26/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints

// This is no longer used in the capstone project.  Using CombinationChartView instead
// Just wanted to save this in case I need to cannibalize the code
class LineChartViewController: UIViewController, ChartViewDelegate {
    
    var selectedState : String?
    var selectedMetric : String?

    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.backgroundColor = .systemBlue
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        lineChartView.rightAxis.enabled = false
        lineChartView.delegate = self
        
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12 )
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .yellow
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(6, force: false)
        xAxis.labelTextColor = .yellow
        xAxis.axisLineColor = .systemBlue
        
        lineChartView.animate(xAxisDuration: 1.0)
        
        setData()

        // Do any additional setup after loading the view.
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print( entry )
    }
    
    func setData() {
        
        let set1 = LineChartDataSet(entries: chartData, label: "Hospitalizations")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 3.0
        set1.setColor( .white )
        set1.fill = Fill( color: .white)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        //set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor = .systemRed

        var movingAverage: [ChartDataEntry] = []
        for x in 0..<set1.count {
            var accum = 0.0
            var count = 0.0
            var i = max( 0, x-6 )
            while i <= x {
                accum = accum + chartData[i].y
                count = count + 1.0
                i += 1
            }
            if ( count > 0 )
            {
                movingAverage.append( ChartDataEntry( x: chartData[x].x, y: accum / count ))
            } else {
                movingAverage.append( ChartDataEntry( x: chartData[x].x, y: 0.0 ))
            }
        }
        let set2 = LineChartDataSet( entries: movingAverage, label: "7-day Moving Average")
        set2.drawCirclesEnabled = false
        set2.mode = .cubicBezier
        set2.lineWidth = 3.0
        set2.setColor( .red )
        set2.highlightColor = .systemGreen

        let dataSets = [ set1, set2 ]
        let data = LineChartData(dataSets: dataSets)
        data.setDrawValues(false)

        //let data2 = LineChartData(dataSet: set2)
        
        lineChartView.data = data
    }

    let chartData: [ChartDataEntry] = [
        ChartDataEntry(x: 1.0, y: 0.0),
        ChartDataEntry(x: 2.0, y: 0.0),
        ChartDataEntry(x: 3.0, y: 0.0),
        ChartDataEntry(x: 4.0, y: 1.0),
        ChartDataEntry(x: 5.0, y: 2.0),
        ChartDataEntry(x: 6.0, y: 3.0),
        ChartDataEntry(x: 7.0, y: 4.0),
        ChartDataEntry(x: 8.0, y: 5.0),
        ChartDataEntry(x: 9.0, y: 10.0),
        ChartDataEntry(x: 10.0, y: 20.0),
        ChartDataEntry(x: 11.0, y: 30.0),
        ChartDataEntry(x: 12.0, y: 40.0),
        ChartDataEntry(x: 13.0, y: 80.0),
        ChartDataEntry(x: 14.0, y: 140.0),
        ChartDataEntry(x: 15.0, y: 160.0),
        ChartDataEntry(x: 16.0, y: 170.0),
        ChartDataEntry(x: 17.0, y: 185.0),
        ChartDataEntry(x: 18.0, y: 195.0),
        ChartDataEntry(x: 19.0, y: 200.0),
        ChartDataEntry(x: 20.0, y: 201.0),
        ChartDataEntry(x: 21.0, y: 202.0),
        ChartDataEntry(x: 22.0, y: 205.0),
        ChartDataEntry(x: 23.0, y: 206.0),
        ChartDataEntry(x: 24.0, y: 209.0),
        ChartDataEntry(x: 25.0, y: 210.0),
        ChartDataEntry(x: 26.0, y: 208.0),
        ChartDataEntry(x: 27.0, y: 205.0),
        ChartDataEntry(x: 28.0, y: 200.0),
        ChartDataEntry(x: 29.0, y: 205.0),
        ChartDataEntry(x: 30.0, y: 192.0),
        ChartDataEntry(x: 31.0, y: 185.0)
     ]
}
