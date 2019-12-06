//
//  DetailViewController.swift
//  CityWeatherApp
//
//  Created by Apple on 10/29/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    private var _weatherResponseData: WeatherResponseData? = nil
    private var _searchLocationResponseData: SearchLocationResponseData? = nil
    private var _currentWeatherImage: UIImage? = nil
    private var _currentIndex = 0
    
    @IBOutlet weak var detailTitle: UINavigationItem!
    @IBOutlet weak var imgWeatherState: UIImageView!
    @IBOutlet weak var lblWeatherState: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblWind: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblAirPressure: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnShowMap: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cityName = detailItem {
            detailTitle.title = cityName
            FetchHelper.getLocationIdByCityName(cityName) { locationId in
                FetchHelper.getWeatherData(locationId) { data in
                    self._weatherResponseData = data
                    FetchHelper.getWeatherImage(data, self._currentIndex) { image in
                        self._currentWeatherImage = image
                        DispatchQueue.main.async {
                            self.updateView(self._currentIndex)
                        }
                    }
                }
            }
        }
    }

    var detailItem: String? { didSet { } }
    
    private func updateView(_ index: Int) {
        guard let weatherResponseData = _weatherResponseData, let currentWeatherImage = _currentWeatherImage else { return }
        
        self.lblDate.text = weatherResponseData.consolidatedWeather[index].applicableDate
        self.lblWeatherState.text = weatherResponseData.consolidatedWeather[index].weatherStateName
        self.lblTemperature.text = "from \(Int(round(weatherResponseData.consolidatedWeather[index].minTemp!)))°C to \(Int(round(weatherResponseData.consolidatedWeather[index].maxTemp!)))°C"
        self.lblWind.text = "\(Int(round(weatherResponseData.consolidatedWeather[index].windSpeed!))) mph \(weatherResponseData.consolidatedWeather[index].windDirectionCompass)"
        self.lblHumidity.text = "\(weatherResponseData.consolidatedWeather[index].humidity!)%"
        self.lblAirPressure.text = "\(Int(round(weatherResponseData.consolidatedWeather[index].airPressure!))) hPa"
        self.imgWeatherState.image = currentWeatherImage
    }
    
    @IBAction func onPreviousBtnClick(_ sender: UIButton) {
        guard let weatherResponseData = _weatherResponseData else { return }
        
        _currentIndex -= 1
        btnNext.isEnabled = true
        
        FetchHelper.getWeatherImage(weatherResponseData, _currentIndex) { image in
            self._currentWeatherImage = image
            DispatchQueue.main.async {
                self.updateView(self._currentIndex)
            }
        }
        
        if _currentIndex == 0 {
            btnPrevious.isEnabled = false
        }
    }
    
    @IBAction func onNextBtnClick(_ sender: UIButton) {
        guard let weatherResponseData = _weatherResponseData else { return }
        
        _currentIndex += 1
        btnPrevious.isEnabled = true
        
        FetchHelper.getWeatherImage(weatherResponseData, _currentIndex) { image in
            self._currentWeatherImage = image
            DispatchQueue.main.async {
                self.updateView(self._currentIndex)
            }
        }
        
        if _currentIndex + 1 == weatherResponseData.consolidatedWeather.count {
            btnNext.isEnabled = false
        }
    }
    
    @IBAction func onShowMapBtnClick(_ sender: UIButton) {
        guard let city = detailTitle.title else { return }
        Storage.shared.cityToShowOnMap = city
        
        performSegue(withIdentifier: "showMap", sender: self)
    }
}

