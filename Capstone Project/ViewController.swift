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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var metricTextField: UITextField!
    
    fileprivate func createAnnotation(_ stateData: CTClient.CTData) {
        // print( stateData.state + " deaths: \(stateData.death)" )
        let annotation = MKPointAnnotation()
        let metric = valueForSelectedMetric(ctData: stateData)
        annotation.title = stateData.state
        annotation.subtitle = "\(metric) \(selectedMetric)"
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
        metricPicker.dataSource = self
        metricPicker.delegate = self
        metricTextField.inputView = metricPicker
        
        print( "Map Range: (\(mapView.region.span.latitudeDelta),\(mapView.region.span.longitudeDelta))" )
        /*
        let mapCenter = CLLocationCoordinate2D( latitude: UserDefaults.standard.double(forKey: CTClient.Defaults.MapCenterLatitude ), longitude: UserDefaults.standard.double(forKey: CTClient.Defaults.MapCenterLongitude) )
        let mapSpan = MKCoordinateSpan( latitudeDelta: UserDefaults.standard.double(forKey: CTClient.Defaults.MapLatDelta), longitudeDelta: UserDefaults.standard.double(forKey: CTClient.Defaults.MapLongDelta) )
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        selectedMetric = UserDefaults.standard.string(forKey: CTClient.Defaults.Metric);
        */
        
        metricTextField.text = selectedMetric

        // Get the current data for all 50 states plus 6 territories of the US
        CTClient.sharedInstance().getCurrentData() { ( result, error ) in
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
        CTClient.sharedInstance().getCurrentData( "US" ) { ( result, error ) in
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
        print( "Selected metric is now '\(selectedMetric)'" )
        reloadAnnotations()
    }
    
    func valueForSelectedMetric( ctData: CTClient.CTData) -> Int {
        switch selectedMetric {
        case CTClient.Metrics.Deaths:
            return ctData.death
        case CTClient.Metrics.CurrentVentilators:
            return ctData.onVentilatorCurrently
        case CTClient.Metrics.CumulativeVentilators:
            return ctData.onVentilatorCumulative
        case CTClient.Metrics.CurrentICUs:
            return ctData.inIcuCurrently
        case CTClient.Metrics.CumulativeICUs:
            return ctData.inIcuCumulative
        case CTClient.Metrics.CurrentHospitalizations:
            return ctData.hospitalizedCurrently
        case CTClient.Metrics.CumulativeHospitalizations:
            return ctData.hospitalizedCumulative
        case CTClient.Metrics.Positives:
            return ctData.positive
        default:
            return 0
        }
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
            
        let metric = valueForSelectedMetric(ctData: stateData)
        let metricMagnitude = magnitudeForSelectedMetric(ctData: stateData)

        var color = UIColor.red
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
    
    // This delegate method is implemented to respond to taps. It finds the
    // annotation in the pin list, and transitions to the LineChartView
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let selectedAnnotation = view.annotation as? MKPointAnnotation
            mapView.deselectAnnotation( view.annotation, animated: true )
            selectedState = selectedAnnotation?.title
            //performSegue( withIdentifier: segueID, sender: self )
            let vc = (storyboard!.instantiateViewController(withIdentifier: "LineChartViewController") as? LineChartViewController)!
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
    
    // MARK: - Navigation

    // Set up the context to share with the PhotoAlbum view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            let vc = segue.destination as! LineChartViewController
            vc.selectedState = selectedState
            vc.selectedMetric = selectedMetric
        }
    }

}

