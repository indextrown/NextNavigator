# NextNavigator TODO

이 문서는 현재 `NextNavigator`의 다음 작업을 우선순위 기준으로 정리한 실행 문서다.
기준은 아래 3가지다.

- 라이브러리 핵심 가치에 직접 영향이 큰가
- 지금 구조를 흔들기 전에 먼저 결정해야 하는가
- 사용성과 테스트 안정성을 빠르게 올릴 수 있는가

---

## P0

지금 바로 먼저 해야 하는 작업이다.
구조와 API 방향을 결정하는 항목이라 뒤로 미루면 이후 구현이 흔들릴 가능성이 크다.

### 1. Navigator MVP API 확정

목표:

- 현재 뼈대 수준의 `Navigator`를 실제 MVP 명세와 맞춘다.

우선 확정할 메서드:

- `launch`
- `push`
- `replace`
- `back`
- `backTo`
- `backOrPush`
- `present`
- `dismissModal`

바로 결정할 것:

- `push([Route])`를 유지할지
- `replace(with:)` 네이밍을 유지할지
- `backTo(_:)`가 마지막 일치 기준인지 확정
- modal이 root 하나만 가지는지 확정

완료 기준:

- `Navigator` 공개 API가 README MVP와 일치한다.
- 메서드 시그니처가 더 이상 자주 바뀌지 않는다.

### 2. RouteRegistry 등록 API 개선

문제:

- 연관값 route 등록 시 `matches`와 `guard case let`를 매번 직접 써야 해서 사용성이 떨어진다.

예:

```swift
.registering(
  .init(
    matches: { route in
      if case .detail = route { return true }
      return false
    },
    build: { context in
      guard case let .detail(id) = context.route else { return nil }
      ...
    }))
```

개선 목표:

- 연관값 route를 더 짧고 읽기 좋게 등록할 수 있는 API 추가

후보:

- `registering(matching:build:)`
- `registering(case:build:)`
- case-path 스타일 helper

완료 기준:

- 예제 앱의 `AppRouter.swift`에서 detail route 등록이 지금보다 더 단순해진다.

### 3. Modal 정책 명확화

지금 필요한 결정:

- modal 1계층만 지원할지
- fullScreen과 일반 sheet를 분리할지
- modal 내부 `back()` 동작 규칙
- modal dismiss 후 `modalController` 정리 정책

완료 기준:

- `ModalCoordinator`가 현재 요구명세 기준으로 최소 동작을 명확히 가진다.
- README와 실제 구현이 같은 정책을 설명한다.

### 4. 핵심 테스트 보강

먼저 넣어야 할 테스트:

- `push`
- `replace`
- `back`
- `backTo`
- `backOrPush`
- `present`
- `dismissModal`
- route 미등록 시 동작

완료 기준:

- 핵심 navigation 연산이 최소 단위 테스트로 보호된다.

---

## P1

P0가 끝난 뒤 바로 이어갈 작업이다.
실사용성과 확장성을 크게 높이는 항목들이다.

### 5. TabCoordinator 구체화

필요한 작업:

- 탭별 독립 stack 유지 정책 확정
- `switchTab(tag:)` 또는 route 기반 탭 이동 API 확정
- 현재 탭 재선택 시 root 복귀 여부 결정
- `TabNavigationHost` 사용 예제 추가

완료 기준:

- 탭 전환이 실제 예제로 검증된다.

### 6. remove / mergeReplace 계열 연산 추가 여부 결정

기존 LinkNavigator의 핵심 연산 중 이관 검토 대상:

- `remove`
- `rootRemove`
- `mergeReplace`
- `rootBackOrNext`

판단 기준:

- 이 연산이 실제 앱에서 자주 필요한가
- typed route 구조에서 자연스러운가
- coordinator 분리 구조를 해치지 않는가

완료 기준:

- 가져올 연산 / 제외할 연산이 명확히 표로 정리된다.

### 7. 예제 앱 확장

추가 후보:

- `ModalSampleApp`
- `TabSampleApp`

목표:

- 문서만 읽지 않고 예제를 직접 열어 개념을 이해할 수 있게 한다.

완료 기준:

- 최소 2개의 성격 다른 예제가 생긴다.

### 8. README와 구현 동기화

해야 할 일:

- README에 적힌 API와 실제 코드 차이 정리
- 구현된 기능과 예정 기능 구분
- 샘플과 문서 링크 최신화

완료 기준:

- 사용자가 README를 보고 기대한 기능과 현재 구현 상태가 크게 다르지 않다.

---

## P2

지금 당장보다 이후 확장 단계에서 보면 좋은 작업이다.

### 9. FullScreen / CustomSheet / PresentationStyle 확장

후보 기능:

- fullScreen modal
- custom presentation style
- detent sheet

주의:

- 이 단계는 modal 정책이 먼저 안정화된 뒤 진행한다.

### 10. Deep link parser 모듈

목표:

- URL -> typed route 변환 계층 추가

완료 기준:

- typed route 구조를 깨지 않고 deep link를 붙일 수 있다.

### 11. Route metadata 일반화

문제:

- 현재는 `WrappingController`와 `AnyRouteIdentifiable`에 의존해 route를 추적한다.

개선 방향:

- UIKit 화면 전반에서 더 일반적으로 route를 식별할 수 있는 방식 검토

### 12. UIKit-only 화면 예제 추가

지금 예제는 SwiftUI wrapped view 중심이다.

후보:

- `UIViewController` 직접 반환 예제
- UIKit view controller와 SwiftUI wrapping 혼합 예제

### 13. 이벤트/알림 계층 분리 검토

기존 LinkNavigator에는 event send 계열 기능이 있다.

우리 버전에서는:

- navigator 내부에 넣지 않고
- 별도 모듈 또는 별도 패턴으로 둘 가능성이 크다.

이 항목은 코어가 안정화된 뒤 다시 검토한다.

---

## 추천 실행 순서

현재 가장 추천하는 작업 순서는 아래다.

1. `Navigator` MVP API 확정
2. `RouteRegistry` 등록성 개선
3. modal 정책 구현
4. 핵심 테스트 추가
5. tab 정책 구현
6. 예제 앱 확장
7. README 동기화

---

## 지금 바로 다음 작업 후보

바로 시작하기 가장 좋은 후보는 둘 중 하나다.

### 후보 A. RouteRegistry 개선

이유:

- 구현 범위가 비교적 작다.
- 예제 코드가 바로 좋아진다.
- 개발자 경험이 눈에 띄게 개선된다.

### 후보 B. ModalCoordinator 구체화 + 테스트

이유:

- 현재 라이브러리 핵심 가치와 직접 연결된다.
- 기존 LinkNavigator 대비 실전성이 올라간다.

내 추천은 `후보 A -> 후보 B` 순서다.

