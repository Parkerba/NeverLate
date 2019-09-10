//
//  MapView.swift
//  Never Late
//
//  Created by parker amundsen on 8/3/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
protocol locationReciever {
    func recieveEventLocation(placemark: MKPlacemark?)
}

class MapView: UIViewController, MKMapViewDelegate {
    var delegate: locationReciever?
    
    // An array of localSearchCompletion to populate searchSuggestion
    var results : [MKLocalSearchCompletion]? = nil
    
    let locationManager =  CLLocationManager()
    
    // User searches to add location
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.layer.cornerRadius = 10
        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = UISearchBar.Style(rawValue: 2)!
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    let backButton: UIButton = {
        let backButton = UIButton();
        backButton.setTitle("Back", for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.7960784314, blue: 0.8705882353, alpha: 1)
        backButton.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
        
        return backButton;
    }()
    
    
    
    // TableView to give the user suggestions based on the text typed in the searchBar
    let searchSuggestion: UITableView = {
        let searchResults = UITableView()
        searchResults.isHidden = true
        searchResults.layer.opacity = 0.8
        searchResults.backgroundColor = .clear
        searchResults.translatesAutoresizingMaskIntoConstraints = false
        searchResults.register(UITableViewCell.self, forCellReuseIdentifier: "searchSuggestion")
        return searchResults
    }()
    
    // searchCompleter populates the results array with suggested
    // locations based on the text inputted by the user
    let searchCompleter : MKLocalSearchCompleter =  {
        let completer = MKLocalSearchCompleter()
        return completer
    }()

    let map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(map)
        view.addSubview(backButton)
        view.addSubview(searchBar)
        view.addSubview(searchSuggestion)
        searchBar.delegate = self
        map.delegate = self
        searchSuggestion.dataSource = self
        searchSuggestion.delegate = self
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationServices()
    }
    
    func setUpUI() {
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        map.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: view.frame.width/10)
        backButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        searchSuggestion.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchSuggestion.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchSuggestion.heightAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
        searchSuggestion.widthAnchor.constraint(equalToConstant: view.frame.width*0.9).isActive = true
        searchSuggestion.rowHeight = view.frame.height/10
        
    }
    
    
    
        
        
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerViewOnUser()
            break
        case .denied:
            let alert  =  UIAlertController(title: "Location Services are not enabled",
                        message: "place go to: \n Settings->Privacy->Location Services\n and enable for NeverLate",
                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            centerViewOnUser()
            break
        @unknown default:
            return
        }
    }
    
    func checkLocationServices() {
        if (CLLocationManager.locationServicesEnabled()) {
            setUpLocationManager()
            checkAuthorization()
        } else {
            
        }
    }
    
    // This will center the map on the users location
    func centerViewOnUser() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(region, animated: true)
        }
    }
    
    // Given a placemarker this will center the map on the placemarker
    func centerViewOnPlaceMarker(placeMarker: MKPlacemark) {
        let region = MKCoordinateRegion.init(center: placeMarker.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        map.addAnnotation(placeMarker)
    }
    
    
    
    
}

extension MapView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print ("editing")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.region = MKCoordinateRegion.init(center: map.centerCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        searchCompleter.queryFragment = searchBar.text!
        results = searchCompleter.results
        if (results != nil && results!.count > 0) {
            searchSuggestion.isHidden = false
        } else {
            if !searchSuggestion.isHidden {
                searchSuggestion.isHidden = true
            }
        }
        searchSuggestion.reloadData()
    }
    
    // function called when teh search button on the keyboard is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if (results == nil || results!.count == 0) {
            let invalidAddress = UIAlertController(title: "Invalid Location", message: "The location you searched for cannot be found please try again", preferredStyle: .alert)
            invalidAddress.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(invalidAddress, animated: true, completion: nil)
        }
        else {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchBar.text!
            searchRequest.region = searchCompleter.region
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard let response = response else {
                    print ("Error")
                    return
                }
                self.centerViewOnPlaceMarker(placeMarker: response.mapItems[0].placemark)
                self.searchSuggestion.isHidden = true
                for item in response.mapItems {
                    print ("\(String(describing: item.name)) \(String(describing: item.phoneNumber))")
                }
                
            }
        }
    }
    
    @objc func onBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
}





extension MapView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
    }
}

extension MapView: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    
}

extension MapView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let size = 5
        return size
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchSuggestion", for: indexPath)
        cell.backgroundColor = .white
        if (indexPath.row < results?.count ?? 0) {
            cell.textLabel?.text = " \(results![indexPath.row].title) \n \(results![indexPath.row].subtitle)"
        }
        else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = results?[indexPath.row].title ?? searchBar.text
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let placeMarker = view.annotation as! MKPlacemark
        delegate?.recieveEventLocation(placemark: placeMarker)
        self.dismiss(animated: true, completion: nil)
    }
    
}
