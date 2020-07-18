//
//  LoginViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import Action


struct LoginViewModel: Stepper, ViewModel {
  var steps = PublishRelay<Step>()

}

extension LoginViewModel {
  public func back() {
    self.steps.accept(MainStep.back)
    print("In LoginViewModel ", #function)
  }
}
