//
//  parser.swift
//  PennLabsTryoutProject
//
//  Created by Maxwell Roling on 1/27/18.
//  Copyright © 2018 Maxwell Roling. All rights reserved.
//

import Foundation
import SwiftyJSON
public class Parser {
    
    var data: Data!
    
    func parseData(data :Data) -> [Venue] {
        
        //set up current date
        let currDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let currDateString = df.string(from: currDate)
        
        var venueArray: [Venue] = []
        let json = JSON(data)
        
        //start parsing data
        for venue in json["document"]["venue"].arrayValue {
            var name: String
            var type: String
            var hours: String = ""
            
            //set name and type of venue
            name = venue["name"].stringValue
            type = venue["venueType"].stringValue
            
            //parse hours of operation of each venue
            let hoursArr = venue["dateHours"].arrayValue
            for day in hoursArr {
                
                var date = day["date"].stringValue
                if (date == currDateString) {
                    
                    let meals = day["meal"].arrayValue
                    let mealCount = meals.count
                    
                    for meal in meals {
                        
                        let open = meal["open"].stringValue
                        let close = meal["close"].stringValue
                        
                        //format the date correctly. I'll admit, this code is a bit messy, but I don't have the time to make it look pretty :(
                        df.dateFormat = "HH:mm:ss"
                        var time = df.date(from: open)
                        
                        //determine what format to use
                        let openSplit = open.split(separator: ":")
                        
                        if (mealCount > 1) {
                            if (openSplit[1] == "00") {
                                df.dateFormat = "h"
                            } else {
                                df.dateFormat = "h:mm"
                            }
                        }
                        else {
                            if (openSplit[1] == "00") {
                                df.dateFormat = "ha"
                            } else {
                                df.dateFormat = "h:mma"
                            }
                        }
                        
                        let openTime = df.string(from: time!)
                        
                        //do the same for the closing time
                        df.dateFormat = "HH:mm:ss"
                        time = df.date(from: close)
                        
                        //determine what format to use again
                        let closeSplit = close.split(separator: ":")
                        if (mealCount > 1) {
                            if (closeSplit[1] == "00") {
                                df.dateFormat = "h"
                            } else {
                                df.dateFormat = "h:mm"
                            }
                        }
                        else {
                            if (closeSplit[1] == "00") {
                                df.dateFormat = "ha"
                            } else {
                                df.dateFormat = "h:mma"
                            }
                        }
                        let closeTime = df.string(from: time!)
                        
                        if (hours != "") {
                            hours += " | "
                        }
                        
                        hours = hours + openTime + "-" + closeTime
                        
                    }
                    date = day["date"].stringValue
                }
            }
            
            let facilityURL = venue["facilityURL"].stringValue
            
            //set to CLOSED if not open on specified day
            if (hours == "") {
                hours = "CLOSED"
            }
            
            venueArray.append(Venue(type: type, name: name, hours: hours, url: facilityURL))
            
        }
        return venueArray
    } 
}

