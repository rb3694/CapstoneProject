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
    let stateNames = [  "US": "United States",
                        "AL": "Alabama", "AK": "Alaska", "AS": "American Samoa",
                        "AZ": "Arizona", "AR": "Arkansas", "CA": "California",
                        "CO": "Colorado", "CT": "Connecticut", "DE": "Deleware",
                        "DC": "District of Columbia", "FL": "Florida", "GA": "Georgia",
                        "GU": "Guam", "HI": "Hawaii", "ID": "Idaho",
                        "IL": "Illinois", "IN": "Indiana", "IA": "Iowa",
                        "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana",
                        "ME": "Maine", "MD": "Maryland", "MA": "Massachusetts",
                        "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
                        "MO": "Missouri", "MT": "Montana", "NE": "Nebraska",
                        "NV": "Nevada", "NH": "New Hampshire", "NJ": "New Jersey",
                        "NM": "New Mexico", "NY": "New York", "NC": "North Carolina",
                        "ND": "North Dakota", "MP": "Northern Mariana Islands",
                        "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon",
                        "PA": "Pennsylvania", "PR": "Puerto Rico", "RI": "Rhode Island",
                        "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee",
                        "TX": "Texas", "VI": "US Virgin Islands", "UT": "Utah",
                        "VT": "Vermont", "VA": "Virginia", "WA": "Washington",
                        "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"
                     ]

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
            cell.detailTextLabel?.text = stateNames[selectedState ?? "Unknown"]
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
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
