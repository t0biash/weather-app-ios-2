//
//  NewCityView.swift
//  CityWeatherApp
//
//  Created by Apple on 11/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class NewCityView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var tableViewCities: UITableView!
    
    private var _foundCities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
