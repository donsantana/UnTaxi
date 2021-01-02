//
//  OurDate.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 8/12/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

struct OurDate{
  var date = Date()
  
  init(stringDate: String?) {
    let dateFormatter = DateFormatter()
    if stringDate != nil{
      dateFormatter.dateFormat = stringDate!.contains("Z") ? "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" : "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
      dateFormatter.timeZone = stringDate!.contains("Z") ? TimeZone(abbreviation: "UTC") : TimeZone.current
      dateFormatter.locale = Locale(identifier: "en_US")
      self.date = dateFormatter.date(from: stringDate!) != nil ? dateFormatter.date(from: stringDate!)! : Date()
    }
  }
  
  init(date: Date) {
    self.date = date
  }
  
  func isToday()->Bool{
    return Calendar.current.isDateInToday(self.date)
  }
  
  func isYesterday() -> Bool {
    return Calendar.current.isDateInYesterday(self.date)
  }
  
  func isFuture() -> Bool{
    return self.date > Date()
  }
  
  func isPast() -> Bool{
    return self.date < Date()
  }
  
  func getISODate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: self.date)
  }
  
  func stringDate() -> String {
    let formatter = DateFormatter()
    //formatter.timeZone = TimeZone.current
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: self.date)
  }
  
  func stringTime() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "HH:mm:ss.SSSSSS'Z'"
    return formatter.string(from: date)
  }
  
  func getUTCTime() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    return formatter.string(from: date)
  }
  
  func dateToShow()->String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: date)
  }
  
  func dayToShow()->String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "d"
    return formatter.string(from: date)
  }
  
  func timeToShow()->String{
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "hh:mm a"
    return formatter.string(from: date)
  }
  
  func dateTimeToShow() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "MMM d,  hh:mm:ss a"
    return formatter.string(from: date)
  }
}
