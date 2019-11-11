//
//  MetaWeather.swift
//  CityWeatherApp
//
//  Created by Rafał on 10/11/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

struct MetaWeather {
    static let API_URL = "https://www.metaweather.com/"
    static let LOCATION_ENDPOINT =  "api/location/"
    static let WEATHER_STATE_IMG_ENDPOINT = "static/img/weather/png/64/"
    static let LOCATION_ID_SEARCH_ENDPOINT = "api/location/search/?query="
}

struct WeatherResponseData:  Codable {
    struct Weather: Codable {
        let airPressure: Float?
        let applicableDate: String
        let humidity: Int?
        let maxTemp: Float?
        let minTemp: Float?
        let theTemp: Float?
        let weatherStateAbbr: String
        let weatherStateName: String
        let windDirectionCompass: String
        let windSpeed: Float?
    }
    
    let consolidatedWeather: [Weather]
}

struct SearchLocationResponseData: Codable {
    let title: String
    let woeid: Int
}

class FetchHelper {
    static func getLocationIdByCityName(_ cityName: String, completion: @escaping (Int)->()) {
        guard let searchLocationUrl = URL(string: MetaWeather.API_URL + MetaWeather.LOCATION_ID_SEARCH_ENDPOINT + cityName.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
    
        let task = URLSession.shared.dataTask(with: searchLocationUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try jsonDecoder.decode([SearchLocationResponseData].self, from: data)
                
                return completion(decodedData[0].woeid)
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    static func getWeatherData(_ locationId: Int, completion: @escaping (WeatherResponseData)->()) {
        guard let weatherUrl = URL(string: MetaWeather.API_URL + MetaWeather.LOCATION_ENDPOINT + "\(locationId)") else { return }
        
        let task = URLSession.shared.dataTask(with: weatherUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try jsonDecoder.decode(WeatherResponseData.self, from: data)
        
                return completion(decodedData)
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    static func getWeatherImage(_ weatherResponseData: WeatherResponseData, _ index: Int, completion: @escaping (UIImage)->()) {
        guard let weatherImageUrl = URL(string: MetaWeather.API_URL + MetaWeather.WEATHER_STATE_IMG_ENDPOINT +  weatherResponseData.consolidatedWeather[index].weatherStateAbbr + ".png") else { return }
        
        let task = URLSession.shared.dataTask(with: weatherImageUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            
            return completion(UIImage(data: data)!)
        }
        task.resume()
    }
}
