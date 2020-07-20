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
import Charts
import NSObject_Rx

class TimerViewController: UIViewController {
  
  var viewModel: TimerViewModel!
  
  let secondLabel = UILabel()
  let minuteLabel = UILabel().then {
    $0.isHidden = true
  }
  let hourLabel = UILabel().then {
    $0.isHidden = true
  }
  let dayLabel = UILabel().then {
    $0.isHidden = true
  }
  lazy var weekAvgLabel = UILabel().then {
    weekAvgLabelTextSetup($0)
  }
  
  lazy var cigaretteNameLabel = UILabel().then {
    cigaretteNameLabelTextSetup($0)
  }
  
  lazy var cigarettePackImage = UIImageView().then {
    $0.image = UIImage(named: "cigarettePack")
  }
  
  lazy var timeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .equalSpacing
    $0.spacing = 10
  }
  
  lazy var lastCigaretteLabel = UILabel().then {
    $0.text = "Last Cigarette"
    lastCigaretteLabelTextSetup($0)
  }
  
  lazy var weekAvgTitleLabel = UILabel().then {
    weekAvgTitleLabelTextSetup($0)
  }
  
  lazy var timerBottomView = UIView().then {
    $0.backgroundColor = UIColor(named: "TimerCardBackColor")
    $0.layer.cornerRadius = 30
    $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
  }
  
  lazy var todayCountTitleLabel = UILabel().then {
    todayCountTitleLabelSetup($0)
  }
  
  lazy var countLabel = UILabel().then {
    countLabelTextSetup($0)
  }
  
  lazy var upCountButton = UIButton().then {
    upCountButtonSetup($0)
  }
  
  lazy var downCountButton = UIButton().then {
    downCountButtonSetup($0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppModel.instance.timerVCStart()
    view.backgroundColor = UIColor(named: "TimerBackColor")
    bind()
    setUpUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = true
    viewModel.setTimer()
  }
  
  private func bind() {
    viewModel.timerStart()
    viewModel.loadWeekAverage()
    
    viewModel.todayCount
      .map { "\($0)" }
      .bind(to: countLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    upCountButton.rx.tap
      .map { [weak self] in
        (self?.countLabel.text.map { Int($0)! + 1 })!
    }
    .subscribe(onNext: { [weak self] in
      self?.viewModel.timerInitInServer()
      self?.viewModel.todayCount.onNext($0) })
      .disposed(by: rx.disposeBag)
    
    downCountButton.rx.tap
      .filter{ [unowned self] in
        Int(self.countLabel.text!)! > 0}
      .map {  [weak self] in
             (self?.countLabel.text.map { Int($0)! - 1 })!}
      .subscribe(onNext: { [weak self] in
        self?.viewModel.timerInitInServer()
        self?.viewModel.todayCount.onNext($0) })
        .disposed(by: rx.disposeBag)
    
    viewModel.todayCount
      .subscribe(onNext: { print($0)})
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .take(1)
      .subscribe(onNext: { [unowned self] _ in
        self.timeStackView.addArrangedSubview(self.dayLabel)
        self.timeStackView.addArrangedSubview(self.hourLabel)
        self.timeStackView.addArrangedSubview(self.minuteLabel)
        self.timeStackView.addArrangedSubview(self.secondLabel)
      })
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .subscribe(onNext: { [unowned self] in
        if $0.day != 0 {
          self.dayLabel.isHidden = false
          self.hourLabel.isHidden = false
          self.minuteLabel.isHidden = false
        } else if $0.hour != 0 {
          self.hourLabel.isHidden = false
          self.minuteLabel.isHidden = false
        } else if $0.minute != 0 {
          self.minuteLabel.isHidden = false
        } else {
          self.dayLabel.isHidden = true
          self.hourLabel.isHidden = true
          self.minuteLabel.isHidden = true
        }
      })
      .disposed(by: rx.disposeBag)
    
    
    viewModel.timerData
      .map { "\($0.day)d" }
      .bind(to: self.dayLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .map { "\($0.hour)h"}
      .bind(to: self.hourLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .map { "\($0.minute)m"}
      .bind(to: self.minuteLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    viewModel.timerData
      .map { "\($0.second)s" }
      .bind(to: self.secondLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
    viewModel.weeklyAverage
      .map { "\($0)"}
      .bind(to: self.weekAvgLabel.rx.text)
      .disposed(by: rx.disposeBag)
  }
  
  private func setUpUI() {
    timerTextSetUp()
    
    view.addSubviews(views: [timeStackView, weekAvgLabel, cigaretteNameLabel, cigarettePackImage, lastCigaretteLabel, weekAvgTitleLabel, timerBottomView])
    timerBottomView.addSubviews(views: [todayCountTitleLabel, countLabel, upCountButton, downCountButton])
    setUpConstraints()
  }
  
  private func setUpConstraints() {
    
    
    
    cigaretteNameLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(22)
      $0.leading.equalTo(20)
    }
    
    cigarettePackImage.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.trailing.equalTo(view.snp.trailing).multipliedBy(0.5)
      $0.bottom.equalTo(view.snp.bottom).multipliedBy(0.45)
      $0.height.equalTo(cigarettePackImage.snp.width).offset(-5)
    }
    
    lastCigaretteLabel.snp.makeConstraints {
      $0.top.equalTo(cigarettePackImage.snp.top).offset(5)
      $0.leading.equalTo(view.snp.centerX)
    }
    
    timeStackView.snp.makeConstraints {
      $0.top.equalTo(lastCigaretteLabel.snp.bottom)
      $0.leading.equalTo(lastCigaretteLabel)
    }
    
    weekAvgTitleLabel.snp.makeConstraints {
      $0.top.equalTo(timeStackView.snp.bottom).offset(22)
      $0.leading.equalTo(lastCigaretteLabel)
    }
    
    weekAvgLabel.snp.makeConstraints {
      $0.centerY.equalTo(weekAvgTitleLabel)
      $0.leading.equalTo(weekAvgTitleLabel.snp.trailing).offset(12)
    }
    
    timerBottomView.snp.makeConstraints {
      $0.top.equalTo(view.snp.centerY).offset(30)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
    
    todayCountTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.centerX.equalToSuperview()
    }
    
    countLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview().offset(-15)
    }
    
    upCountButton.snp.makeConstraints {
      $0.leading.equalTo(view.snp.centerX).offset(20)
      $0.trailing.equalToSuperview().offset(-40)
      $0.bottom.equalToSuperview().offset(-30)
      $0.height.equalToSuperview().multipliedBy(0.2)
    }
    
    downCountButton.snp.makeConstraints {
      $0.trailing.equalTo(view.snp.centerX).offset(-20)
      $0.leading.equalToSuperview().offset(40)
      $0.bottom.equalToSuperview().offset(-30)
      $0.height.equalToSuperview().multipliedBy(0.2)
    }
  }
  
}

extension TimerViewController {
  func timerTextSetUp() {
    [dayLabel, hourLabel, minuteLabel, secondLabel].forEach({
      $0.font = UIFont(name: "NotoSans-ExtraBold", size: 24)
      $0.textColor = UIColor(named: "SmallFontColor")
      $0.textAlignment = .left
      
      $0.layer.shadowOffset = CGSize(width: 1, height: 1)
      $0.layer.shadowOpacity = 1
      $0.layer.shadowRadius = 0
      $0.layer.shadowColor = UIColor(named: "SmallFontBackColor")?.cgColor
    })
  }
  
  func weekAvgLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-ExtraBoldItalic", size: 50)
    label.textColor = UIColor(named: "SmallFontColor")
    label.textAlignment = .left
    
    label.layer.shadowOffset = CGSize(width: 1, height: 1)
    label.layer.shadowOpacity = 1
    label.layer.shadowRadius = 0
    label.layer.shadowColor = UIColor(named: "SmallFontBackColor")?.cgColor
  }
  
  func weekAvgTitleLabelTextSetup(_ label: UILabel) {
    label.text = "Last Week\nAverage :"
    label.numberOfLines = 2
    label.font = UIFont(name: "NotoSans-ExtraBold", size: 24)
    label.textColor = UIColor(named: "SmallFontColor")
    label.textAlignment = .left
    
    label.layer.shadowOffset = CGSize(width: 1, height: 1)
    label.layer.shadowOpacity = 1
    label.layer.shadowRadius = 0
    label.layer.shadowColor = UIColor(named: "SmallFontBackColor")?.cgColor
  }
  
  func cigaretteNameLabelTextSetup(_ label: UILabel) {
    let attributedString = NSMutableAttributedString(string: "BOHAM CIGAR -\nSlim Fit White", attributes: [
         .font: UIFont(name: "NotoSans-ExtraBold", size: 38.0)!,
         .foregroundColor: UIColor(red: 206.0 / 255.0, green: 75.0 / 255.0, blue: 70.0 / 255.0, alpha: 1.0)
       ])
       attributedString.addAttribute(.font, value: UIFont(name: "NotoSans-BoldItalic", size: 38.0)!, range: NSRange(location: 14, length: 14))
       
       label.attributedText = attributedString
       label.numberOfLines = 2
       label.layer.shadowOffset = CGSize(width: 3, height: 3)
       label.layer.shadowOpacity = 1
       label.layer.shadowRadius = 0
       label.layer.shadowColor = UIColor(named: "NameBackColor")?.cgColor
  }
  
  func lastCigaretteLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-ExtraBold", size: 24)
    label.textColor = UIColor(named: "SmallFontColor")
    label.textAlignment = .left
    
    label.layer.shadowOffset = CGSize(width: 1, height: 1)
    label.layer.shadowOpacity = 1
    label.layer.shadowRadius = 0
    label.layer.shadowColor = UIColor(named: "SmallFontBackColor")?.cgColor
  }
  
  func todayCountTitleLabelSetup(_ label: UILabel) {
    label.text = "Today Count"
    label.font = UIFont(name: "NotoSans-ExtraBold", size: 44)
    label.textColor = UIColor.black
    label.textAlignment = .center
    
    label.layer.shadowOffset = CGSize(width: 5, height: 5)
    label.layer.shadowOpacity = 1
    label.layer.shadowRadius = 0
    label.layer.shadowColor = UIColor.cherryRed16.cgColor
  }
  
  func countLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-ExtraBoldItalic", size: 114)
    label.textColor = UIColor(named: "CountLabelColor")
    label.textAlignment = .left
    
    label.layer.shadowOffset = CGSize(width: 5, height: 5)
    label.layer.shadowOpacity = 0.9
    label.layer.shadowRadius = 0
    label.layer.shadowColor = UIColor(named: "CountLabelBackColor")?.cgColor
  }
  
  func upCountButtonSetup(_ button: UIButton) {
    button.setTitle("Up", for: .normal)
    button.titleLabel?.font = UIFont(name: "NotoSans-ExtraBold", size: 44)
    button.backgroundColor = UIColor.apple
    
    button.layer.cornerRadius = 10
    button.layer.shadowOffset = CGSize(width: 3, height: 3)
    button.layer.shadowOpacity = 0.46
    button.layer.shadowRadius = 0
    button.layer.shadowColor = UIColor.black.cgColor
  }
  
  func downCountButtonSetup(_ button: UIButton) {
    button.setTitle("Down", for: .normal)
    button.titleLabel?.font = UIFont(name: "NotoSans-ExtraBold", size: 44)
    button.backgroundColor = UIColor.coral
    
    button.layer.cornerRadius = 10
    button.layer.shadowOffset = CGSize(width: 3, height: 3)
    button.layer.shadowOpacity = 0.46
    button.layer.shadowRadius = 0
    button.layer.shadowColor = UIColor.black.cgColor
  }
  
}

extension UIColor {

  @nonobjc class var cherryRed16: UIColor {
    return UIColor(red: 1.0, green: 0.0, blue: 39.0 / 255.0, alpha: 0.16)
  }

  @nonobjc class var apple: UIColor {
    return UIColor(red: 107.0 / 255.0, green: 219.0 / 255.0, blue: 59.0 / 255.0, alpha: 1.0)
  }

  @nonobjc class var coral: UIColor {
    return UIColor(red: 244.0 / 255.0, green: 83.0 / 255.0, blue: 83.0 / 255.0, alpha: 1.0)
  }

}
