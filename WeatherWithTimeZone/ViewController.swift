//
//  ViewController.swift
//  WeatherWithTimeZone
//
//  Created by Rajesh Kommana on 22/6/17.
//  Copyright © 2017 Rajesh Kommana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var addCity: UIBarButtonItem!
    @IBOutlet weak var weatherImageIconView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var apiKey = "YOURAPIKEY"
    var timeZoneApiKey = "YOURAPIKEY"
    var localIdentifier: String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradients()
        getWeatherData(city: "London") { (temp, desc, icon, lat, lng) in
            self.tempLabel.text = "\(Int(temp))°"
            self.weatherLabel.text = desc.capitalized
            self.cityLabel.text = "London"
            self.downloadWeatherIcon(iconID: icon) { (data) in
                self.weatherImageIconView.image = UIImage(data: data)
            }
            self.getTimeZoneIdentifier(lat: lat, lng: lng, completion: { (timeZoneId) in
                self.localIdentifier = timeZoneId
                 self.dayLabel.text = self.dateFromLocation(identifier: timeZoneId)
                 self.timeLabel.text = self.timeFromLocation(identifier: timeZoneId)
            })
            
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            
            

        }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
    }

    @IBAction func openCityDialog(_ sender: Any) {
        alertCity()
    }
    func addGradients() {
        
        let index = arc4random_uniform(UInt32(5))
        gradientImageView.image = UIImage(named: "gradient\(Int(index)).jpg")
        print("gradient\(Int(index))")
        
    }
    
    func alertCity() {
        
        let alert = UIAlertController(title: "Add City", message: "", preferredStyle: .alert)
        
        var cityText: UITextField?
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            cityText = alert.textFields?[0]
            self.changeCity(city: cityText!.text!)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
            
        }
        
        alert.addTextField { (cityText) in
            cityText.placeholder = "City ..."
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    func changeCity(city: String) {
        
        print("\(city)")
        getWeatherData(city: city) { (temp, desc, icon, lat, lng) in
            self.tempLabel.text = "\(Int(temp))°"
            self.weatherLabel.text = desc.capitalized
            self.cityLabel.text = city.capitalized
            
            self.downloadWeatherIcon(iconID: icon) { (data) in
                self.weatherImageIconView.image = UIImage(data: data)
            }
            self.getTimeZoneIdentifier(lat: lat, lng: lng, completion: { (timeZoneId) in
                self.localIdentifier = timeZoneId
                self.dayLabel.text = self.dateFromLocation(identifier: timeZoneId)
                self.timeLabel.text = self.timeFromLocation(identifier: timeZoneId)
            })
        }
        
    }
    
    func dateFromLocation(identifier: String) -> String {
        
        var dateString: String?
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.timeZone = TimeZone(identifier: identifier)
        dateString = dateFormatter.string(from: currentDate)
        
    
        return dateString!
    }
    func timeFromLocation(identifier: String) -> String {
        
        var timeString: String?
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.timeZone = TimeZone(identifier: identifier)
        timeString = dateFormatter.string(from: currentDate)
        
        
        return timeString!
    }
    func updateTime(){
        
        
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.timeZone = TimeZone(identifier: self.localIdentifier!)
        timeLabel.text = dateFormatter.string(from: currentDate)
        
        
        
    }
    
    


}

extension ViewController {
    
    func getWeatherData(city:String, completion: @escaping (_ temp: Double, _ weather: String, _ icon: String, _ latitude: Double, _ longitude: Double) -> ()){
        
        let cityFiltered: String = city.replacingOccurrences(of: " ", with: "+")
        
        let url:URL = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(cityFiltered)&appid=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil {
                
                if let validData = data {
                    
                    do {
                        
                        let resultsDict = try JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                       // print(resultsDict)
                        
                        let coord = resultsDict["coord"] as! NSDictionary
                        let lat = coord["lat"] as! Double
                        let lng = coord["lon"] as! Double
                        
                        let weather = resultsDict["weather"] as! NSArray
                        let weather0 = weather[0] as! NSDictionary
                        let tempDescription = weather0["description"] as! String
                        let icon = weather0["icon"] as! String
                        
                        
                        let main = resultsDict["main"] as! NSDictionary
                        let temp = main["temp"] as! Double
                        let tempCelcius = temp - 273.15
                        
                        DispatchQueue.main.async(execute:{
                            completion(tempCelcius, tempDescription, icon, lat,lng)
                            
                        })
                        
                        
                        
                        
                        
                        
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
            
            
        } // end of task
        
        task.resume()
        
        
    
    
    
    
    
    
   
    
    
    }
    
    func downloadWeatherIcon(iconID: String, completion: @escaping(_ imgData: Data) -> ()) {
        
        let url = URL(string: "http://openweathermap.org/img/w/\(iconID).png")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                
                if let dataValid = data {
                    
                    do {
                        DispatchQueue.main.async(execute:{
                            completion(dataValid)
                        })
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                
            }
        }
        task.resume()
        
        
        
    }
    
    func getTimeZoneIdentifier(lat: Double, lng: Double, completion: @escaping(_ identifier: String) -> ()) {
        
        let url: URL = URL(string: "https://maps.googleapis.com/maps/api/timezone/json?location=\(lat),\(lng)&timestamp=1458000000&key=\(timeZoneApiKey)")!
        var identifier: String?
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil {
                
                if let validData = data {
                    
                    do {
                        
                        let resultsDict = try JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        // print(resultsDict)
                        
                        identifier = resultsDict["timeZoneId"] as? String
                        print(identifier!)
                        
                        DispatchQueue.main.async(execute:{
                            completion(identifier!)
                            
                        })
                        
                        
                        
                        
                        
                        
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
            
            
        } // end of task
        
        task.resume()
        
        
        
    }
    
}

