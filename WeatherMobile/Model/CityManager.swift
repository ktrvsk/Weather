//
//  CityManager.swift
//  WeatherMobile
//
//  Created by Ksusha on 13.04.2022.
//

import Foundation

struct Cities {
    var nameCity: String
    var conditionId: String
    var temperature: String
}

protocol CitiesManagerDelegate {
    func didUpdateWeather(_ weatherManger: WeatherManager, city: WeatherModel)
    func didFailWithError(error: Error)
}

protocol CityStorageProtocol {
    func load() -> [WeatherModel]
    func save(cities: [WeatherModel])
}

class CityStorage: CityStorageProtocol {
 
    private var storage = UserDefaults.standard
    private var storageKey = "city"
    
    private enum Citykey: String {
        case name
        case temperature
        case conditionId
    }
    
    func load() -> [WeatherModel] {
        
        var resultCities: [WeatherModel] = []
        let citiesFromStorage = storage.array(forKey: storageKey) as?
        [[String:String]] ?? []
        for city in citiesFromStorage {
            guard let name = city[Citykey.name.rawValue],
                  let temperature = city[Citykey.temperature.rawValue],
                  let conditionalId = city[Citykey.conditionId.rawValue]
            else {
                continue
            }
            resultCities.append(WeatherModel(conditionId: Int(conditionalId) ?? 0, cityName: name, temperature: Double(temperature) ?? 0))
        }
        return resultCities
    }
    
    func save(cities: [WeatherModel]) {
        var arrayForStorage: [[String:String]] = []
        cities.forEach { city in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[Citykey.name.rawValue] = city.cityName
            newElementForStorage[Citykey.temperature.rawValue] = city.temperatureString
            newElementForStorage[Citykey.conditionId.rawValue] = city.conditionName
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
