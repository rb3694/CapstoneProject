//
//  StateTableTableViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/3/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit

class StateTableTableViewController: UITableViewController {
    let reuseIdentifier = "StateTableCell"
    
    let stateAbbreviations = [ "United States": "US",
                               "Alabama": "AL", "Alaska": "AK", "American Samoa": "AS",
                               "Arizona": "AZ", "Arkansas": "AR", "California": "CA",
                               "Colorado": "CO", "Connecticut": "CT", "Deleware": "DE",
                               "District of Columbia": "DC", "Florida": "FL", "Georgia": "GA",
                               "Guam": "GU", "Hawaii": "HI", "Idaho": "ID",
                               "Illinois": "IL", "Indiana": "IN", "Iowa": "IA",
                               "Kansas": "KS", "Kentucky": "KY", "Louisiana": "LA",
                               "Maine": "ME", "Maryland": "MD", "Massachusetts": "MA",
                               "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
                               "Missouri": "MO", "Montana": "MT", "Nebraska": "NE",
                               "Nevada": "NV", "New Hampshire": "NH", "New Jersey": "NJ",
                               "New Mexico": "NM", "New York": "NY", "North Carolina": "NC",
                               "North Dakota": "ND", "Northern Mariana Islands": "MP",
                               "Ohio": "OH", "Oklahoma": "OK", "Oregon": "OR",
                               "Pennsylvania": "PA", "Puerto Rico": "PR", "Rhode Island": "RI",
                               "South Carolina": "SC", "South Dakota": "SD", "Tennessee": "TN",
                               "Texas": "TX", "US Virgin Islands": "VI", "Utah": "UT",
                               "Vermont": "VT", "Virginia": "VA", "Washington": "WA",
                               "West Virginia": "WV", "Wisconsin": "WI", "Wyoming": "WY"
                             ]
    var stateNames: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateNames = stateAbbreviations.keys.sorted()
        
        // Lets put the entire country first in the list, instead of
        // alphabetically sorted in with all of the states and territories
        var x = 0
        while x < stateNames.count {
            if stateNames[x] == "United States" {
                stateNames.remove( at: x )
                x = stateNames.count
            } else {
                x += 1
            }
        }
        stateNames.insert( "United States", at: 0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let stateName = stateNames[indexPath.row]
        cell.textLabel?.text = stateName
        cell.detailTextLabel?.text = stateAbbreviations[stateName]

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stateName = stateNames[indexPath.row]
        let vc = (storyboard!.instantiateViewController(withIdentifier: "StatsTableViewController") as? StatsTableViewController)!
        vc.selectedState = stateAbbreviations[stateName]
        self.navigationController!.pushViewController( vc, animated: true)
        return

    }

}
