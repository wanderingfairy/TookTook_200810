//
//  AddMarkerViewController.swift
//  TookTook
//
//  Created by 정의석 on 2020/08/07.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import RxCocoa
import RxFlow
import SkeletonView

class AddMarkerViewController: UIViewController {
  
  var viewModel: MapViewModel!
  
  var mapView: GMSMapView!
  
  // MARK: - Property
  lazy var okButton = UIButton().then {
    $0.backgroundColor = .orange
    $0.setTitle("Add", for: .normal)
  }
  lazy var cancelButton = UIButton().then {
    $0.backgroundColor = .orange
    $0.setTitle("Cancel", for: .normal)
  }
  lazy var titleLabel = UILabel().then {
    $0.text = "Add Smoking Zone"
  }
  lazy var areaTitleLabel = UILabel().then {
    $0.text = "name"
  }
  lazy var areaTitleTextField = UITextField().then {
    $0.borderStyle = .line
  }
  lazy var areaDetailLabel = UILabel().then {
    $0.text = "Detail"
  }
  lazy var areaDetailTextField = UITextField().then {
    $0.borderStyle = .line
  }
  
  lazy var markerPin = UIView().then {
    let markerImageView = UIImageView()
    markerImageView.image = UIImage(named: "PinImage")
    $0.addSubview(markerImageView)
    markerImageView.snp.makeConstraints { (marker) in
      marker.edges.equalToSuperview()
    }
    $0.isHidden = false
  }
  
  lazy var mapViewShadowView = UIImageView().then {
    $0.image = UIImage(named: "mapViewShadowView")
  }
  
  let titleTextSubject = BehaviorSubject<String>(value: "title")
  let detailTextSubject = BehaviorSubject<String>(value: "detail")
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "grayBackgroundColor")
    bind()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //    self.mapView.camera = viewModel.camera
    self.viewModel.currentCameraPosition
      .bind {
        self.mapView.camera = GMSCameraPosition(latitude: $0.latitude, longitude: $0.longitude, zoom: 17.0)
    }
    .disposed(by: rx.disposeBag)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    mapView.layer.cornerRadius = mapView.frame.width / 2
    //    mapView.layer.masksToBounds = true
    //    mapView.clipsToBounds = true
    
  }
  
  // MARK: - Binding
  private func bind() {
    
    var titleText = "title"
    var detailText = "detail"
    
    areaTitleTextField.rx.text
      .bind { self.titleTextSubject.onNext($0 ?? "title") }
      .disposed(by: rx.disposeBag)
    
    areaDetailTextField.rx.text
      .bind { self.detailTextSubject.onNext($0 ?? "detail")}
      .disposed(by: rx.disposeBag)
    
    titleTextSubject
      .subscribe(onNext: { titleText = $0 })
      .disposed(by: rx.disposeBag)
    
    detailTextSubject
      .subscribe(onNext: { detailText = $0 })
      .disposed(by: rx.disposeBag)
    
    okButton.rx.tap
      .bind { [unowned self] in
        self.viewModel.currentCameraPosition
          .take(1)
          .subscribe(onNext: {
          print($0)
          let marker = GMSMarker(position: $0)
          marker.title = titleText
          marker.snippet = detailText
          marker.icon = UIImage(named: "PinImage")
          self.viewModel.addMarkerPosition.onNext(marker)
        })
          .disposed(by: self.rx.disposeBag)
    }
    .disposed(by: rx.disposeBag)
    
    }
  
  // MARK: - Set up UI & Constraints
  private func setupUI() {
    self.mapView = GMSMapView.map(withFrame: self.view.frame, camera: viewModel.camera)
    self.mapView.isUserInteractionEnabled = false
    view.addSubviews(views: [mapViewShadowView, okButton, cancelButton, mapView, titleLabel, areaTitleLabel, areaTitleTextField, areaDetailLabel, areaDetailTextField, markerPin, ])
    setupConstraints()
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
      $0.centerX.equalToSuperview()
    }
    mapView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(50)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(view.snp.width).multipliedBy(0.7)
    }
    areaTitleLabel.snp.makeConstraints {
      $0.top.equalTo(mapView.snp.bottom).offset(20)
      $0.leading.equalToSuperview().offset(30)
    }
    areaTitleTextField.snp.makeConstraints {
      $0.top.equalTo(areaTitleLabel.snp.bottom).offset(10)
      $0.leading.equalTo(areaTitleLabel)
      $0.trailing.equalToSuperview().offset(-30)
    }
    areaDetailLabel.snp.makeConstraints {
      $0.top.equalTo(areaTitleTextField.snp.bottom).offset(20)
      $0.leading.equalTo(areaTitleLabel)
    }
    
    okButton.snp.makeConstraints {
      $0.leading.equalTo(areaTitleLabel)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
      $0.trailing.equalTo(view.snp.centerX).offset(-10)
      $0.height.equalTo(50)
    }
    
    cancelButton.snp.makeConstraints {
      $0.leading.equalTo(view.snp.centerX).offset(10)
      $0.bottom.equalTo(okButton)
      $0.trailing.equalTo(areaDetailTextField)
      $0.height.equalTo(50)
    }
    
    areaDetailTextField.snp.makeConstraints {
      $0.top.equalTo(areaDetailLabel.snp.bottom).offset(10)
      $0.leading.equalTo(areaTitleLabel)
      $0.trailing.equalToSuperview().offset(-30)
      $0.height.equalToSuperview().multipliedBy(0.08)
    }
    
    markerPin.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(mapView.snp.centerY)
      $0.width.equalTo(40)
      $0.height.equalTo(60)
    }
    
    mapViewShadowView.snp.makeConstraints {
      $0.center.equalTo(mapView)
      $0.width.height.equalTo(mapView).multipliedBy(1.24)
    }
  }
}
