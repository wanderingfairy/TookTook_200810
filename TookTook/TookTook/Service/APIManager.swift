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
}
