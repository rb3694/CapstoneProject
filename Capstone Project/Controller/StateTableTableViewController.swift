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
    
    var stateNames: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateNames = CTClient.States.Abbreviations.keys.sorted()
        
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
        cell.detailTextLabel?.text = CTClient.States.Abbreviations[stateName]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stateName = stateNames[indexPath.row]
        let vc = (storyboard!.instantiateViewController(withIdentifier: "StatsTableViewController") as? StatsTableViewController)!
        vc.selectedState = CTClient.States.Abbreviations[stateName]
        self.navigationController!.pushViewController( vc, animated: true)
        return

    }

}
