# NextNavigator

`NextNavigator`는 UIKit controller를 코어로 두는 typed route 기반 navigation 라이브러리다.
`LinkNavigator`를 벤치마킹했지만, 문자열 path 대신 타입 기반 route와 명시적 DI를 중심으로 다시 정리하는 방향을 목표로 한다.

자세한 설계와 요구사항은 [요구사항명세서.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/요구사항명세서.md)를 보면 된다.
다음 작업 우선순위는 [TODO.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/TODO.md)에 정리돼 있다.

## 현재 상태

지금 구현된 핵심은 아래와 같다.

- typed route 기반 `Navigator`
- `RouteRegistry` / `RouteBuilder`
- explicit dependency injection
- `push`, `replace`, `back`, `backTo`, `backOrPush`
- `present`, `presentFullScreen`, `dismissModal`
- `TabNavigationHost`, `switchTab`
- `WrappingController`
- `MinimalSampleApp` 샘플 앱

아직 후순위인 항목은 아래다.

- nested modal 일반화
- `remove`, `mergeReplace`, `rootRemove` 계열 연산
- deep link parser
- state restoration
- UIKit-only 예제 확장

## 핵심 개념

- `Route`
  앱이 정의하는 typed navigation 값이다.
- `Dependencies`
  화면 생성에 필요한 외부 객체 묶음이다.
- `RouteRegistry`
  route를 어떤 화면으로 만들지 등록하는 곳이다.
- `RouteContext`
  builder에 전달되는 값으로 `route`, `navigator`, `dependencies`를 담는다.
- `Navigator`
  실제 push, pop, modal, tab 전환을 실행한다.
- `WrappingController`
  SwiftUI `View`를 `UIViewController`로 감싸는 어댑터다.

## 빠른 시작

### 1. Route 정의

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
```

### 2. Dependencies 정의

```swift
struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}
```

### 3. RouteRegistry 구성

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

### 4. Navigator 생성

```swift
let navigator = Navigator(
  dependencies: AppDependencies(
    userRepository: DefaultUserRepository(),
    analytics: DefaultAnalyticsClient()),
  registry: registry)
```

### 5. SwiftUI에 연결

단일 스택 앱:

```swift
NavigationHost(
  navigator: navigator,
  initialRoutes: [.home],
  prefersLargeTitles: true)
```

탭 앱:

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

### 6. 화면에서 호출

```swift
navigator.push(.detail(id: "42"))
navigator.present(.settings)
navigator.presentFullScreen(.settings)
navigator.back()
navigator.switchTab(tag: 1)
```

## 현재 지원 연산

### Stack

- `push(_ route:)`
- `push(_ routes:)`
- `replace(with:)`
- `back()`
- `backTo(_ route:)`
- `backOrPush(_ route:)`
- `currentRoutes()`

### Modal

- `present(_ route:)`
- `present(_ routes:)`
- `presentFullScreen(_ route:)`
- `presentFullScreen(_ routes:)`
- `dismissModal()`
- `isModalActive`

정책:

- modal은 한 번에 한 계층만 유지한다.
- 새 modal을 열면 기존 modal은 dismiss 후 교체된다.
- modal 내부에서 `back()` 호출 시 스택이 2개 이상이면 pop, 1개면 dismiss된다.

### Tab

- `switchTab(tag:)`
- `switchTab(tag:popToRootIfSelected:)`

정책:

- 각 탭은 독립 `UINavigationController`를 가진다.
- 선택된 탭이 현재 활성 스택이 된다.
- 같은 탭을 다시 선택하면 기본적으로 root로 pop한다.
- modal이 떠 있으면 modal 스택이 우선 활성 스택이 된다.

## 샘플 앱

가장 먼저 보는 걸 추천하는 파일은 아래다.

- 진입점: [SampleApp.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift)
- 라우팅 조립: [AppRouter.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRouter.swift)
- 홈 테스트 화면: [HomeView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/HomeView.swift)
- 디테일 테스트 화면: [DetailView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/DetailView.swift)
- 설정 테스트 화면: [SettingsView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SettingsView.swift)
- Xcode 프로젝트: [MinimalSampleApp.xcodeproj](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp.xcodeproj)

`MinimalSampleApp`은 단순 소개용이 아니라 연산 테스트용 샘플이다.
홈/디테일/설정 화면에서 stack, modal, tab 연산을 직접 눌러볼 수 있다.

## 참고

- 자세한 설계/요구사항: [요구사항명세서.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/요구사항명세서.md)
- 다음 작업 목록: [TODO.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/TODO.md)
- route 개념 샘플: [RouteConceptSamples/README.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/README.md)
