# NextNavigator Requirements

## 1. 문서 목적

이 문서는 `LinkNavigator`를 벤치마킹해 새로 설계하는 `NextNavigator`의 방향성과 요구사항을 정리한다.
README가 빠른 사용 설명서라면, 이 문서는 왜 이렇게 설계했는지와 앞으로 어디까지 확장할지를 설명하는 설계 문서다.

## 2. 배경

기존 `LinkNavigator`는 아래 강점을 가진다.

- path 기반 화면 이동 API가 직관적이다.
- `RouteBuilder` 패턴이 확장하기 쉽다.
- single / tab / modal을 하나의 라우팅 관점으로 다루려는 시도가 좋다.
- SwiftUI 앱에서도 사용할 수 있다.

반면 새 라이브러리를 만들 때는 아래 한계가 있다.

- 문자열 path 중심이라 타입 안정성이 약하다.
- UIKit 의존이 강하지만 구조 분리가 충분하지 않다.
- navigator 책임이 크다.
- 이벤트 버스와 네비게이션이 결합돼 있다.
- `resolve()` 캐스팅 기반 DI는 라이브러리 품질 기준으로 약하다.

## 3. 제품 비전

`NextNavigator`는 UIKit controller를 코어로 사용하는 타입 안전한 라우팅 라이브러리다.

- 화면 이동을 문자열이 아니라 타입으로 표현한다.
- `UINavigationController`, `UITabBarController`, modal 흐름을 직접 제어한다.
- 앱이 명시적으로 의존성을 주입한다.
- SwiftUI에서는 bridge로 사용할 수 있게 한다.
- 테스트 가능성과 예측 가능성을 기본 가치로 둔다.

## 4. 설계 원칙

### 4.1 Type-Safe First

- path 문자열 대신 typed route를 기본으로 둔다.
- URL/string 처리는 별도 parser 계층에서 다룬다.

### 4.2 UIKit-Core

- 코어는 `UINavigationController`, `UITabBarController`, modal presentation을 직접 다룬다.
- SwiftUI는 코어를 감싸는 bridge다.

### 4.3 Explicit Dependencies

- 의존성은 `resolve()` 같은 런타임 캐스팅이 아니라 명시적 타입으로 전달한다.

### 4.4 Small Core, Expandable Surface

- 코어는 navigation에 집중한다.
- alert, event bus, deep link parser 같은 부가 기능은 후순위다.

### 4.5 Testability by Design

- 핵심 stack 전이와 route matching은 테스트 가능해야 한다.

## 5. 핵심 문제 정의

이 라이브러리가 해결하려는 문제는 아래와 같다.

1. UIKit/SwiftUI 혼합 앱에서 복잡한 화면 이동을 일관되게 표현하기 어렵다.
2. deep link와 in-app navigation이 따로 놀기 쉽다.
3. tab, modal, stack이 함께 있는 앱에서 규칙이 흩어지기 쉽다.
4. 문자열 route와 임의 payload는 리팩터링에 취약하다.
5. 화면 생성과 의존성 주입이 섞이면 테스트가 어려워진다.

## 6. 핵심 사용자 시나리오

### 6.1 앱 개발자

- route를 enum 또는 typed value로 선언한다.
- route마다 screen factory를 등록한다.
- 루트에서 navigator를 생성하고 주입한다.
- 화면에서는 `push`, `replace`, `present`, `switchTab` 같은 명령만 호출한다.

### 6.2 아키텍처 사용 팀

- MVVM, MVI, TCA 등 어떤 구조에서도 사용할 수 있어야 한다.
- navigator를 ViewModel 또는 Environment에 주입할 수 있어야 한다.

### 6.3 테스트 작성자

- UI를 실제로 띄우지 않고도 route 전이와 stack 결과를 검증할 수 있어야 한다.

## 7. DI 방향

`NextNavigator`는 명시적 의존성 전달형 DI를 사용한다.

```swift
public struct RouteContext<Dependencies, Route> {
  public let navigator: Navigator<Dependencies, Route>
  public let route: Route
  public let dependencies: Dependencies
}
```

의미는 아래와 같다.

- 앱은 `AppDependencies`를 하나 정의한다.
- navigator 생성 시 그 값을 넘긴다.
- builder는 `context.dependencies`를 직접 사용한다.
- 서비스 로케이터나 문자열 key 조회는 사용하지 않는다.

## 8. 라우트 모델

Route는 문자열이 아니라 타입으로 표현한다.

```swift
enum AppRoute: Hashable {
  case home
  case profile(userID: String)
  case settings
}
```

장점은 아래와 같다.

- 리팩터링 안정성
- payload와 route의 결합
- path 오타 제거
- builder matching 단순화

deep link가 필요하면 별도 parser 계층에서 URL을 typed route로 바꾼다.

## 9. 아키텍처

### 9.1 Core

- `Navigator`
- `SingleStackCoordinator`
- `ModalCoordinator`
- `TabCoordinator`

역할:

- stack 제어
- modal presentation 제어
- tab 전환
- route stack 전이 규칙 수행

### 9.2 Registry

- `RouteBuilder`
- `RouteRegistry`

역할:

- route에 대응하는 화면 생성 규칙 등록

### 9.3 Adapter

- `NavigationHost`
- `TabNavigationHost`
- `WrappingController`

역할:

- SwiftUI에서 UIKit core를 사용할 수 있게 연결

### 9.4 Deep Link

후순위 계층이다.

- URL -> Route 변환

## 10. 현재 구현된 MVP 범위

### 10.1 Stack

- `push(route)`
- `push(routes)`
- `replace(routes)`
- `back()`
- `backTo(route)`
- `backOrPush(route)`
- `currentRoutes()`

정책:

- `backTo`는 마지막 일치 route 기준으로 동작한다.
- `backOrPush`는 존재하면 되돌아가고, 없으면 push한다.

### 10.2 Modal

- `present(route)`
- `present(routes)`
- `presentFullScreen(route)`
- `presentFullScreen(routes)`
- `dismissModal()`

정책:

- modal은 한 번에 한 계층만 유지한다.
- 새 modal을 열면 기존 modal은 정리 후 교체된다.
- modal 내부에서 `back()` 호출 시 스택이 2개 이상이면 pop, 1개면 dismiss된다.
- 탭 앱에서는 현재 선택된 탭 controller가 presenter가 된다.

### 10.3 Tab

- 탭별 독립 stack
- `switchTab(tag:)`
- `switchTab(tag:popToRootIfSelected:)`

정책:

- 각 탭은 독립 `UINavigationController`를 가진다.
- 같은 탭을 다시 선택하면 기본적으로 root로 복귀한다.

### 10.4 Screen Factory

- route를 화면으로 변환하는 registry
- typed route matching
- dependencies 접근

## 11. 비목표

현재 기본 범위에서 제외하는 것은 아래와 같다.

- 범용 DI 컨테이너 제공
- alert 시스템 내장
- 화면 간 이벤트 버스 내장
- 모든 UIKit presentation style 완전 지원
- 애니메이션 DSL 제공
- 완전 자동 deep link decoding

## 12. LinkNavigator에서 계승/재설계할 요소

### 계승

- route registry / builder 개념
- deep-link 스타일 이동 UX
- `backOrNext`와 유사한 고수준 명령
- single / tab / modal을 아우르는 라우팅 언어

### 재설계

- 문자열 path 중심 API
- encoded payload 직접 전달 구조
- `DependencyType.resolve()` 기반 DI
- navigator 내부 이벤트 버스
- 중복된 UIKit 로직

## 13. 현재 오픈 이슈

- route 미등록 시 fallback 정책을 어떻게 둘지
- `remove`, `mergeReplace`, `rootRemove` 계열 연산을 가져올지
- nested modal을 일반화할지
- UIKit-only 예제를 얼마나 제공할지
- analytics hook를 core에 둘지 분리할지

## 14. 성공 기준

초기 MVP가 성공했다고 볼 기준은 아래와 같다.

- typed route 기반 navigation이 안정적으로 동작한다.
- explicit DI가 실제 예제에서 자연스럽다.
- `LinkNavigator`보다 API가 읽기 쉽다.
- 핵심 controller transition 테스트가 주요 동작을 보호한다.
- SwiftUI sample에서 UIKit core 기반 root / modal / tab 흐름이 재현된다.

## 15. 한 줄 결론

`NextNavigator`는 `LinkNavigator`의 UIKit controller 중심 접근을 계승하되, 문자열 path와 약한 DI 구조를 타입 안전한 route와 명시적 DI 구조로 다시 정리하는 라이브러리다.
