//
//  APIManager.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/18.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa
import RxFlow
import CoreLocation
import GoogleMaps

class APIManager {
  
  let ref = Database.database().reference()
  let uid = UserModel.instance.currentUID()
  // MARK: - CRUD
  
  // MARK: - Auth
  public func authSignOut() {
    do {
      try Auth.auth().signOut()
    } catch {
      print("Error while signing out!")
    }
  }
  
  // MARK: - Get
  public func getServerTimer(completion: @escaping (TimeModel) -> Void) {
    var timerData = TimeModel()
    
    ref.child(uid).child("TimerDate").observeSingleEvent(of: .value) { (dataSnp) in
      guard let wholeData = dataSnp.value as? [String:Any] else { return }
      guard let lastServerTimerTime = wholeData["Started Time"] as? String else { return }
      
      
      let now = Date()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy.MM.dd G 'at' HH:mm:ss zzz"
      guard let startDate = dateFormatter.date(from: lastServerTimerTime) else { return }
      
      let calendar = Calendar.current
      let dateGap = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate, to: now)
      
      if case let (y?, M?, d?, h?, m?, s?) = (dateGap.year, dateGap.month, dateGap.day, dateGap.hour, dateGap.minute, dateGap.second) {
        timerData.day = (y * 365) + (M * 30) + (d)
        timerData.hour = h
        timerData.minute = m
        timerData.second = s
        completion(timerData)
        print("inServerTime is ", (y * 365) + (M * 30) + (d), h, m, s)
        print(#function)
      }
    }
  }
  
  public func getServerCount(completion: @escaping (Int) -> Void) {
    var serverCount: Int!
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let todayStr = dateFormatter.string(from: today)
    
    ref.child(uid).child("TodayCount").child(todayStr).observeSingleEvent(of: .value) { (dataSnp) in
      guard let countInFB = dataSnp.value as? Int else { completion(0); return }
      serverCount = countInFB
      completion(serverCount)
    }
  }
  
  public func getWeekCounts(completion: @escaping (Int) -> Void) {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let todayStr = dateFormatter.string(from: today)
    
    ref.child(uid).child("TodayCount").observeSingleEvent(of: .value) { (dataSnp) in
      guard let weeksCountArr = dataSnp.value as? [String:Int] else { return }
      var result = weeksCountArr.sorted { $1.key < $0.key }
      
      while result.count > 8 {
        result = result.dropLast()
        print("dropLast!")
      }
      
      if result.first?.key == todayStr {
        result.removeFirst()
      }
      
      completion(result.map { $0.value }.reduce(0, +) / result.count)
    }
  }
  
  public func getAllMarkersInCommonDataWhenMapStarted(completion: @escaping ([GMSMarker]) -> Void) {
    var resultMarkerArr: [GMSMarker] = []
    ref.child("SmokingZoneData").observeSingleEvent(of: .value) { (dataSnp) in
      guard let allMarkers = dataSnp.value as? [String : Any] else { return }
      print(#function)
//      print(allMarkers.first)
      allMarkers.forEach {
        guard let innerValue = $0.value as? [String:Any] else { return }
        let lat = innerValue["lat"] as? Double
        let long = innerValue["long"] as? Double
        let title = innerValue["title"] as? String
        let snippet = innerValue["snippet"] as? String
        
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat!, longitude: long!))
        marker.title = title
        marker.snippet = snippet
        marker.icon = UIImage(named: "PinImage")
        resultMarkerArr.append(marker)
      }
      completion(resultMarkerArr)
    }
  }
  
  // MARK: - Post
  public func postInitialServerTimer(completion: @escaping () -> ()) {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd G 'at' HH:mm:ss zzz"
    let currentDate = dateFormatter.string(from: now)
    
    let value = ["Started Time" : currentDate] as [String:Any]
    ref.child(uid).child("TimerDate").setValue(value) { err, _ in
      if err == nil {
        print(#function)
        print("in Server timer init is completed")
        completion()
      } else {
        print(#function)
        print(AppError.timerInitError)
      }
    }
  }
  
  public func postUpdateCountInServer(currentCount: Int, completion: @escaping () -> ()) {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let todayStr = dateFormatter.string(from: today)
    
    ref.child(uid).child("TodayCount").child(todayStr).setValue(currentCount) { err, _ in
      if err == nil {
        print(#function)
        print("update Count is Completed")
        completion()
      } else {
        print(#function)
        print(AppError.updateCountError)
      }
    }
  }
  
  public func postAddMarkerToUserDataInServer(title: String, snippet: String, position: CLLocationCoordinate2D, completion: @escaping (String) -> ()) {
    
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let currentDate = dateFormatter.string(from: now)
    
    let value = ["title" : title, "snippet" : snippet, "lat" : position.latitude, "long" : position.longitude, "uid" : uid] as [String:Any]
    ref.child(uid).child("SmokingZoneThisUserAdded").child(currentDate).setValue(value) { err, _ in
      if err == nil {
        completion("upload To User Data In Server is Completed")
      } else {
        print(AppError.markerUploadInUserDataError)
      }
    }
  }
  
  public func postAddMarkerToCommonDataInServer(title: String, snippet: String, position: CLLocationCoordinate2D, completion: @escaping (String) -> ()) {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let currentDate = dateFormatter.string(from: now)
    
    let value = ["title" : title, "snippet" : snippet, "lat" : position.latitude, "long" : position.longitude, "uid" : uid] as [String:Any]
    ref.child("SmokingZoneData").child(currentDate).setValue(value) { err, _ in
      if err == nil {
        completion("upload To SmokingZoneData In Server is Completed")
      } else {
        print(AppError.markerUploadToCommonDataError)
      }
    }
  }
}
