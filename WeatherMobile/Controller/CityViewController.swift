//
//  CityViewController.swift
//  WeatherMobile
//
//  Created by Ksusha on 13.04.2022.
//

import UIKit

class CityViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var cityManager = WeatherManager()
    var storage: CityStorageProtocol!
    
    private var cities: [WeatherModel] = [] {
        didSet {
            storage.save(cities: cities)
        }
    }

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityManager.delegateTable = self
        storage = CityStorage()
        loadCities()
    }
    
    private func loadCities(){
        cities = storage.load()
    }
    
    @IBAction func addNewCity(){
        let alertController = UIAlertController(title: "Add new city", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            let textAlert = alertController.textFields?.first
            if let text = textAlert?.text {
                self.cityManager.fetchWeather(cityName: text)
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: -CitiesManagerDelegate

extension CityViewController: CitiesManagerDelegate {
    func didUpdateWeather(_ weatherManger: WeatherManager, city: WeatherModel){
        cities.append(WeatherModel(conditionId: city.conditionId, cityName: city.cityName, temperature: city.temperature))
//        defaults.set(cities, forKey: "cities")
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}
//MARK: -UITableViewDataSource

extension CityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "cityCellIdentifier")
        else {
            var newCell = UITableViewCell(style: .default, reuseIdentifier: "cityCellIdentifier")
            configure(cell: &newCell, for: indexPath)
            return newCell
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        var configuration = cell.defaultContentConfiguration()
        configuration.text = cities[indexPath.row].cityName
        configuration.secondaryText = "\(cities[indexPath.row].temperatureString) ℃"
//        configuration.image = UIImage(systemName: cities[indexPath.row].conditionName)
//        configuration.imageProperties.tintColor = .gray
        cell.contentConfiguration = configuration
    }
}

//MARK: -UITableViewDelegate

extension CityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.cities.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}

