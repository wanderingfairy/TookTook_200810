//
//  AddMarkerViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/08/07.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import Action
import GoogleMaps
import GooglePlaces
import CoreLocation


struct AddMarkerViewModel: Stepper, ViewModel {
  let steps = PublishRelay<Step>()
  
  
}
