//
//  ViewController.swift
//  InstaWeather
//
//  Created by Riyaz Ahamed on 14/10/15.
//  Copyright (c) 2015 SimplyApp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var placeID = ""
    var suggestionsArray:NSArray?
    var ios7_8BugFixString = ""
    
    
    @IBOutlet weak var constraintForTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestionsTableview: UITableView!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var pressureTitleLabel: UILabel!
    @IBOutlet weak var temperatureTitleLabel: UILabel!
    @IBOutlet weak var windTitleLabel: UILabel!
    
    @IBOutlet weak var humidityTitleLabel: UILabel!
    
    // MARK: - Viewcontroller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestionsTableview.hidden = true
        configSearchBar()
        configSuggestionsTableView()
        hideWeatherLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var point = touch.locationInView(nil)
        
        if !suggestionsTableview.hidden && point.y > 20 + 16{
            //hide suggestions on tap outside
            searchBar.resignFirstResponder()
            suggestionsTableview.hidden = true
            searchBar.setShowsCancelButton(false, animated: true)
            //getPlacesResults(searchBar.text)
        }
    }
    
    // MARK: - TableView delegates
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row < suggestionsArray?.count{
            var locationDetails = self.suggestionsArray![indexPath.row] as! NSDictionary
            cell.textLabel?.text = locationDetails["description"] as? String
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        placeID = ""
        if suggestionsArray != nil{
            var locationDetails = self.suggestionsArray![indexPath.row] as! NSDictionary
            placeID = locationDetails["place_id"] as! String
            searchBar.text = locationDetails["description"] as? String
            getWeatherInfo(searchBar.text)
        }
        searchBar.resignFirstResponder()
        suggestionsTableview.hidden = true
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if suggestionsArray != nil{
            return suggestionsArray!.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    // MARK: - SearchBar delegates
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        suggestionsTableview.hidden = false
        hideWeatherLabels()
        if searchBar.text != ""{
            getPlacesResults(searchBar.text)
        }else{
            suggestionsTableview.hidden = true
        }
        return true
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            suggestionsArray = nil
            suggestionsTableview.hidden = true
            searchBar.setShowsCancelButton(true, animated: true)
        }else{
            suggestionsTableview.hidden = false
            if self.ios7_8BugFixString != searchText{
                suggestionsTableview.reloadData()
                self.ios7_8BugFixString = searchText
                getPlacesResults(searchText)
            }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        suggestionsTableview.hidden = true
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        suggestionsTableview.hidden = true
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // MARK: - Oher methods
    func configSearchBar(){
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        searchBar.layer.shadowOpacity = 0.2
        searchBar.layer.shadowColor! = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).CGColor!
        searchBar.layer.shadowRadius = 2.0
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.barTintColor = UIColor.whiteColor()
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.whiteColor().CGColor!
    }
    
    func configSuggestionsTableView(){
        suggestionsTableview.clipsToBounds = false
        suggestionsTableview.layer.masksToBounds = false
        suggestionsTableview.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        suggestionsTableview.layer.shadowOpacity = 0.2
        suggestionsTableview.layer.shadowColor! = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).CGColor!
        suggestionsTableview.layer.shadowRadius = 2.0
    }
    
    func hideWeatherLabels(){
        weatherLabel.hidden = true
        temperatureLabel.hidden = true
        humidityLabel.hidden = true
        pressureLabel.hidden = true
        windLabel.hidden = true
        pressureTitleLabel.hidden = true
        weatherLabel.hidden = true
        temperatureTitleLabel.hidden = true
        humidityTitleLabel.hidden = true
        windTitleLabel.hidden = true
    }
    
    func showWeatherLabels(){
        weatherLabel.hidden = false
        temperatureLabel.hidden = false
        humidityLabel.hidden = false
        pressureLabel.hidden = false
        windLabel.hidden = false
        pressureTitleLabel.hidden = false
        weatherLabel.hidden = false
        temperatureTitleLabel.hidden = false
        humidityTitleLabel.hidden = false
        windTitleLabel.hidden = false
    }
    
    
    
    // MARK: - API calls
    
    func getWeatherInfo(searchText:String){
        if searchText != ""{
            var urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(searchText)&appid=bd82977b86bf27fb59a04b61b657fb6f"
            urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            var url:NSURL! = NSURL(string: urlString)
            if url != nil{
                getData(url, params: nil, onSuccess: {(data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let weather = data["weather"] as? NSDictionary{
                            self.weatherLabel.text = weather["description"] as? String
                        }
                        if let weather = data["main"] as? NSDictionary{
                            var temperature = weather["temp"] as? NSNumber
                            var tempInCelcius = temperature!.doubleValue - 273.15
                            self.temperatureLabel.text = "\(tempInCelcius) C"
                            var humidity = weather["humidity"] as? NSNumber
                            self.humidityLabel.text = "\(humidity!.doubleValue)%"
                            var pressure = weather["pressure"] as? NSNumber
                            self.pressureLabel.text = "\(pressure!.doubleValue) hPa"
                            
                        }
                        if let weather = data["wind"] as? NSDictionary{
                            var speed = weather["speed"] as? NSNumber
                            self.windLabel.text = "\(speed!.doubleValue) m/h"
                        }
                        self.showWeatherLabels()
                    });
                    
                    }) { (message) -> Void in
                }
            }
            else{
            }
        }
    }
    
    
    
    func getPlacesResults(searchText:String){
        if searchText != ""{
            var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchText)&language=en&components=country:in&types=(cities)&key=AIzaSyByEcn-b0fnhgaTY52bQQZLon960SqPSus"
            urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            var url:NSURL! = NSURL(string: urlString)
            if url != nil{
                getData(url, params: nil, onSuccess: {(data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        if data["status"] as! String == "OK"{
                            var locs:NSDictionary = data as! NSDictionary
                            self.suggestionsArray = locs["predictions"] as? NSArray
                            if self.suggestionsArray?.count > 5{
                                self.constraintForTableViewHeight.constant = CGFloat(self.suggestionsArray!.count * 44)
                            }else{
                                self.constraintForTableViewHeight.constant = CGFloat(self.suggestionsArray!.count * 44)
                            }
                            self.suggestionsTableview.reloadData()
                        }else if data["status"] as! String == "ZERO_RESULTS"{
                            self.suggestionsArray = nil
                            self.constraintForTableViewHeight.constant = 0
                            self.suggestionsTableview.reloadData()
                        }
                    });
                    
                    }) { (message) -> Void in
                }
            }
            else{
            }
        }
    }
    
    func getData(url:NSURL, params:[String:AnyObject]?, onSuccess:((data: AnyObject) -> Void)?, onFail:((message:String) -> Void)?){
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if(params != nil){
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        }
        
        fetchData(request, onSuccess: onSuccess, onFail: onFail)
    }
    
    func fetchData(request: NSMutableURLRequest, onSuccess:((data: AnyObject) -> Void)?, onFail:((message:String) -> Void)?)
    {
        let queue = NSOperationQueue()
        var response :NSURLResponse!
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data:NSData!, error:NSError!) -> Void in
            if data != nil{
                var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("data: \(datastring!)")
            }
            let res = response as! NSHTTPURLResponse!
            
            if error == nil{
                var err:NSError?
                let res = response as! NSHTTPURLResponse!
                
                switch res.statusCode {
                case 200:
                    if data != nil {
                        if var jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) {
                            onSuccess!(data: jsonResult)
                            return
                        }
                        var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                        if datastring == ""{
                            onSuccess!(data: [])
                            return
                        }
                    }
                    else{
                        onFail!(message: "No data received")
                        return
                    }
                default :
                    onFail!(message : "Server Error")
                    return
                }
            }
        }
    }
}



