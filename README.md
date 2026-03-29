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

## 설치

### Swift Package Manager

Xcode에서 추가하는 방법:

1. `File > Add Package Dependencies...`
2. 이 저장소 URL 입력
3. 원하는 version / branch / commit 선택
4. 앱 타깃에 `NextNavigator` 연결

로컬 패키지로 붙이는 방법:

1. `File > Add Package Dependencies...`
2. `Add Local...` 선택
3. `NextNavigator/Package.swift`가 있는 폴더 선택

`Package.swift`로 직접 추가하는 방법:

```swift
dependencies: [
  .package(url: "https://github.com/indextrown/NextNavigator.git", branch: "main")
]
```

```swift
targets: [
  .target(
    name: "YourApp",
    dependencies: [
      .product(name: "NextNavigator", package: "NextNavigator")
    ])
]
```

공개 저장소를 기준으로 붙일 때는 `https://github.com/indextrown/NextNavigator.git`를 사용하면 된다.
로컬에서 같이 개발 중이라면 로컬 패키지 방식이 가장 빠르다.

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

## 아키텍처

`NextNavigator`는 크게 `Core`, `Registry`, `Adapter`, `Model` 계층으로 나뉜다.

### Core

- `Navigator`
  라이브러리의 메인 진입점이다. push, back, present, tab 전환 같은 공개 연산을 제공한다.
- `SingleStackCoordinator`
  하나의 `UINavigationController` stack을 읽고 바꾸는 역할을 맡는다.
- `ModalCoordinator`
  modal용 `UINavigationController`를 만들고 present/dismiss를 담당한다.
- `TabCoordinator`
  탭별 navigation controller를 만들고 현재 탭 전환을 담당한다.
- `AnyRouteIdentifiable`
  각 화면이 어떤 route에 대응하는지 stack 안에서 추적할 수 있게 해준다.

### Registry

- `RouteRegistry`
  route를 어떤 화면으로 만들지 등록하는 장소다.
- `RouteBuilder`
  특정 route를 받아 `UIViewController`를 만드는 규칙이다.

### Adapter

- `NavigationHost`
  단일 stack `Navigator`를 SwiftUI에 올리는 bridge다.
- `TabNavigationHost`
  탭 기반 `Navigator`를 SwiftUI에 올리는 bridge다.
- `WrappingController`
  SwiftUI `View`를 UIKit controller로 감싸는 어댑터다.

### Model

- `RouteContext`
  builder에 전달되는 실행 컨텍스트다.
- `TabNavigationItem`
  탭 구성에 필요한 tag, root route, tab item 정보를 담는다.
- `ModalPresentationStyle`
  modal 표시 스타일을 추상화한 타입이다.

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

아래 시간복잡도는 현재 구현 기준의 대략적인 비용이다.

- `B`: 등록된 `RouteBuilder` 개수
- `S`: 현재 활성 `UINavigationController` stack 길이
- `R`: 한 번에 전달한 route 개수

실제 UIKit 내부 animation/presentation 비용은 별도로 있을 수 있고, 여기서는 `NextNavigator`가 수행하는 탐색과 배열 조작 비용 위주로 본다.

### Stack

- `push(_ route:)`
  - 시간복잡도: `O(B + S)`
- `push(_ routes:)`
  - 시간복잡도: `O(R * B + (S + R))`
- `replace(with:)`
  - 시간복잡도: `O(R * B + R)`
- `back()`
  - 시간복잡도: `O(1)`
- `backTo(_ route:)`
  - 시간복잡도: `O(S)`
- `backOrPush(_ route:)`
  - 시간복잡도: route가 있으면 `O(S)`, 없으면 `O(S + B)`
- `currentRoutes()`
  - 시간복잡도: `O(S)`

### Modal

- `present(_ route:)`
  - 시간복잡도: `O(B)`
- `present(_ routes:)`
  - 시간복잡도: `O(R * B + R)`
- `presentFullScreen(_ route:)`
  - 시간복잡도: `O(B)`
- `presentFullScreen(_ routes:)`
  - 시간복잡도: `O(R * B + R)`
- `dismissModal()`
  - 시간복잡도: `O(1)`
- `isModalActive`
  - 시간복잡도: `O(1)`

정책:

- modal은 한 번에 한 계층만 유지한다.
- 새 modal을 열면 기존 modal은 dismiss 후 교체된다.
- modal 내부에서 `back()` 호출 시 스택이 2개 이상이면 pop, 1개면 dismiss된다.

### Tab

- `switchTab(tag:)`
  - 시간복잡도: `O(1)`
- `switchTab(tag:popToRootIfSelected:)`
  - 시간복잡도: 탭 전환만 하면 `O(1)`, 같은 탭 재선택 후 root 복귀는 `O(S)`

정책:

- 각 탭은 독립 `UINavigationController`를 가진다.
- 선택된 탭이 현재 활성 스택이 된다.
- 같은 탭을 다시 선택하면 기본적으로 root로 pop한다.
- modal이 떠 있으면 modal 스택이 우선 활성 스택이 된다.

### 참고

- `RouteRegistry.build(route:)`는 현재 `builders.first(where:)`를 사용하므로 route 1개당 `O(B)`다.
- `backTo`와 `backOrPush`는 현재 stack에서 마지막 일치 화면을 찾기 위해 선형 탐색을 사용한다.
- `switchTab`은 탭 controller 딕셔너리 조회를 사용하므로 기본적으로 `O(1)`이다.

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
