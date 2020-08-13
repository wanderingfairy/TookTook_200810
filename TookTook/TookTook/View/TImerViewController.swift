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
  
  lazy var todayLabelView = UIView()
  
  lazy var todayLabelBackView = UIImageView().then {
    $0.image = UIImage(named: "todayTitleLabelBackView")
  }
  
  lazy var last7DayLabelView = UIView()
  lazy var last7DayLabelBackView = UIImageView().then {
    $0.image = UIImage(named: "last7DayLabelBackView")
  }
  
  lazy var daysAvgView = UIView()
  lazy var daysAvgBackView = UIImageView().then {
    $0.image = UIImage(named: "last7DayLabelBackView")
  }
  
  lazy var lastCigaretteView = UIView()
  lazy var lastCigaretteBackView = UIImageView().then {
    $0.image = UIImage(named: "lastCigaretteBackView")
  }
  
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
    $0.text = "Your last cigarette"
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
  lazy var upCountButtonBackView = UIImageView().then {
    $0.image = UIImage(named: "plusButton")
  }
  
  lazy var downCountButton = UIButton().then {
    downCountButtonSetup($0)
  }
  lazy var downCountButtonBackView = UIImageView().then {
    $0.image = UIImage(named: "minusButton")
  }
  lazy var settingButton = UIButton()
  lazy var settingButtonBackView = UIImageView().then {
    $0.image = UIImage(named: "settingButton")
  }
  lazy var last7DaysCountLabel = UILabel().then {
    last7DayLabelTextSetup($0)
  }
  lazy var last7DaysTitleLabel = UILabel().then {
    last7DayTitleLabelTextSetup($0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppModel.instance.timerVCStart()
    view.backgroundColor = UIColor(named: "grayBackgroundColor")
    bind()
    setUpUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AppModel.instance.inTimerVC()
    self.navigationController?.navigationBar.isHidden = true
    self.tabBarController?.tabBar.isHidden = false
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
    
    viewModel.weeklyAllCount
      .map { "\($0)"}
      .bind(to: self.last7DaysCountLabel.rx.text)
      .disposed(by: rx.disposeBag)
    
  }
  
  private func setUpUI() {
    timerTextSetUp()
    
    view.addSubviews(views: [todayLabelBackView, todayLabelView, last7DayLabelView, last7DayLabelBackView, daysAvgView, daysAvgBackView, lastCigaretteView, lastCigaretteBackView, upCountButton, downCountButton, countLabel, todayCountTitleLabel, timeStackView, lastCigaretteLabel, weekAvgLabel, weekAvgTitleLabel, upCountButtonBackView, downCountButtonBackView, settingButton, settingButtonBackView, last7DaysCountLabel, last7DaysTitleLabel])
    setUpConstraints()
  }
  
  private func setUpConstraints() {
    
    let bounds = UIScreen.main.bounds
    let height = bounds.size.height
    
    todayLabelView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(dynamicHeight(34))
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.9)
      $0.height.equalToSuperview().multipliedBy(0.22)
    }
    
    todayLabelBackView.snp.makeConstraints {
      $0.center.equalTo(todayLabelView)
      $0.width.equalTo(todayLabelView).multipliedBy(1.2)
      $0.height.equalTo(todayLabelView).multipliedBy(1.35)
    }
    
    last7DayLabelView.snp.makeConstraints {
      $0.leading.equalTo(todayLabelView)
      $0.top.equalTo(todayLabelView.snp.bottom).offset(dynamicHeight(40))
      $0.trailing.equalTo(view.snp.centerX).offset(-10)
      $0.height.equalToSuperview().multipliedBy(0.12)
    }
    
    last7DayLabelBackView.snp.makeConstraints {
      $0.center.equalTo(last7DayLabelView)
      $0.width.equalTo(last7DayLabelView).multipliedBy(1.46)
      $0.height.equalTo(last7DayLabelView).multipliedBy(1.66)
    }
    daysAvgView.snp.makeConstraints {
      $0.trailing.equalTo(todayLabelView)
      $0.top.equalTo(last7DayLabelView)
      $0.leading.equalTo(view.snp.centerX).offset(10)
      $0.height.equalToSuperview().multipliedBy(0.12)
    }
    daysAvgBackView.snp.makeConstraints {
      $0.center.equalTo(daysAvgView)
      $0.width.equalTo(daysAvgView).multipliedBy(1.46)
      $0.height.equalTo(daysAvgView).multipliedBy(1.66)
    }
    weekAvgLabel.snp.makeConstraints {
      $0.bottom.equalTo(daysAvgView.snp.centerY).offset(10)
      $0.centerX.equalTo(daysAvgView)
    }
    weekAvgTitleLabel.snp.makeConstraints {
      $0.top.equalTo(daysAvgView.snp.centerY).offset(10)
      $0.centerX.equalTo(daysAvgView)
    }
    last7DaysCountLabel.snp.makeConstraints {
      $0.bottom.equalTo(last7DayLabelView.snp.centerY).offset(10)
      $0.centerX.equalTo(last7DayLabelView)
    }
    last7DaysTitleLabel.snp.makeConstraints {
      $0.top.equalTo(last7DayLabelView.snp.centerY).offset(10)
      $0.centerX.equalTo(last7DayLabelView)
    }
    
    lastCigaretteView.snp.makeConstraints {
      $0.top.equalTo(last7DayLabelView.snp.bottom).offset(dynamicHeight(46))
      $0.leading.equalTo(todayLabelView)
      $0.trailing.equalTo(todayLabelView)
      $0.height.equalToSuperview().multipliedBy(0.143)
    }
    lastCigaretteBackView.snp.makeConstraints {
      $0.center.equalTo(lastCigaretteView)
      $0.width.equalTo(lastCigaretteView).multipliedBy(1.21)
      $0.height.equalTo(lastCigaretteView).multipliedBy(1.88)
    }
    timeStackView.snp.makeConstraints {
      $0.top.equalTo(lastCigaretteView).offset(15)
      $0.centerX.equalTo(lastCigaretteView)
    }
    lastCigaretteLabel.snp.makeConstraints {
      $0.top.equalTo(lastCigaretteView.snp.centerY).offset(10)
      $0.centerX.equalTo(lastCigaretteView)
    }
    

    
    upCountButton.snp.makeConstraints {
      $0.trailing.equalTo(todayLabelView)
      $0.top.equalTo(lastCigaretteView.snp.bottom).offset(dynamicHeight(46))
      $0.width.equalToSuperview().multipliedBy(0.24)
      $0.height.equalTo(view.snp.width).multipliedBy(0.23)
    }
    
    upCountButtonBackView.snp.makeConstraints {
      $0.center.equalTo(upCountButton)
      $0.width.equalTo(upCountButton).multipliedBy(1.76)
      $0.height.equalTo(upCountButton).multipliedBy(1.82)
    }
    
    downCountButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(lastCigaretteView.snp.bottom).offset(dynamicHeight(46))
      $0.width.equalToSuperview().multipliedBy(0.24)
      $0.height.equalTo(view.snp.width).multipliedBy(0.23)
    }
    downCountButtonBackView.snp.makeConstraints {
      $0.center.equalTo(downCountButton)
      $0.width.equalTo(downCountButton).multipliedBy(1.76)
      $0.height.equalTo(downCountButton).multipliedBy(1.82)
    }
    
    settingButton.snp.makeConstraints {
      $0.leading.equalTo(todayLabelView)
      $0.top.equalTo(lastCigaretteView.snp.bottom).offset(dynamicHeight(46))
      $0.width.equalToSuperview().multipliedBy(0.24)
      $0.height.equalTo(view.snp.width).multipliedBy(0.23)
    }
    settingButtonBackView.snp.makeConstraints {
      $0.center.equalTo(settingButton)
      $0.width.equalTo(settingButton).multipliedBy(1.76)
      $0.height.equalTo(settingButton).multipliedBy(1.82)
    }
    
    
    countLabel.snp.makeConstraints {
      $0.centerX.equalTo(todayLabelView)
      $0.bottom.equalTo(todayLabelView.snp.centerY).offset(10)
    }
    
    todayCountTitleLabel.snp.makeConstraints {
      
      $0.centerX.equalTo(todayLabelView)
      $0.top.equalTo(todayLabelView.snp.centerY).offset(15)
    }

        

  }
  
}

extension TimerViewController {
  func timerTextSetUp() {
    [dayLabel, hourLabel, minuteLabel, secondLabel].forEach({
      $0.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(32))
      $0.textColor = UIColor(named: "CountLabelColor")
      $0.textAlignment = .left
    })
  }
  
  func weekAvgLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(44))
    label.textColor = UIColor(named: "CountLabelColor")
    label.textAlignment = .left
  }
  
  func weekAvgTitleLabelTextSetup(_ label: UILabel) {
    label.text = "7days AVG."
    label.numberOfLines = 2
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(22))
    label.textColor = UIColor(named: "todaycountColor")
    label.textAlignment = .left
  }
  
  func last7DayLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(44))
    label.textColor = UIColor(named: "CountLabelColor")
    label.textAlignment = .left
  }
  
  func last7DayTitleLabelTextSetup(_ label: UILabel) {
    label.text = "Last 7days"
    label.numberOfLines = 2
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(22))
    label.textColor = UIColor(named: "todaycountColor")
    label.textAlignment = .left
  }
  
  func lastCigaretteLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(24))
    label.textColor = UIColor(named: "todaycountColor")
    label.textAlignment = .left
    label.dynamicFont(fontSize: label.font.pointSize)
  }
  
  func todayCountTitleLabelSetup(_ label: UILabel) {
    label.text = "Today"
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(30))
    label.textColor = UIColor(named: "todaycountColor")
    label.textAlignment = .center
  }
  
  func countLabelTextSetup(_ label: UILabel) {
    label.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(74))
    label.textColor = UIColor(named: "CountLabelColor")
    label.textAlignment = .left
  }
  
  func upCountButtonSetup(_ button: UIButton) {
    button.setTitle("Up", for: .normal)
    button.titleLabel?.font = UIFont(name: "NotoSans-ExtraBold", size: dynamicFontSize(28))
    button.backgroundColor = UIColor(named: "grayBackgroundColor")
  }
  
  func downCountButtonSetup(_ button: UIButton) {
    button.setTitle("Down", for: .normal)
    button.titleLabel?.font = UIFont(name: "NotoSans-ExtraBold", size: dynamicFontSize(28))
    button.backgroundColor = UIColor(named: "grayBackgroundColor")
  }
  
  func dynamicFontSize(_ size: CGFloat) -> CGFloat {
    let bounds = UIScreen.main.bounds
    let height = bounds.size.height
    
    switch height {
    case 480.0: //Iphone 3,4S => 3.5 inch
      return size * 0.535
    case 568.0: //iphone 5, SE => 4 inch
      return size * 0.74
    case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
      return size * 0.92
    case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
      return size * 0.82
    case 812.0: //iphone X, XS => 5.8 inch
      return size * 0.9
    case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
      return size
    default:
      return size
    }
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

extension UILabel {
  
  func dynamicFont(fontSize size: CGFloat) {
    let currentFontName = self.font.fontName
    var calculatedFont: UIFont?
    let bounds = UIScreen.main.bounds
    let height = bounds.size.height
    
    switch height {
    case 480.0: //Iphone 3,4S => 3.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.7)
      resizeFont(calculatedFont: calculatedFont)
      break
    case 568.0: //iphone 5, SE => 4 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.8)
      resizeFont(calculatedFont: calculatedFont)
      break
    case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.92)
      resizeFont(calculatedFont: calculatedFont)
      break
    case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.95)
      resizeFont(calculatedFont: calculatedFont)
      break
    case 812.0: //iphone X, XS => 5.8 inch
      calculatedFont = UIFont(name: currentFontName, size: size)
      resizeFont(calculatedFont: calculatedFont)
      break
    case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 1.15)
      resizeFont(calculatedFont: calculatedFont)
      break
    default:
      print("not an iPhone")
      break
    }
  }
  
  private func resizeFont(calculatedFont: UIFont?) {
    self.font = calculatedFont
    self.font = UIFont(name: "NotoSans-Regular", size: calculatedFont!.pointSize)
  }
  
  func dynamicFontItalic(fontSize size: CGFloat) {
    let currentFontName = self.font.fontName
    var calculatedFont: UIFont?
    let bounds = UIScreen.main.bounds
    let height = bounds.size.height
    
    switch height {
    case 480.0: //Iphone 3,4S => 3.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.7)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    case 568.0: //iphone 5, SE => 4 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.8)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.92)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 0.95)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    case 812.0: //iphone X, XS => 5.8 inch
      calculatedFont = UIFont(name: currentFontName, size: size)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
      calculatedFont = UIFont(name: currentFontName, size: size * 1.15)
      resizeFontItalic(calculatedFont: calculatedFont)
      break
    default:
      print("not an iPhone")
      break
    }
  }
  
  private func resizeFontItalic(calculatedFont: UIFont?) {
    self.font = calculatedFont
    self.font = UIFont(name: "NotoSans-ExtraBoldItalic", size: calculatedFont!.pointSize)
  }
}

extension UIButton {

func dynamicFont(fontSize size: CGFloat) {
  let currentFontName = self.titleLabel?.font.fontName
  var calculatedFont: UIFont?
  let bounds = UIScreen.main.bounds
  let height = bounds.size.height
  
  switch height {
  case 480.0: //Iphone 3,4S => 3.5 inch
    calculatedFont = UIFont(name: currentFontName!, size: size * 0.7)
    resizeFont(calculatedFont: calculatedFont)
    break
  case 568.0: //iphone 5, SE => 4 inch
    calculatedFont = UIFont(name: currentFontName!, size: size * 0.8)
    resizeFont(calculatedFont: calculatedFont)
    break
  case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
    calculatedFont = UIFont(name: currentFontName!, size: size * 0.92)
    resizeFont(calculatedFont: calculatedFont)
    break
  case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
    calculatedFont = UIFont(name: currentFontName!, size: size * 0.95)
    resizeFont(calculatedFont: calculatedFont)
    break
  case 812.0: //iphone X, XS => 5.8 inch
    calculatedFont = UIFont(name: currentFontName!, size: size)
    resizeFont(calculatedFont: calculatedFont)
    break
  case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
    calculatedFont = UIFont(name: currentFontName!, size: size * 1.15)
    resizeFont(calculatedFont: calculatedFont)
    break
  default:
    print("not an iPhone")
    break
  }
}
  
  private func resizeFont(calculatedFont: UIFont?) {
    self.titleLabel?.font = calculatedFont!
    self.titleLabel?.font = UIFont(name: "NotoSans-Light", size: calculatedFont!.pointSize)!
  }
}

private func dynamicHeight(_ height: Float) -> Float {
        switch height {
        case 480.0: //Iphone 3,4S => 3.5 inch
          return height * 0.7
        case 568.0: //iphone 5, SE => 4 inch
          return height * 0.8
        case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
          return height * 0.92
        case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
          return height * 0.95
        case 812.0: //iphone X, XS => 5.8 inch
          return height
        case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
          return height * 1.15
        default:
          print("not an iPhone")
          break
        }
  return height
}
