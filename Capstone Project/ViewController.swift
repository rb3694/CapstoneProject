//
//  ViewController.swift
//  Capstone Project
//
//  Created by Robert Busby on 5/26/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    lazy var geocoder = CLGeocoder()
    var annotations = [MKPointAnnotation]()
    var ctData: [String:CTClient.CTData] = [:]
    let segueID = "MapToChartSegue"
    var selectedState : String?
    var selectedMetric = CTClient.Metrics.Deaths
    var metricPicker = UIPickerView()
    var dataController : DataController!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var metricTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate func createAnnotation(_ stateData: CTClient.CTData) {
        let annotation = MKPointAnnotation()
        let metric = stateData.valueForMetric( selectedMetric )
        annotation.title = stateData.state
        if let metric = metric {
            annotation.subtitle = "\(metric) \(selectedMetric)"
        } else {
            annotation.subtitle = "\(selectedMetric) Not Reported"
        }
        if let coordinate = CTClient.States.GeoCenters[stateData.state] {
            annotation.coordinate = coordinate
        } else {
            print( "!!! Unable to find geographic center for \(stateData.state) !!!" )
        }
        self.annotations.append( annotation )
        performUIUpdatesOnMain {
            self.mapView.addAnnotation( annotation )
        }
    }
    
    func reloadAnnotations()
    {
        mapView.removeAnnotations( annotations)
        annotations.removeAll()
        for stateData in ctData.values {
            createAnnotation( stateData )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        let mapCenter = CLLocationCoordinate2D( latitude: UserDefaults.standard.double(forKey: CTClient.Defaults.MapCenterLatitude ), longitude: UserDefaults.standard.double(forKey: CTClient.Defaults.MapCenterLongitude) )
        let mapSpan = MKCoordinateSpan( latitudeDelta: UserDefaults.standard.double(forKey: CTClient.Defaults.MapLatDelta), longitudeDelta: UserDefaults.standard.double(forKey: CTClient.Defaults.MapLongDelta) )
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        selectedMetric = UserDefaults.standard.string(forKey: CTClient.Defaults.Metric) ?? CTClient.Metrics.Deaths
        
        metricTextField.text = selectedMetric
        metricPicker.dataSource = self
        metricPicker.delegate = self
        var row = 0
        while row < CTClient.Metrics.metricsList.count && CTClient.Metrics.metricsList[row] != selectedMetric {
            row += 1
        }
        metricPicker.selectRow( row, inComponent: 0, animated: false )
        metricTextField.inputView = metricPicker

        // Get the current data for all 50 states plus 6 territories of the US
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        CTClient.sharedInstance().getCurrentData() { ( result, error ) in
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
            } else {
                let theData = result as! [AnyObject]
                for x in 0..<theData.count {
                    let stateData = CTClient.CTData( theData[x] as! [String : AnyObject] )
                    self.ctData[stateData.state] = stateData
                    self.createAnnotation(stateData)
                }
            }
        }
        
        // Get the aggregate data for the entire US
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        CTClient.sharedInstance().getCurrentData( "US" ) { ( result, error ) in
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            if error != nil {
                print( "ERROR: \(String(describing: error))" )
            } else {
                var theData: [String:AnyObject]
                theData = (result?[0] ?? [:]) as! [String:AnyObject]
                let stateData = CTClient.CTData( theData )
                self.ctData[stateData.state] = stateData
                self.createAnnotation( stateData )
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
    
    // MARK: - PickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CTClient.Metrics.metricsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CTClient.Metrics.metricsList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMetric = CTClient.Metrics.metricsList[row]
        metricTextField.text = selectedMetric
        self.view.endEditing(true)

        UserDefaults.standard.set( selectedMetric, forKey: CTClient.Defaults.Metric )
        reloadAnnotations()
    }
    
    func magnitudeForSelectedMetric( ctData: CTClient.CTData) -> Int {
        switch selectedMetric {
        case CTClient.Metrics.Deaths:
            return 10000
        case CTClient.Metrics.CurrentVentilators:
            return 1500
        case CTClient.Metrics.CumulativeVentilators:
            return 5000
        case CTClient.Metrics.CurrentICUs:
            return 1500
        case CTClient.Metrics.CumulativeICUs:
            return 5000
        case CTClient.Metrics.CurrentHospitalizations:
            return 5000
        case CTClient.Metrics.CumulativeHospitalizations:
            return 10000
        case CTClient.Metrics.Positives:
            return 50000
        default:
            return 0
        }
    }


    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool ) {
        // Remember the map center and zoom level - store in user defaults
        UserDefaults.standard.set( mapView.region.center.latitude, forKey: CTClient.Defaults.MapCenterLatitude)
        UserDefaults.standard.set( mapView.region.center.longitude, forKey: CTClient.Defaults.MapCenterLongitude)
        UserDefaults.standard.set( mapView.region.span.latitudeDelta, forKey: CTClient.Defaults.MapLatDelta )
        UserDefaults.standard.set( mapView.region.span.longitudeDelta, forKey: CTClient.Defaults.MapLongDelta )
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        let reuseId = "statePin"
        let usReuseId = "usMarker"
        let state = annotation.title as? String ?? ""
        let stateData = ctData[state]!
            
        let metric = stateData.valueForMetric(selectedMetric)
        let metricMagnitude = magnitudeForSelectedMetric(ctData: stateData)

        var color = UIColor.clear
        if let metric = metric {
            if metric < metricMagnitude / 1000 {
                color = .green
            } else if metric < metricMagnitude / 200 {
                color = .cyan
            } else if metric < metricMagnitude / 100 {
                color = .blue
            } else if metric < metricMagnitude / 20 {
                color = .purple
            } else if metric < metricMagnitude / 10 {
                color = .magenta
            } else if metric < metricMagnitude / 2 {
                color = .yellow
            } else if metric < metricMagnitude {
                color = .orange
            } else {
                color = .red
            }
        }

        if ( annotation.title == "US" )
        {
            // We want the US pin to stand out, so we use a marker instead of a pin
            var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: usReuseId ) as? MKMarkerAnnotationView
            if markerView == nil {
                markerView = MKMarkerAnnotationView( annotation: annotation, reuseIdentifier: usReuseId )
                markerView!.canShowCallout = true
                markerView!.rightCalloutAccessoryView = UIButton( type: .detailDisclosure )
                // I keep getting mysterious, random crashes with error message
                // -[MKPointAnnotation memberAnnotations]: unrecognized selector sent to instance
                // So I'm going to disable clustering to try to avoid them.  See here and below.
                // markerView!.clusteringIdentifier = usReuseId
                markerView!.clusteringIdentifier = nil
            } else {
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
            // I keep getting mysterious, random crashes with error message
            // -[MKPointAnnotation memberAnnotations]: unrecognized selector sent to instance
            // So I'm going to disable clustering to try to avoid them.  See here and above.
            // (I don't really want clustering anyway, can't click on clustered pin to get a graph)
            // pinView!.clusteringIdentifier = reuseId
            pinView!.clusteringIdentifier = nil
        } else {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = color

        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It finds the
    // annotation in the pin list, and transitions to the LineChartView
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let selectedAnnotation = view.annotation as? MKPointAnnotation
            mapView.deselectAnnotation( view.annotation, animated: true )
            guard let stateData = ctData[selectedAnnotation?.title ?? "XX"] else {
                print("Can't find state data for map pin tap!")
                return
            }
            if stateData.valueForMetric(selectedMetric) == nil {
                // No need to draw graphs for metrics that aren't reported.
                return
            }
            selectedState = selectedAnnotation?.title
            let vc = (storyboard!.instantiateViewController(withIdentifier: "ComboChartViewController") as? ComboChartViewController)!
            vc.dataController = dataController
            vc.selectedState = selectedState
            vc.selectedMetric = selectedMetric
            self.navigationController!.pushViewController( vc, animated: true)
            return
        }
        print( "###### ERROR: Unable to find selected pin!" )
    }

    
    // MARK:  GEOCODING (no longer used)

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

