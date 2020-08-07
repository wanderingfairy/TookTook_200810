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
  
  lazy var okButton = UIButton().then {
    $0.backgroundColor = .orange
  }

    override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = .white
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
    mapView.layer.cornerRadius = mapView.frame.width / 2
    mapView.layer.masksToBounds = true
    mapView.clipsToBounds = true
  }
  
  private func bind() {
    okButton.rx.tap
      .bind { [unowned self] in
        self.viewModel.currentCameraPosition.subscribe(onNext: {
          print($0)
          let marker = GMSMarker(position: $0)
          marker.title = "test"
          marker.snippet = "long long long information"
          marker.icon = UIImage(named: "PinImage")
          self.viewModel.addMarkerPosition.onNext(marker)
        })
          .disposed(by: self.rx.disposeBag)
    }
    .disposed(by: rx.disposeBag)
    
  }
  
  private func setupUI() {
    self.mapView = GMSMapView.map(withFrame: self.view.frame, camera: viewModel.camera)
    self.mapView.isUserInteractionEnabled = false
    view.addSubviews(views: [okButton, mapView])
    setupConstraints()
  }
  
  private func setupConstraints() {
    okButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
      $0.width.height.equalTo(50)
    }
    mapView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(200)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(view.snp.width).multipliedBy(0.6)
    }
  }
}
