//
//  MapViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import Action


struct MapViewModel: Stepper, ViewModel {
  var steps = PublishRelay<Step>()


}

extension MapViewModel {
  public func checkFunction() {
    self.steps.accept(MainStep.check)
    print(#function)
  }
  
  public func navigateToLoginVC() {
    self.steps.accept(MainStep.loginIsRequired)
    print(#function)
  }
}
