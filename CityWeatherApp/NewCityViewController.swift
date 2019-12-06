//
//  NewCityView.swift
//  CityWeatherApp
//
//  Created by Apple on 11/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import CoreLocation

class NewCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var tableViewCities: UITableView!
    @IBOutlet weak var lblCity: UILabel!
    
    private var _foundCities = [String]()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                get10ClosestCitiesFromCurrentLocation()
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .denied:
                print("denied")
                break
            case .restricted:
                print("restricted")
                break
            case .authorizedAlways:
                print("authorized always")
                break
        }
    }
    
    func getCurrentPlace(completion: @escaping (CLPlacemark?) -> Void) {
        guard let location = locationManager.location else { return }

        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
    
    func get10ClosestCitiesFromCurrentLocation() {
        getCurrentPlace() { placemark in
            guard let placemark = placemark, let location = self.locationManager.location else { return }
            
            if let town = placemark.locality, let country = placemark.country {
                self.lblCity.text = "Your current location is \(town), \(country)"
                
                FetchHelper.get10ClosestCitiesFromSpecifiedLattLong(location.coordinate.latitude, location.coordinate.longitude) { responseData in
                    self._foundCities = [String]()
                    for data in responseData {
                        self._foundCities.append(data.title)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableViewCities.reloadData()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _foundCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        cell.textLabel!.text = _foundCities[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Storage.shared.cities.append(_foundCities[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSearchBtnClick(_ sender: UIButton) {
        guard let city = txtCity.text else { return }

        let locationUrl = URL(string: MetaWeather.API_URL + MetaWeather.LOCATION_ID_SEARCH_ENDPOINT + city.replacingOccurrences(of: " ", with: "+"))
        
        let task = URLSession.shared.dataTask(with: locationUrl!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try jsonDecoder.decode([SearchLocationResponseData].self, from: data)
                
                self._foundCities = [String]()
                for searchLocationResponseData in decodedData {
                    self._foundCities.append(searchLocationResponseData.title)
                }
                
                DispatchQueue.main.async {
                    self.tableViewCities.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    @IBAction func onCancelBtnClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
     }
}

extension NewCityViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkLocationAuthorization()
    }
}
