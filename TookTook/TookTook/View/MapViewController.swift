//
//  MapViewController.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import RxCocoa
import RxFlow

class MapViewController: UIViewController {
  
  // MARK: - Property init
  
  var viewModel: MapViewModel!
  
  var mapView: GMSMapView!
  
  let bag = DisposeBag()
  
  var tapGesture = UITapGestureRecognizer()
  
  lazy var markerPin = UIView().then {
    let markerImageView = UIImageView()
    markerImageView.image = UIImage(named: "PinImage")
    $0.addSubview(markerImageView)
    markerImageView.snp.makeConstraints { (marker) in
      marker.edges.equalToSuperview()
    }
    $0.isHidden = true
  }
  
  lazy var addMarkerButton = UIButton().then {
    $0.setImage(UIImage(named: "MarkerAddButton"), for: .normal)
    $0.addGestureRecognizer(tapGesture)
    $0.adjustsImageWhenHighlighted = false
    setMapViewButtonsShadow($0)
  }
  
  lazy var confirmAddButton = UIButton().then {
    $0.setImage(UIImage(named: "confirmAddButton"), for: .normal)
    $0.adjustsImageWhenHighlighted = false
    setMapViewButtonsShadow($0)
    $0.alpha = 0
    $0.isHidden = true
  }
  
  lazy var cancelAddButton = UIButton().then {
    $0.setImage(UIImage(named: "cancelAddButton"), for: .normal)
    $0.adjustsImageWhenHighlighted = false
    setMapViewButtonsShadow($0)
    $0.alpha = 0
    $0.isHidden = true
  }
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewModel.validateAuthState()
    viewModel.validateLocationPermission()
    viewModel.mapStart()
    mapViewInit()
    bind()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AppModel.instance.appStart()
    viewModel.validateAuthState()
    viewModel.checkFunction()
    viewModel.findMyLocationButton(subviews: self.mapView.subviews, addMarkerButton: addMarkerButton)
  }
  
  // MARK: - Binding
  private func bind() {
    let rxAddMarkerButton = addMarkerButton.rx.controlEvent(.touchDown)
    rxAddMarkerButton
      .bind { _ in
        self.setSpreadShadowEffectForMapViewButtons(button: self.addMarkerButton)
        self.appearConfirmButton()
        self.appearCancelButton()
    }
    .disposed(by: rx.disposeBag)
    
    let rxAddMarkerButtonTouchUpInside = addMarkerButton.rx.controlEvent(.touchDown)
    rxAddMarkerButtonTouchUpInside
      .bind { _ in
        self.appearMarkerPin()
        print("didTapAddMarkerButton")
    }
    .disposed(by: rx.disposeBag)
    
    cancelAddButton.rx.controlEvent(.touchDown)
      .bind { _ in
        self.setSpreadShadowEffectForMapViewButtons(button: self.cancelAddButton)
        self.disappearConfirmButton()
        self.disappearCancelButton()
        self.disappearDummyMarkerView()
    }
    .disposed(by: rx.disposeBag)
    
    confirmAddButton.rx.controlEvent(.touchDown)
      .bind { _ in
        self.setSpreadShadowEffectForMapViewButtons(button: self.confirmAddButton)
        self.viewModel.navigateToAddMarkerVC(mapViewModel: self.viewModel, mapView: self.mapView)
    }
    .disposed(by: rx.disposeBag)
    
    self.viewModel.addMarkerPosition
      .bind {
        $0.map = self.mapView
        self.disappearConfirmButton()
        self.disappearCancelButton()
        self.disappearDummyMarkerView()
    }
    .disposed(by: rx.disposeBag)
  }
  
  // MARK: - Set up UI & Constraints
  private func setupUI() {
    view.addSubviews(views: [mapView, addMarkerButton, markerPin, confirmAddButton, cancelAddButton])
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    mapView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
    addMarkerButton.snp.makeConstraints {
      $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-76)
      $0.width.height.equalTo(56)
    }
    markerPin.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(mapView.snp.centerY)
      $0.width.equalTo(56)
      $0.height.equalTo(80)
    }
    confirmAddButton.snp.makeConstraints {
      $0.edges.equalTo(addMarkerButton)
    }
    cancelAddButton.snp.makeConstraints {
      $0.edges.equalTo(addMarkerButton)
    }
  }
}

  //MARK: - Map View
extension MapViewController {
  
  private func mapViewInit() {
    mapView = GMSMapView.map(withFrame: self.view.frame, camera: viewModel.camera)
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    self.mapView.delegate = self
  }
  
  func setMapViewButtonsShadow(_ button: UIButton) {
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowOpacity = 0.25
    button.layer.shadowRadius = 1
    button.layer.shadowColor = UIColor.black.cgColor
  }
  
  private func appearMarkerPin() {
    markerPin.isHidden = false
  }
  
  private func appearConfirmButton() {
    self.confirmAddButton.snp.remakeConstraints() {
      $0.width.height.equalTo(self.addMarkerButton)
      $0.centerY.equalTo(self.addMarkerButton)
      $0.trailing.equalTo(self.addMarkerButton.snp.leading).offset(-10)
    }
    self.confirmAddButton.isHidden = false
    UIView.animate(withDuration: 0.3) {
      self.confirmAddButton.alpha = 1
    }
  }
  
  private func appearCancelButton() {
    self.cancelAddButton.isHidden = false
    UIView.animate(withDuration: 0.3) {
      self.cancelAddButton.alpha = 1
    }
  }
  
  private func disappearConfirmButton() {
    self.confirmAddButton.isHidden = true
    UIView.animate(withDuration: 0.3) {
      self.confirmAddButton.alpha = 0
    }
  }
  
  private func disappearCancelButton() {
    self.cancelAddButton.isHidden = true
    UIView.animate(withDuration: 0.3) {
      self.cancelAddButton.alpha = 0
    }
  }
  
  private func disappearDummyMarkerView() {
    self.markerPin.isHidden = true
  }
  
  @objc private func setSpreadShadowEffectForMapViewButtons(button: UIButton) {
    print(#function)
    let animation = CABasicAnimation(keyPath: "shadowRadius")
    animation.fromValue = button.layer.shadowRadius
    animation.toValue = 10
    animation.duration = 0.1
    animation.isRemovedOnCompletion = false
    button.layer.add(animation, forKey: animation.keyPath)
  }
}

// MARK: - GMSMapViewDelegate Functions
extension MapViewController: GMSMapViewDelegate, CLLocationManagerDelegate {
  func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//    print("current camera positaion is ", position.target)
    guard let currentCameraPosition = viewModel.currentCameraPosition else { return }
    currentCameraPosition.onNext(position.target)
  }
}


