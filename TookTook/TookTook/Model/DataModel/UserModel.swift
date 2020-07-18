//
//  UserModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/18.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa
import NSObject_Rx

class UserModel {
  
  static let instance = UserModel()
  
  private let bag = DisposeBag()
  
  private let firebaseUID = BehaviorSubject<String?>(value: nil)
  
  
  func settingUID(withUID uid: String) {
    firebaseUID.onNext(uid)
    print(#function)
    firebaseUID
      .subscribe(onNext: { print("current saved UID is", $0)})
      .disposed(by: bag)
  }
  
  func currentUID() -> String {
    var uid = String()
    
    firebaseUID
      .subscribe(onNext: { uid = $0 ?? "none" })
      .disposed(by: bag)
    
    return uid
  }
  
}
