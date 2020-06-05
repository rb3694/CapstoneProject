//
//  StatsTableViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/3/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController {
    let reuseIdentifier = "StatsTableCell"
    var selectedState: String?
    var ctData: CTClient.CTData?

    var statNames = [ "State",
                      CTClient.Metrics.Deaths,
                      CTClient.Metrics.CurrentVentilators,
                      CTClient.Metrics.CumulativeVentilators,
                      CTClient.Metrics.CurrentICUs,
                      CTClient.Metrics.CumulativeICUs,
                      CTClient.Metrics.CurrentHospitalizations,
                      CTClient.Metrics.CumulativeHospitalizations,
                      CTClient.Metrics.Positives
                    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current data for the selected state
        CTClient.sharedInstance().getCurrentData( selectedState ) { ( result, error ) in
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
            } else {
                var theData: [String:AnyObject]
                if self.selectedState == "US" {
                    theData = (result?[0] ?? [:]) as! [String:AnyObject]
                } else {
                    theData = result as! [String:AnyObject]
                }
                let stateData = CTClient.CTData( theData )
                self.ctData = stateData
            }
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let statName = statNames[indexPath.row]
        cell.textLabel?.text = statName + ":"
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)

        if statName == "State" {
            cell.detailTextLabel?.text = CTClient.States.Names[selectedState ?? "Unknown"]
        } else {
            let statValue = ctData?.valueForMetric( statName )
            if let statValue = statValue {
                cell.detailTextLabel?.text = "\(statValue)"
            } else {
              cell.detailTextLabel?.text = "(Not Reported)"
            }
        }

        return cell
    }

}
