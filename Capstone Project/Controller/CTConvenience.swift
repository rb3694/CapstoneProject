//
//  CTConvenience.swift
//  Capstone Project
//
//  Created by Robert Busby on 5/26/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation

extension CTClient {
    
    // Use CovidTracker API to retrieve some data
    func getCurrentData(_ state: String? = nil, completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) {
        _ = CTClient.sharedInstance().httpTask( state: state, method: "current" ) {
            (results, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                guard results != nil else {
                    completionHandler( nil,
                                       NSError( domain: "currentData", code: 100,
                                                userInfo: [NSLocalizedDescriptionKey: "No Results"]
                                              )
                                     )
                    return
                }
                completionHandler( results, nil )
            }
        }
    }
      
    func getHistoricalData(_ state: String, completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) {
        _ = CTClient.sharedInstance().httpTask( state: state, method: "daily" ) {
            (results, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                guard results != nil else {
                    completionHandler( nil,
                                       NSError( domain: "dailyData", code: 100,
                                                userInfo: [NSLocalizedDescriptionKey: "No Results"]
                                              )
                                     )
                    return
                }
                completionHandler( results, nil )
            }
        }
    }

}
