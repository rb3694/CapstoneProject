//
//  ViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 5/26/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    lazy var geocoder = CLGeocoder()
    var annotations = [MKPointAnnotation]()
    var ctData: [String:CTClient.CTData] = [:]

    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate func createAnnotation(_ stateData: CTClient.CTData) {
        // print( stateData.state + " deaths: \(stateData.death)" )
        self.ctData[stateData.state] = stateData
        let annotation = MKPointAnnotation()
        annotation.title = stateData.state
        annotation.subtitle = "\(stateData.death) deaths"
        if let coordinate = CTClient.GeoCenters.States[stateData.state] {
            annotation.coordinate = coordinate
            // print( "Setting location coordinates to (\(coordinate.latitude), \(coordinate.longitude))")
        } else {
            print( "!!! Unable to find geographic center for \(stateData.state) !!!" )
        }
        self.annotations.append( annotation )
        performUIUpdatesOnMain {
            self.mapView.addAnnotation( annotation )
        }
        print( "Location \(annotation.title ?? "") with \(annotation.subtitle ?? "")")
        // self.mapView.showAnnotations(annotations, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the current data for all 50 states plus 6 territories of the US
        CTClient.sharedInstance().getCurrentData() { ( result, error ) in
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
            } else {
                // print( "Success!" )
                let theData = result as! [AnyObject]
                for x in 0..<theData.count {
                    let stateData = CTClient.CTData( theData[x] as! [String : AnyObject] )
                    self.createAnnotation(stateData)
                    // print( "There are now \(self.annotations.count) annotations" )
                }
            }
        }
        
        // Get the aggregate data for the entire US
        CTClient.sharedInstance().getCurrentData( "US" ) { ( result, error ) in
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
            } else {
                // print( "Success!" )
                var theData: [String:AnyObject]
                    theData = (result?[0] ?? [:]) as! [String:AnyObject]
                let stateData = CTClient.CTData( theData )
                self.createAnnotation( stateData )
                // print("There are now \(self.annotations.count) annotations (US)")
            }
        }

            /*--------------------------------------------------------------------------------
             * This is how I originally tried to get the coordinates for all of the states,
             * but apparently the geocoder shuts down with error 2 (network error) if you
             * try to do more than 50 forward geocode requests in quick succession.  It's also
             * super slow.  So I came up with the GeoCenters dictionary instead.
             ---------------------------------------------------------------------------------
            if self.annotations.count > 0 {
                // Process the first annotation location name to convert it to coordinates.
                // The completionHandler will process the next annotations in succession.
                var state = self.annotations[0].title ?? ""
                if state.uppercased() != "US" {
                    state = state.uppercased() + ", US"
                }
                self.geocoder.geocodeAddressString( state ) { ( placemarks, error ) in
                    self.processGeocodeResponse( index: 0, withPlacemarks: placemarks, error: error )
                }
            }
            ----------------------------------------------------------------------------------- */
    }
    
    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        let reuseId = "statePin"
        let usReuseId = "usMarker"
        let state = annotation.title as? String ?? ""
        let stateData = ctData[state]
            
        let deaths = stateData?.death ?? 0
        // print( "Pin for \(state) represents \(deaths) deaths" )
        var color = UIColor.red
        if deaths < 10 {
            color = .green
        } else if deaths < 50 {
            color = .cyan
        } else if deaths < 100 {
            color = .blue
        } else if deaths < 500 {
            color = .purple
        } else if deaths < 1000 {
            color = .magenta
        } else if deaths < 5000 {
            color = .yellow
        } else if deaths < 10000 {
            color = .orange
        }

        if ( annotation.title == "US" )
        {
            //print( "Found the US marker" )
            // We want the US pin to stand out, so we use a marker instead of a pin
            var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: usReuseId ) as? MKMarkerAnnotationView
            if markerView == nil {
                //print( "No view for US marker - creating one" )
                markerView = MKMarkerAnnotationView( annotation: annotation, reuseIdentifier: usReuseId )
                markerView!.canShowCallout = true
                markerView!.rightCalloutAccessoryView = UIButton( type: .detailDisclosure )
                markerView!.clusteringIdentifier = usReuseId
            } else {
                print( "Reusing MKMarkerAnnotationView for US marker" )
                markerView!.annotation = annotation
            }
            markerView!.markerTintColor = color
            markerView!.displayPriority = .required
            return markerView
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.clusteringIdentifier = reuseId
        } else {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = color

        return pinView
    }

    fileprivate func geocodeNextAnnotation(_ index: Int) {
        // Geocoder should be free now, get the next state's geographic center.
        let x = index + 1
        if x < annotations.count {
            var newState = annotations[x].title ?? ""
            if ( newState.uppercased() != "US" )
            {
                newState = newState + ", US"
            }
            print( "Attempting to geocode address \(x), '\(newState)")
            self.geocoder.geocodeAddressString( newState ) { ( placemarks, error ) in
                self.processGeocodeResponse( index: x, withPlacemarks: placemarks, error: error )
            }
        }
    }
    
    private func processGeocodeResponse( index: Int, withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {

        let annotation = self.annotations[index]
        let state = annotation.title ?? ""
        
        if let error = error {
            performUIUpdatesOnMain {
                //self.locationField.text = "Unable to Find Coordinates for Location"
                print("Unable to Forward Geocode Address \(index), '\(state)': (\(error))")
            }
            geocodeNextAnnotation( index )
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                if let placemark = placemarks.first {
                    location = placemark.location
                    print( "Setting annotation title to \(state), " )
                    print( "                   subtitle to \(String(describing: placemark.locality))" )
                    annotation.subtitle = placemark.locality
                    annotation.title = state
                } else {
                    print( "placemarks.count was 0 or placemarks was nil for \(state)" )
                }
            }

            if let location = location {
                // Successfully translated address string to map coordinates.
                // Create an annotation for the map at that position.
                print( "Adding annotation for \(state)" )
                let locCoordinate = location.coordinate
                let coordinate = CLLocationCoordinate2D( latitude: locCoordinate.latitude, longitude: locCoordinate.longitude )
                annotation.coordinate = coordinate
                print( "Setting location coordinates to (\(coordinate.latitude), \(coordinate.longitude))")
                performUIUpdatesOnMain {
                    self.mapView.addAnnotation(annotation);
                }
            } else {
                //performUIUpdatesOnMain {
                print( "No Matching Location Found for \(state)" );
                //}
            }
            
            geocodeNextAnnotation(index)
            
        }
    }

}

