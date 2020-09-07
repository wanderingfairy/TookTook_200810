# Took Took 리팩토링

패스트 캠퍼스 iOS School에서 진행했던 3차 해커톤 프로젝트를 RxSwift, MVVM-C 디자인 패턴을 사용해 리팩토링한 앱입니다. (기존 앱 레포 https://github.com/wanderingfairy/SmokerMap )

- RxSwift를 사용하여 비동기 작업 처리

- MVC 패턴 -> MVVM-C 패턴으로 변환

- 네이버 지도 API -> Google Map API

- 디자인 개선

  

## Description

- 사용 기술
  - Language : Swift
  - Framework : UIKit, CoreLocation, RxSwift
  - Library : Almofire, Action, NSObject-Rx, RxCocoa, RxFlow, SnapKit, Then, Kingfisher, GoogleMap
  - Back-End : Google Firebase

## Video Link(Youtube)

## https://youtu.be/d-w3wNaNFSI

## Design Concept

- neuromorphism design (Adobe XD 사용)

![스크린샷 2020-09-03 오후 5.38.09](https://tva1.sinaimg.cn/large/007S8ZIlgy1gidjvlloomj30u013zqis.jpg)



## Feature

- Apple Login

<img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9nogc58j30ke13qdnm.jpg" alt="스크린샷 2020-08-13 오후 4.21.23" style="zoom:50%;" />

- Google Map

<img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9oac146j30kg14mqmj.jpg" alt="스크린샷 2020-08-13 오후 4.24.23" style="zoom:50%;" />

- Add Smoking zone

<img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9oo31o0j30kc14qwr9.jpg" alt="스크린샷 2020-08-13 오후 4.24.48" style="zoom:50%;" />

- Smoking Timer

<img src="https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9p43fwbj30ke14k7f1.jpg" alt="스크린샷 2020-08-13 오후 4.24.59" style="zoom:50%;" />

---

## RxSwift + MVVM-C 

![스크린샷 2020-09-07 오후 7.36.42](https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9ro7orhj30wj0slh4z.jpg)

RxFlow를 사용하여 Coordinator 패턴을 적용했고, RxSwift를 이용해 기능을 구현했습니다.

---

## UnitTest

![스크린샷 2020-09-07 오후 7.38.58](https://tva1.sinaimg.cn/large/007S8ZIlgy1gii9u1bd2oj31az0u0tmn.jpg)

Unit Test를 이용하여 App State에 대한 기본적인 테스트를 구현했습니다.

