//
//  ViewController.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class TimerViewController: UIViewController {
  
  var viewModel: TimerViewModel!
  
  let countLabel = UILabel()
  let addCountButton = UIButton().then {
    $0.setTitle("Add", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .orange
  }
  let timerLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppModel.instance.timerVCStart()
    view.backgroundColor = .white
    bind()
    setUpUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.setTimer()
  }
  
  private func bind() {
    viewModel.timerStart()
    
    viewModel.todayCount
      .map { "\($0)" }
      .bind(to: countLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    addCountButton.rx.tap
      .map { [weak self] in
        (self?.countLabel.text.map { Int($0)! + 1 })!
    }
    .subscribe(onNext: { [weak self] in
      self?.viewModel.timerInitInServer()
      self?.viewModel.todayCount.onNext($0) })
      .disposed(by: rx.disposeBag)
    
    viewModel.todayCount
      .subscribe(onNext: { print($0)})
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .subscribe(onNext: { [weak self] in
        self?.timerLabel.text = "\($0.day)일 \($0.hour)시간 \($0.minute)분 \($0.second)초"
      })
      .disposed(by: rx.disposeBag)
  }
  
  private func setUpUI() {
    view.addSubviews(views: [countLabel, addCountButton, timerLabel])
    setUpConstraints()
  }
  
  private func setUpConstraints() {
    countLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    addCountButton.snp.makeConstraints {
      $0.centerX.equalTo(countLabel)
      $0.top.equalTo(countLabel.snp.bottom).offset(100)
      $0.width.equalToSuperview().multipliedBy(0.7)
      $0.height.equalTo(50)
    }
    timerLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(countLabel.snp.top).offset(-50)
    }
  }
  
}

