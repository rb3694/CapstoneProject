//
//  CTConstants.swift
//  Capstone Project
//
//  Created by Robert Busby on 5/26/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import MapKit

extension CTClient {
    
    // MARK: Configuration
    
    struct Configuration {
        static let CellLimit = 25
    }
    
    // MARK: Defaults
    
    struct Defaults {
        static let HasLaunched = "HasLaunched"
        static let MapCenterLatitude = "MapCenterLatitude"
        static let MapCenterLongitude = "MapCenterLongitude"
        static let MapLongDelta = "MapLongDelta"
        static let MapLatDelta = "MapLatDelta"
        static let Metric = "Metric"
    }
    
    struct Metrics {
        static let Deaths = "Deaths"
        static let CurrentVentilators = "Ventilators (current)"
        static let CumulativeVentilators = "Ventilators (cumulative)"
        static let CurrentICUs = "ICU (current)"
        static let CumulativeICUs = "ICU (cumulative)"
        static let CurrentHospitalizations = "Hospitalizations (current)"
        static let CumulativeHospitalizations = "Hospitalizations (cumulative)"
        static let Positives = "Positive Tests"
        static let metricsList = [ Metrics.Deaths, Metrics.CurrentVentilators, Metrics.CumulativeVentilators, Metrics.CurrentICUs, Metrics.CumulativeICUs, Metrics.CurrentHospitalizations, Metrics.CumulativeHospitalizations, Metrics.Positives ]
    }
    
    // MARK: HttpMethods
    
    struct HttpMethods {
        static let Get = "GET"
        static let Post = "POST"
        static let Put = "PUT"
        static let Delete = "DELETE"
    }
    
    // MARK: CovidTrack
    
    struct CovidTrack {
        static let APIScheme = "https"
        static let APIHost = "covidtracking.com"
        static let APIPath = "/api/v1/"
        static let US = "us/"
        static let States = "states/"
        static let Current = "current.json"
        static let Daily = "daily.json"
        static let Info = "info.json"
    }
    
    // MARK: Geographic Centers
    
    // Avoid killing the network with 57 forward geocoding requests.
    // Source:  GeoHack @ tools.wmflabs.org
    
    struct GeoCenters {
        static let States: [String:CLLocationCoordinate2D] = [
            "AL":   CLLocationCoordinate2D( latitude: 32.7794, longitude: -86.8287 ),
            "AK":   CLLocationCoordinate2D( latitude: 64.0685, longitude: -152.2782 ),
            "AR":   CLLocationCoordinate2D( latitude: 34.8938, longitude: -92.4426 ),
            "AZ":   CLLocationCoordinate2D( latitude: 34.2744, longitude: -111.6602 ),
            "CA":   CLLocationCoordinate2D( latitude: 37.1841, longitude: -119.4696 ),
            "CO":   CLLocationCoordinate2D( latitude: 38.9972, longitude: -105.5478 ),
            "CT":   CLLocationCoordinate2D( latitude: 41.6219, longitude: -72.7273 ),
            "DE":   CLLocationCoordinate2D( latitude: 38.9896, longitude: -75.505 ),
            "DC":   CLLocationCoordinate2D( latitude: 38.9101, longitude: -77.0147 ),
            "FL":   CLLocationCoordinate2D( latitude: 28.6305, longitude: -82.4497 ),
            "GA":   CLLocationCoordinate2D( latitude: 32.6415, longitude: -83.4426 ),
            "HI":   CLLocationCoordinate2D( latitude: 20.2927, longitude: -156.3737 ),
            "ID":   CLLocationCoordinate2D( latitude: 44.3509, longitude: -114.613 ),
            "IL":   CLLocationCoordinate2D( latitude: 40.0417, longitude: -89.1965 ),
            "IN":   CLLocationCoordinate2D( latitude: 39.8942, longitude: -86.2816 ),
            "IA":   CLLocationCoordinate2D( latitude: 42.0751, longitude: -93.496 ),
            "KS":   CLLocationCoordinate2D( latitude: 38.4937, longitude: -98.3804 ),
            "KY":   CLLocationCoordinate2D( latitude: 37.5347, longitude: -85.3021 ),
            "LA":   CLLocationCoordinate2D( latitude: 31.0689, longitude: -91.9968 ),
            "ME":   CLLocationCoordinate2D( latitude: 45.3695, longitude: -69.2428 ),
            "MD":   CLLocationCoordinate2D( latitude: 39.055,  longitude: -76.7909 ),
            "MA":   CLLocationCoordinate2D( latitude: 42.2596, longitude: -71.8083 ),
            "MI":   CLLocationCoordinate2D( latitude: 44.3467, longitude: -85.4102 ),
            "MN":   CLLocationCoordinate2D( latitude: 46.2807, longitude: -94.3053 ),
            "MS":   CLLocationCoordinate2D( latitude: 32.7364, longitude: -89.6678 ),
            "MO":   CLLocationCoordinate2D( latitude: 38.3566, longitude: -92.458 ),
            "MT":   CLLocationCoordinate2D( latitude: 47.0527, longitude: -109.6333 ),
            "NE":   CLLocationCoordinate2D( latitude: 41.5378, longitude: -99.7951 ),
            "NV":   CLLocationCoordinate2D( latitude: 39.3289, longitude: -116.6312 ),
            "NH":   CLLocationCoordinate2D( latitude: 43.6805, longitude: -71.5811 ),
            "NJ":   CLLocationCoordinate2D( latitude: 40.1907, longitude: -74.6728 ),
            "NM":   CLLocationCoordinate2D( latitude: 34.4071, longitude: -106.1126 ),
            "NY":   CLLocationCoordinate2D( latitude: 42.9538, longitude: -75.5268 ),
            "NC":   CLLocationCoordinate2D( latitude: 35.5557, longitude: -79.3877 ),
            "ND":   CLLocationCoordinate2D( latitude: 47.4501, longitude: -100.4659 ),
            "OH":   CLLocationCoordinate2D( latitude: 40.2862, longitude: -82.7937 ),
            "OK":   CLLocationCoordinate2D( latitude: 35.5889, longitude: -97.4943 ),
            "OR":   CLLocationCoordinate2D( latitude: 43.9336, longitude: -120.5583),
            "PA":   CLLocationCoordinate2D( latitude: 40.8781, longitude: -77.7996 ),
            "RI":   CLLocationCoordinate2D( latitude: 41.6762, longitude: -71.5562 ),
            "SC":   CLLocationCoordinate2D( latitude: 33.9169, longitude: -80.8964 ),
            "SD":   CLLocationCoordinate2D( latitude: 44.4443, longitude: -100.2263 ),
            "TN":   CLLocationCoordinate2D( latitude: 35.858,  longitude: -86.3505 ),
            "TX":   CLLocationCoordinate2D( latitude: 31.4757, longitude: -99.3312 ),
            "UT":   CLLocationCoordinate2D( latitude: 39.3055, longitude: -111.6703 ),
            "VT":   CLLocationCoordinate2D( latitude: 44.0687, longitude: -72.6658 ),
            "VA":   CLLocationCoordinate2D( latitude: 37.5215, longitude: -78.8537 ),
            "WA":   CLLocationCoordinate2D( latitude: 47.3826, longitude: -120.4472 ),
            "WV":   CLLocationCoordinate2D( latitude: 38.6409, longitude: -80.6227 ),
            "WI":   CLLocationCoordinate2D( latitude: 44.6243, longitude: -89.9941 ),
            "WY":   CLLocationCoordinate2D( latitude: 42.9957, longitude: -107.5512 ),
            "AS":   CLLocationCoordinate2D( latitude: -14.290078, longitude: -170.702787 ),
            "GU":   CLLocationCoordinate2D( latitude: 13.443976, longitude: 144.767149 ),
            "MP":   CLLocationCoordinate2D( latitude: 18.318329, longitude: 146.028419 ),
            "PR":   CLLocationCoordinate2D( latitude: 18.222264, longitude: -66.430278 ),
            "VI":   CLLocationCoordinate2D( latitude: 18.048155, longitude: -64.803436 ),
            "US":   CLLocationCoordinate2D( latitude: 39.833333, longitude: -98.583333 )
        ]
    }
    
    
    // MARK: CovidTrack Response Keys
    
    struct CTResponseKeys {
        static let Date = "date"
        static let State = "state"
    }
    
    struct CTData : Codable {
        let state:                  String
        let date:                   String
        let positive:               Int?
        let negative:               Int?
        let pending:                Int?
        let hospitalizedCurrently:  Int?
        let hospitalizedCumulative: Int?
        let inIcuCurrently:         Int?
        var inIcuCumulative:        Int?
        var onVentilatorCurrently:  Int?
        var onVentilatorCumulative: Int?
        var recovered:              Int?
        var hash:                   String
        var lastModified:           String
        var death:                  Int?
        var totalTestResults:       Int?
        var dataQualityGrade:       String
        
        init( _ jsonDictionary : [String:AnyObject] ) {
            self.state = (jsonDictionary["state"] as? String) ?? "US"
            if jsonDictionary["date"] == nil {
                self.date = "date not specified"
            } else {
                self.date = String(jsonDictionary["date"] as! Int)
            }
            self.positive = jsonDictionary["positive"] as? Int
            self.negative = jsonDictionary["negative"] as? Int
            self.pending = jsonDictionary["pending"] as? Int
            self.hospitalizedCurrently = jsonDictionary["hospitalizedCurrently"] as? Int
            self.hospitalizedCumulative = jsonDictionary["hospitalizedCumulative"] as? Int
            self.inIcuCurrently = jsonDictionary["inIcuCurrently"] as? Int
            self.inIcuCumulative = jsonDictionary["inIcuCumulative"] as? Int
            self.onVentilatorCurrently = jsonDictionary["onVentilatorCurrently"] as? Int
            self.onVentilatorCumulative = jsonDictionary["onVentilatorCumulative"] as? Int
            self.recovered = jsonDictionary["recovered"] as? Int
            self.hash = jsonDictionary["hash"] as? String ?? ""
            self.lastModified = jsonDictionary["lastModified"] as? String ?? ""
            self.death = jsonDictionary["death"] as? Int
            self.totalTestResults = jsonDictionary["totalTestResults"] as? Int
            self.dataQualityGrade = jsonDictionary["dataQualityGrade"] as? String ?? ""
        }
        
        func valueForMetric(_ selectedMetric: String ) -> Int? {
             var metric : Int?
             switch selectedMetric {
             case CTClient.Metrics.Deaths:
                 metric = self.death
                 break
             case CTClient.Metrics.CurrentVentilators:
                 metric = self.onVentilatorCurrently
                 break
             case CTClient.Metrics.CumulativeVentilators:
                 metric = self.onVentilatorCumulative
                 break
             case CTClient.Metrics.CurrentICUs:
                 metric = self.inIcuCurrently
                 break
             case CTClient.Metrics.CumulativeICUs:
                 metric = self.inIcuCumulative
                 break
             case CTClient.Metrics.CurrentHospitalizations:
                 metric = self.hospitalizedCurrently
                 break
             case CTClient.Metrics.CumulativeHospitalizations:
                 metric = self.hospitalizedCumulative
                 break
             case CTClient.Metrics.Positives:
                 metric = self.positive
                 break
             default:
                 print("In default case!")
                 break
             }
             return metric
         }
    }
}
