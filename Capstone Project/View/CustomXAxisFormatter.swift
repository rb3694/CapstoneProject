//
//  CustomXAxisFormatter.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/7/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import Charts

class CustomXAxisFormatter: IAxisValueFormatter {
    var ctData: [CTClient.CTData] = []
    init( ctData: [CTClient.CTData] ) {
        self.ctData = ctData
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int( value )
        if index < ctData.count {
            let date = ctData[index].date
            //let year = date.prefix( 4 )
            let day = date.suffix( 2 )
            let startIndex = date.index( date.startIndex, offsetBy: 4 )
            let endIndex = date.index( date.endIndex, offsetBy: -2 )
            let month = date[startIndex..<endIndex]
            return "\(month)-\(day)"
        }
        return "--"
    }
    

}
