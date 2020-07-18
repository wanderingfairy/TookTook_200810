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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppModel.instance.timerVCStart()
    view.backgroundColor = .white
    bind()
    setUpUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  private func bind() {
    viewModel.todayCount
      .map { "\($0)" }
      .bind(to: countLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    addCountButton.rx.tap
      .map { [weak self] in
        (self?.countLabel.text.map { Int($0)! + 1 })!
    }
    .subscribe(onNext: { [weak self] in
      self?.viewModel.todayCount.onNext($0) })
      .disposed(by: rx.disposeBag)
  }
  
  private func setUpUI() {
    view.addSubviews(views: [countLabel, addCountButton])
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
  }
  
}

