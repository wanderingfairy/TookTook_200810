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
  
  
  // MARK: - Post
  
}
