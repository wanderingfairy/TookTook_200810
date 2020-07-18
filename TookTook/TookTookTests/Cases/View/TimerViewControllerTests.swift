//
//  TimerViewControllerTests.swift
//  TookTookTests
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import XCTest
@testable import TookTook

class TimerViewControllerTests: XCTestCase {

  var sut: TimerViewController!

    override func setUp() {
      super.setUp()
      let rootTabBarController = loadRootTabBarController()
      sut = rootTabBarController.timerController
    }
    
    override func tearDown() {
      sut = nil
      super.tearDown()
    }
  
  // MARK: - Created TimerVC
  
  func testTimerVC_whenNavigatedToTimerVC_appStateIsInTimerVC() {
    //when
    sut.viewDidLoad()
    //then
    XCTAssertEqual(AppModel.instance.appState, AppState.inTimerVC)
  }
  
  func testTimerVC_whenStartedWithZeroTodayCount_countLabelTextIsZero() {
    // given
//    sut.viewModel.todayCount.onNext(0)
    
    // when
    sut.viewDidLoad()
    
    // then
    let countLabelText = sut.countLabel.text
    XCTAssertEqual(countLabelText, "0")
  }
  
  
  func textTimerVC_whenStartedWithNotZeroTodayCount_countLabelTextIsNotZero() {
    // given
//    sut.viewModel.todayCount.onNext(10)
    AppModel.instance.dataModel.inServerCount.onNext(100)
    AppModel.instance.appStart()
    
    // when
    sut.viewDidLoad()
    
    // then
    let countLabelText = sut.countLabel.text
    XCTAssertEqual(countLabelText, "100")
  }

}
