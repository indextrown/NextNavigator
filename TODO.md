# NextNavigator TODO

이 문서는 현재 구현 상태를 기준으로, 이제 진짜 남아 있는 다음 작업을 정리한 문서다.
예전의 "뼈대 만들기" 단계는 대부분 지나갔고, 이제는 코어 안정화, API 확장, 문서-예제-테스트 정합성이 핵심이다.

---

## 최근 완료

아래 항목은 이미 반영된 상태다.

- `Navigator` MVP 뼈대 구현
- `push`, `replace`, `back`, `backTo`, `backOrPush`
- `present`, `presentFullScreen`, `dismissModal`
- `TabCoordinator`, `switchTab`
- `RouteRegistry`의 `matching` / `extracting` 등록 API
- `MinimalSampleApp` 샘플 앱
- README 사용 가이드 확장
- `.gitignore` 추가

---

## P0

지금 가장 먼저 손봐야 하는 작업이다.
실사용 품질과 구조 안정성에 직접 연결된다.

### 1. README와 실제 구현 완전 동기화

해야 할 일:

- 요구명세 성격의 서술과 현재 구현 설명을 더 명확히 분리
- 현재 지원 연산과 미지원 연산을 표로 정리
- 샘플 앱 기준 설명과 코어 API 설명이 충돌하지 않게 정리

완료 기준:

- README만 읽어도 "지금 되는 것"과 "앞으로 할 것"이 분명하다.

### 2. 탭 환경 modal 회귀 테스트 보강

배경:

- 탭 환경에서 `present`가 `rootController` 기준으로만 동작하던 버그를 수정했다.

해야 할 일:

- 선택된 탭 controller를 presenter로 쓰는 케이스를 더 안정적으로 테스트
- `presentFullScreen`도 탭 환경에서 검증
- modal + tab + back 조합 동작 테스트 추가

완료 기준:

- 탭 앱에서 modal 관련 회귀가 테스트로 보호된다.

### 3. route 미등록 / fallback 정책 명확화

지금 확인할 것:

- 등록되지 않은 route를 build하려고 하면 조용히 무시할지
- assertion / logging / custom fallback controller를 둘지

완료 기준:

- README와 테스트에 route 미등록 정책이 명시된다.

### 4. Package / 빌드 환경 정리

해야 할 일:

- iOS 전용 패키지로 플랫폼을 더 명확히 선언할지 검토
- CLI `swift test`가 macOS 환경에서 왜 막히는지 문서화
- Xcode 기준 실행 방법과 한계를 README에 짧게 정리

완료 기준:

- 사용자가 왜 CLI에서 `UIKit` 테스트가 바로 안 되는지 헷갈리지 않는다.

---

## P1

P0 다음으로 바로 가치가 큰 작업이다.

### 5. 추가 navigation 연산 설계

검토 대상:

- `remove`
- `mergeReplace`
- `backToRoot`
- `rootBackOrPush`

판단 기준:

- typed route 구조에서 자연스러운가
- coordinator 구조를 해치지 않는가
- 실전 앱에서 자주 필요한가

완료 기준:

- 가져올 연산과 제외할 연산이 정리된다.

### 6. Modal 확장 정책

검토 대상:

- nested modal 허용 여부
- `.pageSheet`, `.overFullScreen` 외 presentation style 확장
- modal stack 일반화 여부

완료 기준:

- 현재 modal을 1계층으로 유지할지, 더 일반화할지 결정된다.

### 7. UIKit-only 예제 추가

목표:

- 현재는 SwiftUI + `WrappingController` 예제 위주다.
- `UIViewController`를 직접 반환하는 registry 예제가 하나 있으면 라이브러리 성격이 더 분명해진다

완료 기준:

- SwiftUI wrapper 없이도 사용할 수 있는 예제가 추가된다.

### 8. 예제 앱 분리

현재:

- `MinimalSampleApp` 하나에 stack / modal / tab 테스트를 모두 모아뒀다.

다음 후보:

- `StackSampleApp`
- `ModalSampleApp`
- `TabSampleApp`

완료 기준:

- 개념별 예제가 분리되어 처음 보는 사람도 더 빠르게 이해할 수 있다.

---

## P2

코어가 더 안정된 뒤 보는 확장 작업이다.

### 9. Deep link parser 모듈

목표:

- URL -> typed route 변환 계층 추가

### 10. Route metadata 일반화

현재:

- `WrappingController`와 `AnyRouteIdentifiable`를 통해 route를 추적한다.

검토 방향:

- UIKit 화면 전반에서 더 일반적인 route 추적 방식 제공

### 11. 상태 복원

후보:

- 현재 stack route 저장/복원
- selected tab 복원
- modal 상태 복원

### 12. analytics / hook 포인트

후보:

- push / replace / present 시 공통 hook 제공
- 외부 analytics 모듈 연결 포인트 제공

### 13. 이벤트 계층 분리 검토

기존 LinkNavigator의 `send` 계열 기능을 그대로 넣기보다,
필요하면 별도 모듈로 두는 방향을 유지할지 검토한다.

---

## 추천 다음 순서

지금 가장 추천하는 순서는 아래다.

1. route 미등록 정책 정리
2. 탭 환경 modal 테스트 보강
3. README의 현재 구현/미지원 표 정리
4. 추가 navigation 연산 설계
5. UIKit-only 예제 추가

---

## 메모

현재 `NextNavigator`는 "컨셉 검증" 단계는 넘겼다.
이제부터 중요한 건 새로운 기능을 무작정 늘리기보다, 이미 만든 코어를 더 예측 가능하고 설명 가능하게 다듬는 것이다.
