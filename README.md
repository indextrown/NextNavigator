# NextNavigator

> Working title: `NextNavigator`
>
> 이 이름은 임시다. 실제 구현이 구체화되면 `RouteFlow`, `TypedNavigator`, `RouteStackKit` 등으로 변경할 수 있다.

## 1. 문서 목적

이 문서는 `LinkNavigator`를 벤치마킹하여 새로 설계할 라이브러리의 방향성과 요구명세를 정의한다.
현재 단계의 목표는 코드를 빨리 쓰는 것이 아니라, 이후 구현 판단의 기준이 되는 설계 원칙을 먼저 고정하는 것이다.

이 문서는 아래 역할을 한다.

- 왜 새 라이브러리를 만드는지 설명한다.
- 기존 `LinkNavigator`에서 계승할 점과 버릴 점을 구분한다.
- MVP 범위와 이후 확장 범위를 분리한다.
- 핵심 API와 DI 방식의 기준을 정한다.
- 구현 전에 테스트 전략과 폴더 구조 초안을 정한다.

---

## 2. 배경

기존 `LinkNavigator`는 아래 강점을 가진다.

- path 기반 화면 이동 API가 직관적이다.
- `RouteBuilder` 패턴이 확장하기 쉽다.
- Single / Tab / Modal 전환을 하나의 라우팅 개념으로 다루려는 시도가 좋다.
- SwiftUI 앱에서도 사용할 수 있다.

반면 새 라이브러리를 만들 때는 아래 한계가 분명하다.

- 문자열 path 중심이라 타입 안정성이 약하다.
- UIKit 의존이 강하다.
- navigator가 너무 많은 책임을 가진다.
- Single/Tab 구현 중복이 있다.
- 이벤트 버스와 네비게이션이 결합되어 있다.
- DI가 `resolve()` 캐스팅 중심이라 라이브러리 품질 기준으로는 약하다.

따라서 새 라이브러리는 `LinkNavigator`를 복제하는 것이 아니라, 다음 방향으로 재설계해야 한다.

- 타입 안정성 강화
- 책임 분리
- UIKit 코어 구조 정리
- 테스트 가능한 구조
- 단계적 확장 가능성 확보

---

## 3. 제품 비전

`NextNavigator`는 UIKit controller를 코어로 사용하는 타입 안전한 라우팅 라이브러리다.

핵심 비전은 아래와 같다.

- 화면 이동을 문자열 조합이 아니라 타입으로 표현한다.
- `UINavigationController`와 `UITabBarController`를 중심으로 실제 앱 네비게이션을 제어한다.
- 앱이 명시적으로 의존성을 주입하도록 설계한다.
- Deep link, push/pop/replace, modal, tab 전환을 일관된 모델로 다룬다.
- SwiftUI에서는 브리지로 사용할 수 있게 하되, 코어는 UIKit에 둔다.
- 테스트와 예측 가능성을 라이브러리의 기본 가치로 둔다.

---

## 4. 설계 원칙

### 4.1 Type-Safe First

- path 문자열 대신 타입화된 route를 기본값으로 둔다.
- 문자열 URL 처리는 parser 계층에서만 다룬다.

### 4.2 UIKit-Core

- 코어는 `UINavigationController`, `UITabBarController`, modal presentation 흐름을 직접 다룬다.
- SwiftUI는 코어를 감싸는 bridge 역할을 가진다.
- 기존 벤치마킹 라이브러리처럼 실제 controller stack 조작이 핵심이다.

### 4.3 Explicit Dependencies

- 의존성은 `resolve()` 캐스팅이 아니라 명시적 타입으로 전달한다.
- builder가 의존성을 숨겨서 찾지 않게 한다.

### 4.4 Small Core, Expandable Surface

- 코어는 최소 기능만 가진다.
- alert/event bus/deep link parser 같은 부가 기능은 분리 가능한 모듈 또는 후순위 기능으로 둔다.

### 4.5 Testability by Design

- 핵심 스택 전이 규칙은 controller 기반 테스트로 검증 가능해야 한다.
- builder, route matching, stack 조작 로직은 분리해서 단위 테스트 가능해야 한다.

---

## 5. 핵심 문제 정의

이 라이브러리가 해결하려는 문제는 아래와 같다.

1. UIKit/SwiftUI 혼합 앱에서 복잡한 화면 이동을 일관된 방식으로 표현하기 어렵다.
2. Deep link와 in-app navigation이 따로 놀기 쉽다.
3. Tab, modal, stack이 함께 있는 앱에서 전환 규칙이 흩어지기 쉽다.
4. 문자열 route와 임의 payload는 리팩터링에 취약하다.
5. 화면 생성과 의존성 주입이 섞이면 테스트가 어려워진다.

---

## 6. 사용자 시나리오

### 6.1 앱 개발자

- 앱 라우트를 enum 또는 typed value로 선언한다.
- 특정 route에 대응하는 screen factory를 등록한다.
- 앱 루트에서 navigator를 생성해 주입한다.
- View에서는 `push`, `replace`, `present`, `switchTab` 같은 고수준 명령을 호출한다.

### 6.2 아키텍처 사용 팀

- MVI, MVVM, TCA 등 어떤 구조에서도 사용할 수 있어야 한다.
- navigator를 ViewModel 또는 Environment에 주입할 수 있어야 한다.

### 6.3 테스트 작성자

- 실제 UI를 띄우지 않고도 route 전이와 stack 결과를 검증할 수 있어야 한다.
- mock navigator 또는 test store를 쉽게 만들 수 있어야 한다.

---

## 7. 목표

### 7.1 MVP 목표

- Typed route 기반 stack navigation
- push / pop / popTo / replace / backOrPush 지원
- modal presentation 지원
- tab container 지원
- explicit dependency injection 지원
- SwiftUI bridge 제공
- deep link parser를 붙일 수 있는 구조 제공
- 핵심 controller transition 테스트 제공

### 7.2 장기 목표

- URL -> Route parser 모듈
- state restoration
- analytics hook
- transition customization
- SwiftUI convenience layer 강화
- route guard / authorization layer

---

## 8. 비목표

초기 버전에서는 아래를 기본 범위에서 제외한다.

- 범용 DI 컨테이너 제공
- alert 시스템 내장
- 화면 간 이벤트 버스 내장
- 모든 UIKit presentation style 완전 지원
- 애니메이션 DSL 제공
- 완전 자동 deep link decoding

이유는 간단하다.
초기 버전에서 책임을 너무 넓히면 코어 설계가 흐려진다.

---

## 9. LinkNavigator에서 계승할 요소

### 유지할 개념

- route registry / builder 개념
- deep-link 스타일 이동 UX
- `backOrNext` 같은 고수준 명령
- single / tab / modal을 아우르는 라우팅 언어
- 테스트용 navigator 추상화

### 버리거나 재설계할 요소

- 문자열 path 중심 API
- encoded string payload 직접 전달 구조
- `DependencyType.resolve()` 기반 DI
- navigator 내부 이벤트 버스
- 중복된 UIKit 로직 구조
- 중복된 Single / Tab 구현

---

## 10. DI 방향성

### 10.1 선택 기준

새 라이브러리의 DI는 아래 조건을 만족해야 한다.

- 타입 안전해야 한다.
- builder에서 런타임 캐스팅을 줄여야 한다.
- 테스트 대체가 쉬워야 한다.
- 특정 DI 프레임워크에 종속되면 안 된다.

### 10.2 채택 방안

`NextNavigator`는 "명시적 의존성 전달형 DI"를 채택한다.

예상 형태:

```swift
public struct RouteContext<Dependencies, Route> {
  public let navigator: Navigator<Dependencies, Route>
  public let route: Route
  public let dependencies: Dependencies
}
```

```swift
public struct RouteBuilder<Dependencies, Route, Screen> {
  public let match: (Route) -> Bool
  public let build: (RouteContext<Dependencies, Route>) -> Screen
}
```

이 방식의 의미:

- 앱은 `AppDependencies`를 하나 정의한다.
- navigator 생성 시 `AppDependencies`를 넘긴다.
- 각 builder는 `context.dependencies`를 직접 사용한다.
- `resolve()` 같은 동적 캐스팅이 필요 없다.

### 10.3 채택하지 않는 방식

초기 버전에서는 아래 방식을 채택하지 않는다.

- 라이브러리 자체 DI 컨테이너 제공
- 서비스 로케이터 패턴
- 문자열 key 기반 의존성 조회

---

## 11. 라우트 모델 방향

### 11.1 기본 전략

Route는 문자열이 아니라 타입으로 표현한다.

예시:

```swift
enum AppRoute: Hashable {
  case home
  case profile(userID: String)
  case settings
  case signIn
}
```

### 11.2 장점

- 리팩터링 안정성
- payload와 route의 결합
- path 오타 제거
- builder matching 단순화

### 11.3 Deep link 처리

URL/string 처리는 별도 parser 계층에서 수행한다.

예시:

```swift
protocol RouteParser {
  associatedtype Route
  func parse(url: URL) -> Route?
}
```

즉, core는 typed route와 controller stack을 알고, deep link 계층만 문자열을 안다.

---

## 12. 사용법

이 섹션은 [MinimalSampleApp](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift) 예제 코드를 기준으로 설명한다.

전체 흐름은 아래 순서다.

1. route 타입을 정의한다.
2. 앱 의존성을 정의한다.
3. `RouteRegistry`에 화면 빌더를 등록한다.
4. `Navigator`를 생성한다.
5. SwiftUI에서는 `NavigationHost`로 붙인다.
6. 각 화면에서는 `navigator.push`, `navigator.present`, `navigator.back` 같은 API를 호출한다.

### 12.1 Step 1. Route 정의

먼저 앱 전체에서 사용할 route 타입을 만든다.

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
```

실제 예제 파일:

- [AppRoute.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRoute.swift)

이 단계에서 중요한 점은 route를 문자열이 아니라 타입으로 만든다는 것이다.

- `.home`처럼 단순 route를 둘 수 있다.
- `.detail(id: String)`처럼 연관값을 가진 route도 둘 수 있다.
- 이후 모든 navigation API는 이 타입을 기준으로 동작한다.

### 12.2 Step 2. Dependencies 정의

다음으로 builder에서 사용할 앱 의존성을 하나의 구조체로 묶는다.

```swift
struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}
```

예제에서는 아래처럼 간단한 프로토콜과 기본 구현을 함께 두고 있다.

```swift
protocol UserRepository {
  func displayName(for id: String) -> String
}

struct DefaultUserRepository: UserRepository {
  func displayName(for id: String) -> String {
    "User-\(id)"
  }
}
```

실제 예제 파일:

- [AppDependencies.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppDependencies.swift)

이 구조의 의미는 명확하다.

- 라이브러리가 DI 컨테이너를 제공하지 않는다.
- 앱이 필요한 의존성을 직접 조합해서 넣는다.
- 각 화면은 `RouteContext.dependencies`를 통해 이 값에 접근한다.

### 12.3 Step 3. RouteRegistry 구성

이제 route를 실제 화면으로 바꾸는 registry를 만든다.

예제의 핵심은 [AppRouter.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRouter.swift)이다.

```swift
let registry = RouteRegistry<AppDependencies, AppRoute>()
  .registering(.home) { context in
    WrappingController(route: context.route, title: "Home") {
      HomeView(navigator: context.navigator)
    }
  }
  .registering(.settings) { context in
    WrappingController(route: context.route, title: "Settings") {
      SettingsView(navigator: context.navigator)
    }
  }
```

정적 route는 `registering(_ route:)`를 쓰면 가장 간단하다.

- `.home`
- `.settings`
  처럼 값이 고정된 route에 적합하다.

연관값 route는 predicate 기반 builder를 사용한다.

```swift
let registry = RouteRegistry<AppDependencies, AppRoute>()
  .registering(
    extracting: { route in
      guard case let .detail(id) = route else { return nil }
      return id
    },
    build: { context, id in
      WrappingController(route: context.route, title: "Detail") {
        DetailView(
          userID: id,
          repository: context.dependencies.userRepository,
          navigator: context.navigator)
      }
    })
```

이 방식의 장점은 아래와 같다.

- route matching과 화면 생성이 같은 위치에 있다.
- 연관값 추출이 자연스럽다.
- builder 안에서 dependency를 바로 사용할 수 있다.
- UIKit 코어를 쓰더라도 SwiftUI 화면은 `WrappingController`로 쉽게 감쌀 수 있다.
- `matches`와 `guard case let`를 두 번 반복하지 않아도 된다.

### 12.4 Step 4. Navigator 생성

registry를 만들었다면 navigator를 조립한다.

```swift
let navigator = Navigator(
  dependencies: AppDependencies(
    userRepository: DefaultUserRepository(),
    analytics: DefaultAnalyticsClient()
  ),
  registry: registry
)
```

핵심은 두 가지다.

- 앱이 `Dependencies`를 명시적으로 만든다.
- `Navigator`는 `RouteRegistry`를 받아 실제 화면 생성에 사용한다.

예제에서는 이 조립을 `AppRouter.buildNavigator()` 안에 모아뒀다.

```swift
enum AppRouter {
  static func buildNavigator() -> Navigator<AppDependencies, AppRoute> {
    let registry = RouteRegistry<AppDependencies, AppRoute>()
    // ...

    return Navigator(
      dependencies: AppDependencies(
        userRepository: DefaultUserRepository(),
        analytics: DefaultAnalyticsClient()
      ),
      registry: registry
    )
  }
}
```

이 패턴을 쓰면 앱 시작 지점이 단순해진다.

### 12.5 Step 5. SwiftUI App에 붙이기

SwiftUI 앱에서는 `NavigationHost`로 UIKit core를 감싼다.

실제 예제는 [SampleApp.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift)와 같다.

```swift
@main
struct SampleApp: App {
  private let navigator = AppRouter.buildNavigator()

  var body: some Scene {
    WindowGroup {
      NavigationHost(
        navigator: navigator,
        initialRoutes: [.home],
        prefersLargeTitles: true)
    }
  }
}
```

여기서 각 값의 의미는 아래와 같다.

- `navigator`
  생성해둔 UIKit core navigator 인스턴스
- `initialRoutes`
  앱 시작 시 쌓을 route 목록
- `prefersLargeTitles`
  root navigation bar 설정

중요한 점은 `NavigationHost` 자체가 navigation 엔진이 아니라는 것이다.

- 실제 코어는 `Navigator`
- 실제 컨테이너는 `UINavigationController`
- `NavigationHost`는 이를 SwiftUI에 올리는 bridge

탭 기반 앱에서는 `TabNavigationHost`를 사용한다.

```swift
TabNavigationHost(
  navigator: navigator,
  items: [
    .init(
      tag: 0,
      route: .home,
      tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)
    ),
    .init(
      tag: 1,
      route: .settings,
      tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)
    ),
  ]
)
```

이때 각 탭은 독립 `UINavigationController`를 가진다.

### 12.6 Step 6. 화면에서 navigation 호출

화면에서는 `Navigator`를 직접 받아 고수준 명령을 호출한다.

예제의 [HomeView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/HomeView.swift)는 아래와 같다.

```swift
struct HomeView: View {
  let navigator: Navigator<AppDependencies, AppRoute>

  var body: some View {
    VStack(spacing: 16) {
      Button("Push Detail 42") {
        navigator.push(.detail(id: "42"))
      }

      Button("Present Settings") {
        navigator.present(.settings)
      }

      Button("Present Settings Full Screen") {
        navigator.presentFullScreen(.settings)
      }
    }
  }
}
```

이 예제에서 볼 수 있는 포인트:

- `push(.detail(id: "42"))`
  현재 stack 위에 detail 화면 push
- `present(.settings)`
  modal navigation controller를 열고 settings 화면 표시
- `presentFullScreen(.settings)`
  full screen modal로 settings 표시
- `switchTab(tag: 1)`
  특정 탭으로 이동

`DetailView`에서는 뒤로 가기와 back-or-push 예제도 보여준다.

```swift
Button("Back") {
  navigator.back()
}

Button("Back Or Push Settings") {
  navigator.backOrPush(.settings)
}
```

### 12.7 Step 7. RouteContext로 dependency 사용

builder 안에서 dependency를 쓰는 흐름도 예제에 들어 있다.

```swift
build: { context in
  // extracting 등록을 쓰면 여기까지 오기 전에 id가 이미 추출된다.
}
```

`RouteContext`에서 주로 쓰는 값은 아래 3가지다.

- `context.route`
  현재 builder가 처리 중인 typed route
- `context.navigator`
  화면에서 사용할 navigator
- `context.dependencies`
  앱이 주입한 의존성 묶음

즉, 기존 `resolve()` 방식 없이도 화면 생성 시 필요한 값이 모두 들어온다.

### 12.8 Step 8. 전체 파일 관계

예제 파일들의 역할은 아래와 같다.

- [AppRoute.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRoute.swift)
  앱 전체 route 정의
- [AppDependencies.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppDependencies.swift)
  앱 의존성 정의
- [AppRouter.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRouter.swift)
  registry 구성과 navigator 조립
- [HomeView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/HomeView.swift)
  push / present 예제
- [DetailView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/DetailView.swift)
  dependency 사용, back / backOrPush 예제
- [SettingsView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SettingsView.swift)
  modal에서 닫기 또는 back 예제
- [SampleApp.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift)
  SwiftUI 앱 시작점

### 12.9 빠른 시작 요약

처음 붙일 때는 아래 순서만 기억하면 된다.

1. `enum AppRoute: Hashable` 만든다.
2. `struct AppDependencies` 만든다.
3. `RouteRegistry`에 각 화면을 등록한다.
4. `Navigator(dependencies:registry:)`를 만든다.
5. SwiftUI에서는 `NavigationHost`에 넣는다.
6. 화면에서는 `navigator.push`, `navigator.present`, `navigator.back`를 호출한다.

### 12.10 최소 샘플 코드 위치

최소 샘플 앱 코드는 아래 경로에 추가되어 있다.

- Xcode 프로젝트: [MinimalSampleApp.xcodeproj](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp.xcodeproj)
- [AppRoute.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRoute.swift)
- [AppDependencies.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppDependencies.swift)
- [AppRouter.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRouter.swift)
- [HomeView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/HomeView.swift)
- [DetailView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/DetailView.swift)
- [SettingsView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SettingsView.swift)
- [SampleApp.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift)

Xcode에서 실행할 때는 `MinimalSampleApp.xcodeproj`를 열고 `MinimalSampleApp` 스킴을 선택한 뒤 iOS Simulator에서 실행하면 된다.

연관값 route가 왜 필요한지 헷갈리면 아래 비교 샘플도 같이 보면 이해가 쉽다.

- [RouteConceptSamples/README.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/README.md)
- [01-FixedScreenRoutes.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/01-FixedScreenRoutes.swift)
- [02-DetailRouteWithID.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/02-DetailRouteWithID.swift)
- [03-RouteWithMultipleValues.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/03-RouteWithMultipleValues.swift)

---

## 13. 아키텍처 초안

### 13.1 Core 계층

역할:

- `UINavigationController` stack 제어
- modal presentation 제어
- tab root controller 관리
- route stack 전이 규칙 수행

후보 타입:

- `Navigator`
- `SingleStackCoordinator`
- `TabCoordinator`
- `ModalCoordinator`

### 13.2 Registry 계층

역할:

- route에 대응하는 screen factory 등록

후보 타입:

- `RouteBuilder`
- `RouteRegistry`

### 13.3 Adapter 계층

역할:

- SwiftUI에서 UIKit core를 사용할 수 있게 연결

후보 타입:

- `NavigationHost`
- `TabNavigationHost`
- `WrappingController`

### 13.4 Deep Link 계층

역할:

- URL -> Route 변환

---

## 14. 핵심 타입 초안

아래는 확정 코드가 아니라 설계 초안이다.

```swift
public final class Navigator<Dependencies, Route: Hashable> {
  public let dependencies: Dependencies

  public init(
    dependencies: Dependencies
  ) {
    self.dependencies = dependencies
  }

  public weak var rootController: UINavigationController?
  public var modalController: UINavigationController?

  public func launch(_ routes: [Route]) -> [UIViewController] { [] }
  public func push(_ route: Route, animated: Bool) { }
  public func push(_ routes: [Route], animated: Bool) { }
  public func replace(with routes: [Route], animated: Bool) { }
  public func back(animated: Bool) { }
  public func backTo(_ route: Route, animated: Bool) { }
  public func backOrPush(_ route: Route, animated: Bool) { }
  public func present(_ route: Route, animated: Bool) { }
  public func dismissModal(animated: Bool) { }
}
```

```swift
public struct RouteContext<Dependencies, Route: Hashable> {
  public let navigator: Navigator<Dependencies, Route>
  public let route: Route
  public let dependencies: Dependencies
}
```

주의:

- Tab 표현은 route를 탭 키로도 쓸지, 별도 `TabID`를 둘지 추후 결정 필요
- 코어는 상태 저장소보다 controller coordinator 성격이 강하다
- 다만 route stack 계산 로직은 helper 계층으로 분리해 테스트 가능하게 유지한다

---

## 15. MVP 기능 명세

### 15.1 Stack Navigation

필수 지원:

- `push(route)`
- `push(routes)`
- `back()`
- `backTo(route)`
- `replace(routes)`
- `backOrPush(route)`

조건:

- route 비교는 `Hashable` 또는 `Equatable`에 기반한다.
- 중복 route 존재 시 `backTo` 기준은 명확히 정의해야 한다.
- `backOrPush`는 "마지막 일치 route로 이동"을 기본 정책으로 한다.
- 실제 스택 조작은 `UINavigationController.viewControllers` 교체 또는 pop/push 기반으로 수행한다.

### 15.2 Modal Navigation

필수 지원:

- `present(route)`
- `present(routes)`
- `presentFullScreen(route)`
- `dismissModal()`
- modal 내부 push/back

조건:

- 초기 버전은 모달 1계층만 지원한다.
- nested modal은 추후 확장으로 둔다.
- modal은 별도 `UINavigationController`를 present하는 구조를 기본으로 한다.
- 새 modal을 열면 기존 modal은 먼저 정리하고 교체한다.
- modal 내부에서 `back()` 호출 시 스택이 2개 이상이면 pop, 1개면 dismiss 한다.

### 15.3 Tab Navigation

필수 지원:

- 탭별 독립 stack
- 탭 전환
- 현재 탭 root 복귀 옵션

조건:

- 초기 버전은 고정 탭 구성만 지원한다.
- 동적 탭 추가/삭제는 후순위다.
- 각 탭은 독립 `UINavigationController`를 가진다.
- 같은 탭을 다시 선택하면 기본적으로 root로 복귀한다.

### 15.4 Screen Factory

필수 지원:

- route를 화면으로 변환하는 registry
- typed route matching
- dependencies 접근

---

## 16. API 사용 예시 목표

개발자가 최종적으로 느끼는 경험은 아래와 비슷해야 한다.

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}

struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}

let navigator = Navigator(
  dependencies: AppDependencies(
    userRepository: DefaultUserRepository(),
    analytics: DefaultAnalyticsClient()
  )
)
```

```swift
let registry = RouteRegistry<AppDependencies, AppRoute>()
  .register(.home) { context in
    HomeView(navigator: context.navigator)
  }
  .register(.detail) { context in
    switch context.route {
    case let .detail(id):
      DetailView(id: id, repository: context.dependencies.userRepository)
    default:
      EmptyView()
    }
  }
```

핵심은 아래다.

- route가 타입이다.
- 의존성이 명시적이다.
- 화면 생성이 읽기 쉽다.

---

## 17. 테스트 요구사항

초기 버전부터 아래 테스트는 필수다.

### Core State Tests

- push 시 controller stack 증가
- back 시 마지막 controller 제거
- replace 시 전체 교체
- backTo 시 마지막 일치 route로 복귀
- backOrPush 시 존재하면 복귀, 없으면 push
- modal present / dismiss 전이
- tab switch 시 stack 유지

### Registry Tests

- route와 builder 매칭 검증
- 잘못된 route에 대한 fallback 정책 검증

### Integration Tests

- SwiftUI host가 UIKit core를 정상 연결하는지
- root / modal / tab 흐름 연결 검증

---

## 18. 폴더 구조 초안

초기 작업 구조는 아래를 기준으로 한다.

```text
NextNavigator/
  README.md
  Package.swift
  Sources/
    NextNavigator/
      Core/
      Registry/
      Adapter/
      Model/
      Testing/
  Tests/
    NextNavigatorTests/
```

### 폴더별 역할

- `Core`
  - navigator, coordinators, stack helpers
- `Registry`
  - route builder, route registry
- `Adapter`
  - SwiftUI host, UIKit bridge helpers
- `Model`
  - route context, tab item, modal config
- `Testing`
  - mock navigator, test helpers

---

## 19. 개발 단계 계획

### Phase 1. 명세 고정

- README 요구명세 작성
- 용어 통일
- 핵심 타입 초안 합의

### Phase 2. Core 구현

- `Navigator`
- single stack coordinator
- modal coordinator
- core tests

### Phase 3. Registry 구현

- typed route builder
- route registry
- build pipeline

### Phase 4. SwiftUI Adapter

- `NavigationHost`
- `UIViewControllerRepresentable` bridge
- modal / tab 연결

### Phase 5. Sample App

- single stack sample
- tab sample
- deep link sample

---

## 20. 의사결정 로그

### Decision 1. DI는 명시적 전달형을 사용한다

이유:

- 타입 안정성
- 테스트 용이성
- 불필요한 런타임 캐스팅 제거

### Decision 2. Route는 타입 기반으로 설계한다

이유:

- path 문자열 오타 제거
- payload를 route와 함께 표현 가능
- 리팩터링 안정성 증가

### Decision 3. Core는 UIKit controller 중심으로 설계한다

이유:

- 벤치마킹 대상과 동일한 문제 영역을 직접 다룰 수 있음
- 실제 앱 네비게이션 제어와 구현 간 거리가 짧음
- SwiftUI는 브리지로 충분히 지원 가능

### Decision 4. 이벤트 버스는 초기 범위에서 제외한다

이유:

- 네비게이션 코어와 책임 분리
- 초기 설계 단순화

---

## 21. 오픈 이슈

아직 확정되지 않은 항목:

- route registry를 enum case matching 중심으로 설계할지, predicate 기반으로 열어둘지
- tab 식별자를 route와 분리할지
- SwiftUI host를 얼마나 얇게 둘지
- modal을 state 한 계층만 둘지, stack of presentations로 일반화할지
- analytics hook를 core에 둘지 adapter/plugin으로 뺄지

이 이슈들은 구현 직전에 다시 확정한다.

---

## 22. 다음 액션

이 문서 다음 단계의 우선순위는 아래다.

1. `Package.swift` 생성
2. `Sources/NextNavigator` 기본 구조 생성
3. `Navigator`와 coordinator 최소 구현
4. stack transition 테스트 작성
5. sample route와 sample registry 구성

---

## 23. 성공 기준

초기 MVP가 성공했다고 판단할 기준은 아래와 같다.

- 타입 안전한 route 기반 navigation이 동작한다.
- 명시적 DI 방식이 실제 예제에서 자연스럽다.
- `LinkNavigator`보다 API가 읽기 쉽다.
- core tests가 주요 controller 전이 규칙을 보장한다.
- SwiftUI sample에서 UIKit core 기반 root / modal / tab 흐름이 재현된다.

---

## 24. 한 줄 결론

`NextNavigator`는 `LinkNavigator`의 UIKit controller 중심 접근을 계승하되, 문자열 path와 약한 DI 구조는 개선하고, 타입 안전성과 구조 정리를 핵심으로 다시 만드는 라이브러리다.

---

## 25. 전체 개념 정리

이 섹션은 문서 전체를 다 읽은 뒤 마지막에 빠르게 다시 정리할 수 있도록 만든 요약이다.

### 25.1 이 라이브러리는 무엇인가

`NextNavigator`는 UIKit controller를 코어로 두는 navigation 라이브러리다.

핵심은 아래와 같다.

- route를 문자열이 아니라 타입으로 다룬다.
- `UINavigationController`와 `UITabBarController`를 실제로 제어한다.
- 화면 생성은 `RouteRegistry`와 `RouteBuilder`가 담당한다.
- 의존성은 `RouteContext`를 통해 명시적으로 전달한다.
- SwiftUI에서는 `NavigationHost` 같은 bridge를 통해 사용한다.

즉, 이 라이브러리는 "typed route + UIKit stack control + explicit DI" 조합이라고 보면 된다.

### 25.2 핵심 타입 한 번에 보기

- `Route`
  앱이 정의하는 typed navigation 값이다. 예: `AppRoute.home`, `AppRoute.detail(id:)`
- `Dependencies`
  앱이 화면 생성에 필요한 외부 의존성을 묶은 타입이다.
- `RouteRegistry`
  route를 어떤 화면으로 만들지 등록하는 장소다.
- `RouteBuilder`
  특정 route를 실제 `UIViewController`로 바꾸는 규칙이다.
- `RouteContext`
  builder에 전달되는 컨텍스트다. `route`, `navigator`, `dependencies`를 담는다.
- `Navigator`
  실제 navigation 명령을 수행하는 코어 객체다.
- `WrappingController`
  SwiftUI `View`를 `UIViewController`로 감싸는 편의 타입이다.
- `NavigationHost`
  SwiftUI에서 UIKit core navigator를 올려주는 bridge다.

### 25.3 내부 동작 구조

사용자가 `navigator.push(.detail(id: "42"))`를 호출하면 내부적으로는 아래 흐름으로 움직인다.

1. `Navigator`가 route를 받는다.
2. `RouteRegistry`가 해당 route를 처리할 builder를 찾는다.
3. builder는 `RouteContext`를 받아 `UIViewController`를 만든다.
4. `Navigator`는 그 controller를 `UINavigationController` stack에 push하거나 replace한다.

즉, route는 "이동 의도"이고, registry는 "화면 생성 규칙"이며, navigator는 "실제 이동 실행기"다.

### 25.4 LinkNavigator와 가장 큰 차이

- 문자열 path 대신 typed route를 쓴다.
- `resolve()` 기반 DI 대신 명시적 dependency 전달을 쓴다.
- UIKit core를 유지하지만 구조를 더 분리한다.
- route matching과 화면 생성 규칙을 더 명확하게 분리한다.

---

## 26. 사용자는 어떻게 쓰는가

실제 사용자는 아래 순서대로 이 라이브러리를 붙이면 된다.

### 26.1 1단계. Route 타입을 만든다

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
```

앱에서 이동 가능한 모든 화면 상태를 여기에 정의한다.

### 26.2 2단계. Dependencies 타입을 만든다

```swift
struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}
```

화면 생성에 필요한 외부 객체를 한 군데 모은다.

### 26.3 3단계. RouteRegistry를 만든다

```swift
let registry = RouteRegistry<AppDependencies, AppRoute>()
  .registering(.home) { context in
    WrappingController(route: context.route) {
      HomeView(navigator: context.navigator)
    }
  }
```

각 route가 어떤 화면으로 생성되는지 등록한다.

### 26.4 4단계. Navigator를 만든다

```swift
let navigator = Navigator(
  dependencies: appDependencies,
  registry: registry
)
```

이 객체가 앱 전역 navigation의 중심이 된다.

### 26.5 5단계. 앱 시작점에 연결한다

SwiftUI에서는 `NavigationHost`로 연결한다.

```swift
NavigationHost(
  navigator: navigator,
  initialRoutes: [.home]
)
```

이 시점부터 root `UINavigationController`가 준비된다.

### 26.6 6단계. 화면에서 navigator를 호출한다

```swift
navigator.push(.detail(id: "42"))
navigator.present(.settings)
navigator.back()
```

이렇게 화면이나 ViewModel에서 고수준 명령을 호출하면 된다.

### 26.7 7단계. 연관값 route와 dependency를 builder에서 사용한다

```swift
.registering(
  extracting: { route in
    guard case let .detail(id) = route else { return nil }
    return id
  },
  build: { context, id in
    WrappingController(route: context.route) {
      DetailView(
        userID: id,
        repository: context.dependencies.userRepository,
        navigator: context.navigator
      )
    }
  })
```

이 패턴으로 typed route와 dependency를 동시에 활용할 수 있다.

### 26.8 사용자의 머릿속 모델

사용자는 아래처럼 이해하면 된다.

- route를 만든다.
- dependencies를 만든다.
- registry에 route별 화면 생성을 등록한다.
- navigator를 만든다.
- host에 붙인다.
- 화면에서 navigator 메서드를 호출한다.

즉, "화면을 직접 push하는 것"이 아니라 "route를 navigator에 전달하는 것"이 이 라이브러리의 사용 방식이다.

### 26.9 가장 짧은 체크리스트

처음 도입할 때는 이것만 보면 된다.

1. `AppRoute` 만들었는가
2. `AppDependencies` 만들었는가
3. `RouteRegistry`에 화면 등록했는가
4. `Navigator`를 조립했는가
5. `NavigationHost`에 연결했는가
6. 화면에서 `navigator.push/present/back`를 호출하고 있는가

---

## 27. 실사용 가이드

이 섹션은 지금까지 구현된 `NextNavigator`를 실제 사용자가 어떻게 붙이고, 어떤 연산을 호출하면 되는지 한 번에 보기 위한 요약이다.

### 27.1 가장 먼저 이해할 구조

`NextNavigator`는 아래 순서로 동작한다.

1. 앱이 `Route`를 정의한다.
2. 앱이 `Dependencies`를 정의한다.
3. 앱이 `RouteRegistry`에 route별 화면 생성 규칙을 등록한다.
4. 앱이 `Navigator`를 만든다.
5. 앱 시작점에서 `NavigationHost` 또는 `TabNavigationHost`에 연결한다.
6. 각 화면은 `navigator.push(...)`, `navigator.present(...)` 같은 메서드만 호출한다.

즉 사용자는 직접 `UIViewController`를 push하는 대신, `Route`를 넘겨서 이동을 요청한다.

### 27.2 가장 기본 사용 순서

#### 1. Route 정의

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
```

- 화면이 하나뿐이면 `.home`, `.settings`처럼 단순 case로 충분하다.
- 화면마다 대상이 달라지면 `.detail(id:)`처럼 연관값을 사용한다.

#### 2. Dependencies 정의

```swift
struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}
```

- 화면 생성에 필요한 외부 객체를 한 곳에 모은다.
- builder에서는 `context.dependencies`로 꺼내 쓴다.

#### 3. RouteRegistry 정의

```swift
let registry = RouteRegistry<AppDependencies, AppRoute>()
  .registering(.home) { context in
    WrappingController(route: context.route, title: "Home") {
      HomeView(navigator: context.navigator)
    }
  }
  .registering(
    extracting: { (route: AppRoute) -> String? in
      guard case let .detail(id) = route else { return nil }
      return id
    },
    build: { context, id in
      WrappingController(route: context.route, title: "Detail") {
        DetailView(
          userID: id,
          repository: context.dependencies.userRepository,
          navigator: context.navigator)
      }
    })
  .registering(.settings) { context in
    WrappingController(route: context.route, title: "Settings") {
      SettingsView(navigator: context.navigator)
    }
  }
```

- `.registering(.home)`는 고정 route 등록이다.
- `.registering(extracting:)`는 연관값 route를 등록할 때 쓴다.
- `WrappingController`는 SwiftUI View를 `UIViewController`로 감싸 `UINavigationController`에 넣기 위한 어댑터다.

#### 4. Navigator 조립

```swift
let navigator = Navigator(
  dependencies: AppDependencies(
    userRepository: DefaultUserRepository(),
    analytics: DefaultAnalyticsClient()),
  registry: registry)
```

- `Navigator`는 실제 push, pop, modal, tab 전환을 담당한다.
- 이 객체를 앱에서 공유해서 사용한다.

#### 5. 앱 시작점에 연결

단일 스택 앱이면 `NavigationHost`를 사용한다.

```swift
NavigationHost(
  navigator: navigator,
  initialRoutes: [.home],
  prefersLargeTitles: true)
```

탭 앱이면 `TabNavigationHost`를 사용한다.

```swift
TabNavigationHost(
  navigator: navigator,
  items: [
    .init(
      tag: 0,
      route: .home,
      tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
    .init(
      tag: 1,
      route: .settings,
      tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1))
  ])
```

### 27.3 화면에서 어떻게 호출하는가

화면이나 ViewModel은 `Navigator`만 알고 있으면 된다.

```swift
struct HomeView: View {
  let navigator: Navigator<AppDependencies, AppRoute>

  var body: some View {
    VStack {
      Button("Detail 42") {
        navigator.push(.detail(id: "42"))
      }

      Button("Settings Modal") {
        navigator.present(.settings)
      }

      Button("Settings Full Screen") {
        navigator.presentFullScreen(.settings)
      }
    }
  }
}
```

상세 화면에서는 뒤로 가기만 호출하면 된다.

```swift
Button("Back") {
  navigator.back()
}
```

### 27.4 현재 지원하는 Navigator 연산

아래는 지금 코드에 실제로 구현되어 있는 연산 목록이다.

#### Stack

`push(_ route:)`

- route 하나를 현재 활성 스택에 push한다.

```swift
navigator.push(.settings)
```

`push(_ routes:)`

- 여러 route를 순서대로 build해서 현재 스택 뒤에 붙인다.

```swift
navigator.push([.home, .detail(id: "42")])
```

`replace(with:)`

- 현재 활성 스택 전체를 새 route 배열로 교체한다.

```swift
navigator.replace(with: [.home, .detail(id: "42")])
```

`back()`

- 현재 활성 스택에서 한 단계 뒤로 간다.
- modal 내부 스택이 1개뿐이면 pop 대신 modal dismiss가 일어난다.

```swift
navigator.back()
```

`backTo(_ route:)`

- 현재 활성 스택에서 마지막으로 일치하는 route가 있는 화면까지 pop한다.

```swift
navigator.backTo(.home)
```

`backOrPush(_ route:)`

- 현재 활성 스택에 해당 route가 있으면 그 위치까지 되돌아간다.
- 없으면 새로 push한다.

```swift
navigator.backOrPush(.settings)
```

`currentRoutes()`

- 현재 활성 스택에 들어 있는 route 목록을 가져온다.
- 디버깅, 테스트, 상태 확인 용도다.

```swift
let routes = navigator.currentRoutes()
```

#### Modal

`present(_ route:)`

- route 하나를 새 modal navigation stack의 root로 띄운다.

```swift
navigator.present(.settings)
```

`present(_ routes:)`

- route 배열을 새 modal navigation stack으로 띄운다.

```swift
navigator.present([.home, .detail(id: "42")])
```

`presentFullScreen(_ route:)`

- route 하나를 full screen modal로 띄운다.

```swift
navigator.presentFullScreen(.settings)
```

`presentFullScreen(_ routes:)`

- route 배열을 full screen modal로 띄운다.

```swift
navigator.presentFullScreen([.home, .settings])
```

`dismissModal()`

- 현재 modal을 닫는다.

```swift
navigator.dismissModal()
```

`isModalActive`

- 현재 modal이 떠 있는지 확인한다.

```swift
if navigator.isModalActive {
  navigator.dismissModal()
}
```

현재 modal 정책은 아래와 같다.

- modal은 한 번에 한 계층만 유지한다.
- 새 modal을 띄우면 기존 modal은 먼저 dismiss되고 새 modal로 교체된다.
- modal 내부에서 `back()` 호출 시 스택이 2개 이상이면 pop, 1개면 dismiss된다.

#### Tab

`switchTab(tag:)`

- 특정 tag의 탭으로 전환한다.

```swift
navigator.switchTab(tag: 1)
```

`switchTab(tag:popToRootIfSelected:)`

- 같은 탭을 다시 선택했을 때 root로 되돌릴지 제어할 수 있다.

```swift
navigator.switchTab(tag: 1, popToRootIfSelected: false)
```

현재 tab 정책은 아래와 같다.

- 각 탭은 독립 `UINavigationController`를 가진다.
- 선택된 탭의 controller가 현재 활성 스택으로 취급된다.
- 같은 탭을 다시 선택하면 기본적으로 root로 pop한다.
- modal이 떠 있으면 modal 스택이 우선 활성 스택이 된다.

### 27.5 RouteRegistry 등록 패턴

실제로 가장 많이 쓰는 등록 패턴은 세 가지다.

#### 고정 route 등록

```swift
.registering(.settings) { context in
  WrappingController(route: context.route, title: "Settings") {
    SettingsView(navigator: context.navigator)
  }
}
```

#### 조건 기반 등록

```swift
.registering(
  matching: { route in
    if case .detail = route { return true }
    return false
  },
  build: { context in
    guard case let .detail(id) = context.route else { return nil }
    return WrappingController(route: context.route, title: "Detail") {
      DetailView(
        userID: id,
        repository: context.dependencies.userRepository,
        navigator: context.navigator)
    }
  })
```

#### 값 추출 기반 등록

```swift
.registering(
  extracting: { (route: AppRoute) -> String? in
    guard case let .detail(id) = route else { return nil }
    return id
  },
  build: { context, id in
    WrappingController(route: context.route, title: "Detail") {
      DetailView(
        userID: id,
        repository: context.dependencies.userRepository,
        navigator: context.navigator)
    }
  })
```

실무에서는 연관값 route가 많다면 `extracting` 기반 등록이 가장 읽기 쉽다.

### 27.6 언제 어떤 route 형태를 쓰는가

고정 화면이면 단순 case가 맞다.

```swift
case home
case settings
case login
```

대상이 달라지는 화면이면 연관값 route가 맞다.

```swift
case detail(id: String)
case profile(userID: String)
case post(id: Int)
```

즉 기준은 "이 화면이 하나뿐인가"가 아니라 "이 화면이 어떤 대상을 보여줘야 하는가"이다.

### 27.7 사용자가 기억하면 되는 한 줄

`NextNavigator`는 화면을 직접 만드는 네비게이션 라이브러리가 아니라, `Route`를 정의하고 `RouteRegistry`에 화면 생성 규칙을 등록한 뒤 `Navigator`에 route를 넘겨 이동하는 라이브러리다.
