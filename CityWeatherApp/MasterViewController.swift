//
//  MasterViewController.swift
//  CityWeatherApp
//
//  Created by Apple on 10/29/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    private var _detailViewController: DetailViewController? = nil
    private var _weatherResponseData = [WeatherResponseData]()
    private var _weatherImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            _detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        performSegue(withIdentifier: "newCity", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let city = Storage.shared.cities[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = city
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.shared.cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityWeatherCell", for: indexPath)
        let city = Storage.shared.cities[indexPath.row]
        
        FetchHelper.getLocationIdByCityName(city) { locationId in
            FetchHelper.getWeatherData(locationId) { data in
                FetchHelper.getWeatherImage(data, 0) { image in
                    DispatchQueue.main.async {
                        self.setRowData(cell, city, data, image)
                    }
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Storage.shared.cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func setRowData(_ cell: UITableViewCell, _ city: String, _ data: WeatherResponseData, _ image: UIImage) {
        cell.textLabel!.text = "\(Int(round(data.consolidatedWeather[0].theTemp!)))°C \(city)"
        cell.imageView?.image = image
    }
}

