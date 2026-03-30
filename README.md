# NextNavigator

`NextNavigator`는 UIKit controller를 코어로 두는 typed route 기반 navigation 라이브러리다.
`LinkNavigator`를 벤치마킹했지만, 문자열 path 대신 타입 기반 route와 명시적 DI를 중심으로 다시 정리하는 방향을 목표로 한다.

자세한 설계와 요구사항은 [REQUIREMENTS.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/REQUIREMENTS.md)를 보면 된다.
다음 작업 우선순위는 [TODO.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/TODO.md)에 정리돼 있다.

## 왜 UIKit 엔진 기반인가

핵심은 이거다.

SwiftUI의 `NavigationStack`은 "화면을 선언적으로 쌓는 것"에는 좋지만, 실제 앱에서 필요한 **복잡한 navigation을 명시적으로 통제하는 엔진**으로 쓰기에는 아쉬움이 있다.
`NextNavigator`는 그 아쉬움을 해결하기 위해 navigation 엔진을 UIKit 기반으로 두었다.

### `NavigationStack`만으로 갈 때 아쉬운 점

- `NavigationStack`은 "지금 어떤 화면들이 쌓였는가"를 표현하는 데는 좋지만, "지금 어느 navigation 엔진이 활성인가"를 다루는 개념은 약하다.
- `ObservableObject` 기반 navigation container를 두고 `@Published path`로 stack을 관리하면, path 변경이 view update의 트리거가 되어 원치 않는 `body` 재평가가 여러 스택이나 상위 컨테이너까지 퍼질 수 있다.
- 실제 앱은 push만 있는 게 아니라 tab, modal, deep link, back 정책이 함께 움직이는데, 이걸 하나의 명시적인 제어 계층으로 묶기 어렵다.
- `backTo`, `backOrPush`, `present`, `switchTab` 같은 imperative한 동작은 결국 화면 상태 표현만으로는 부족하고, 별도의 navigation 제어 로직이 필요해진다.
- 탭마다 독립 stack 유지, modal 위에 별도 stack 유지, 현재 활성 stack 우선순위 같은 규칙을 직접 통제하려면 UIKit 쪽이 더 직관적이다.
- 즉 문제의 핵심은 `NavigationStack`이 부족해서가 아니라, **복잡한 앱 navigation의 오케스트레이션을 전담하기엔 추상화 레벨이 다르다**는 점이다.

### 그래서 `NextNavigator`는 이렇게 선택했다

`NextNavigator`는 화면 UI는 SwiftUI로 만들 수 있게 두되, navigation의 실제 엔진은 `UINavigationController`, `UITabBarController`, modal presentation 위에 올렸다.

이렇게 하면 아래가 더 명확해진다.

- push/pop stack 제어를 `UINavigationController` 기준으로 직접 다룰 수 있다.
- modal을 별도 navigation stack으로 분리해서 관리할 수 있다.
- tab마다 독립된 navigation controller를 둘 수 있다.
- 현재 활성 stack이 root인지, tab인지, modal인지 우선순위를 명확하게 정할 수 있다.
- deep link도 결국 "어느 stack에 어떤 action으로 반영할지"를 하나의 navigator API로 모을 수 있다.

즉 `NextNavigator`는 SwiftUI의 선언형 화면 작성은 활용하되, **복잡한 navigation에서는 상태 표현보다 엔진 제어가 더 중요하다**고 보고 UIKit을 코어로 선택한 라이브러리다.

## 핵심 기능

- 타입 기반 라우팅
  - 문자열 path 대신 `enum` 기반 route로 화면 이동을 표현한다.
- UIKit 코어 네비게이션
  - `UINavigationController`, `UITabBarController`, modal presentation을 직접 제어한다.
- 명시적 의존성 주입
  - `RouteContext`를 통해 `navigator`, `route`, `dependencies`를 함께 전달한다.
- RouteRegistry 기반 화면 생성
  - route마다 어떤 화면을 만들지 registry에 등록하고, builder가 `UIViewController`를 생성한다.
- Stack / Modal / Tab 통합 연산
  - `push`, `replace`, `back`, `backTo`, `backOrPush`, `present`, `dismissModal`, `switchTab`을 일관된 API로 제공한다.
- SwiftUI 브리지
  - `NavigationHost`, `TabNavigationHost`, `WrappingController`로 SwiftUI 화면을 UIKit 스택에 연결할 수 있다.
- 딥링크 진입점
  - `DeepLinkParser`와 `navigator.handle(url:parser:)`로 custom scheme, universal link를 route로 연결할 수 있다.
- 샘플 앱 제공
  - `MinimalSampleApp`에서 stack, modal, tab, deep link, MVVM 기반 화면 흐름을 직접 눌러볼 수 있다.

## 현재 상태

지금 구현된 핵심은 아래와 같다.

- typed route 기반 `Navigator`
- `RouteRegistry` / `RouteBuilder`
- explicit dependency injection
- `push`, `replace`, `back`, `backTo`, `backOrPush`
- `present`, `presentFullScreen`, `dismissModal`
- `TabNavigationHost`, `switchTab`
- typed deep link handling entry points
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
  .package(url: "https://github.com/indextrown/NextNavigator.git", from: "1.0.0")
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

공개 저장소를 기준으로 붙일 때는 `https://github.com/indextrown/NextNavigator.git`와 `from: "1.0.0"` 조합을 사용하면 된다.
로컬에서 같이 개발 중이라면 로컬 패키지 방식이 가장 빠르다.

## 사용법

처음 붙일 때는 아래 순서대로 하면 된다.

### 1. Route를 만든다

```swift
enum AppRoute: Hashable {
  case home
  case detail(id: String)
  case settings
}
```

- 고정 화면이면 `.home`, `.settings`처럼 단순 case를 쓴다.
- 대상이 달라지는 화면이면 `.detail(id:)`처럼 연관값을 쓴다.

### 2. Dependencies를 만든다

```swift
struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}
```

- 화면 생성에 필요한 외부 객체를 한 곳에 모은다.
- builder 안에서는 `context.dependencies`로 접근한다.

### 3. RouteRegistry에 화면 생성 규칙을 등록한다

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
```

- `registering(.home)`는 고정 route 등록이다.
- `registering(extracting:)`는 `.detail(id:)` 같은 연관값 route 등록에 쓴다.

### 4. Navigator를 만든다

```swift
let navigator = Navigator(
  dependencies: AppDependencies(
    userRepository: DefaultUserRepository(),
    analytics: DefaultAnalyticsClient()),
  registry: registry)
```

- 이 객체가 실제 네비게이션의 중심이다.
- 화면에서는 `UIViewController`를 직접 다루지 않고, 이 navigator만 호출하면 된다.

### 5. 앱 시작점에 연결한다

단일 stack 앱:

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

### 6. 화면에서 navigator를 호출한다

```swift
navigator.push(.detail(id: "42"))
navigator.present(.settings)
navigator.presentFullScreen(.settings)
navigator.back()
navigator.switchTab(tag: 1)
```

자주 쓰는 의미는 이렇다.

- `push`
  현재 stack 뒤에 화면 추가
- `replace`
  현재 stack 전체 교체
- `back`
  한 단계 뒤로 가기
- `backTo`
  특정 route가 있는 위치까지 되돌아가기
- `backOrPush`
  있으면 되돌아가고, 없으면 새로 push
- `present`
  modal로 열기
- `switchTab`
  특정 탭으로 이동

### 7. 딥링크를 붙이고 싶으면 parser를 구현한다

```swift
struct AppDeepLinkParser: DeepLinkParser {
  func parse(url: URL) -> DeepLink<AppRoute>? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return nil
    }

    switch components.host {
    case "home":
      return DeepLink(route: .home, action: .replace)
    case "detail":
      let id = components.queryItems?.first(where: { $0.name == "id" })?.value ?? ""
      guard !id.isEmpty else { return nil }
      return DeepLink(route: .detail(id: id), action: .push)
    default:
      return nil
    }
  }
}
```

```swift
.onOpenURL { url in
  navigator.handle(url: url, parser: AppDeepLinkParser())
}
```

### 8. 딥링크와 유니버설 링크 설정

`NextNavigator`는 URL을 직접 등록해주지는 않는다.
앱이 URL을 받을 수 있게 iOS 설정을 해주고, 받은 URL을 parser에 넘기는 구조다.

#### 커스텀 스킴 딥링크

예:

- `nextnavigator://home`
- `nextnavigator://detail?id=42`

설정 순서:

1. Xcode에서 앱 target 선택
2. `Info` 탭 이동
3. `URL Types` 추가
4. `Identifier`는 예: `io.nextnavigator.minimalsampleapp` 입력
5. `URL Schemes`에는 전체 URL이 아니라 scheme만 입력
6. 예: `nextnavigator`

그 다음 SwiftUI 앱 시작점에서:

```swift
.onOpenURL { url in
  navigator.handle(url: url, parser: AppDeepLinkParser())
}
```

시뮬레이터 실행 순서:

1. Xcode에서 `MinimalSampleApp`을 iPhone Simulator로 한 번 실행한다.
2. 시뮬레이터가 켜진 상태를 확인한다.
3. 아래 명령으로 URL을 앱에 보낸다.

시뮬레이터 테스트:

```bash
xcrun simctl openurl booted "nextnavigator://home"
xcrun simctl openurl booted "nextnavigator://detail?id=42"
xcrun simctl openurl booted "nextnavigator://settings"
```

`No devices are booted.`가 나오면 아직 시뮬레이터가 실행되지 않은 상태다.
먼저 Xcode에서 앱을 실행한 뒤 다시 시도하면 된다.

`OSStatus error -10814`가 나오면 보통 아래 둘 중 하나다.

- `URL Schemes`에 `nextnavigator`가 등록되지 않음
- 등록 후 앱을 다시 빌드/실행하지 않음

#### 유니버설 링크

예:

- `https://example.com/home`
- `https://example.com/detail?id=42`

필요한 것:

1. 실제 도메인 준비
2. 앱 target의 `Signing & Capabilities`에서 `Associated Domains` 추가
3. 예: `applinks:example.com` 등록
4. 서버에 `apple-app-site-association` 파일 배포
5. 앱에서 동일하게 `.onOpenURL`로 URL 처리

코드 연결은 딥링크와 동일하다.

```swift
.onOpenURL { url in
  navigator.handle(url: url, parser: AppDeepLinkParser())
}
```

시뮬레이터 테스트:

```bash
xcrun simctl openurl booted "https://example.com/home"
xcrun simctl openurl booted "https://example.com/detail?id=42"
```

주의:

- 유니버설 링크는 커스텀 스킴과 달리 URL scheme 등록만으로는 동작하지 않는다.
- `Associated Domains`와 서버의 `apple-app-site-association` 파일이 모두 맞아야 한다.
- 즉 샘플 앱 코드만으로는 바로 테스트되지 않고, 앱 설정과 서버 설정까지 끝나야 한다.

차이는 URL을 앱으로 넘겨주는 iOS 설정이 다르다는 점이다.

정리:

- 커스텀 스킴 딥링크
  - 앱 내부 URL scheme 등록만 있으면 비교적 바로 테스트 가능
- 유니버설 링크
  - `Associated Domains`와 서버 설정이 추가로 필요

샘플 앱 현재 상태:

- parser와 `.onOpenURL` 연결 예제는 포함돼 있음
- URL scheme / Associated Domains / 서버 설정은 사용자가 앱 프로젝트에서 추가해야 함

### 9. 가장 짧은 도입 체크리스트

1. `AppRoute`를 만들었는가
2. `AppDependencies`를 만들었는가
3. `RouteRegistry`에 화면을 등록했는가
4. `Navigator`를 생성했는가
5. `NavigationHost` 또는 `TabNavigationHost`에 연결했는가
6. 화면에서 `navigator.push/present/back`를 호출하고 있는가

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
- `DeepLinkParser`
  URL을 typed route 기반 deep link로 바꾸는 parser 프로토콜이다.
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

### DeepLink

- `DeepLink`
  파싱된 URL 결과를 typed route 배열과 action으로 표현한다.
- `DeepLinkAction`
  `push`, `replace`, `present(style:)` 중 어떤 방식으로 적용할지 정한다.
- `DeepLinkParser`
  URL을 `DeepLink<Route>`로 바꾸는 parser 프로토콜이다.

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

### 7. Deep Link 연결

```swift
struct AppDeepLinkParser: DeepLinkParser {
  func parse(url: URL) -> DeepLink<AppRoute>? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return nil
    }

    switch components.host {
    case "home":
      return DeepLink(route: .home, action: .replace)
    case "settings":
      return DeepLink(route: .settings, action: .present(style: .fullScreen))
    case "detail":
      let id = components.queryItems?.first(where: { $0.name == "id" })?.value ?? ""
      guard !id.isEmpty else { return nil }
      return DeepLink(route: .detail(id: id), action: .push)
    default:
      return nil
    }
  }
}
```

```swift
.onOpenURL { url in
  navigator.handle(url: url, parser: AppDeepLinkParser())
}
```

예시 URL:

- `nextnavigator://home`
- `nextnavigator://detail?id=42`
- `nextnavigator://settings`

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

### Deep Link

- `handle(_ deepLink:)`
  - 시간복잡도: deep link action에 따라 `push`, `replace`, `present` 비용을 그대로 따른다.
- `handle(url:parser:)`
  - 시간복잡도: `O(P + A)`

여기서:

- `P`: 앱이 구현한 parser 비용
- `A`: 파싱된 action 실행 비용

정책:

- URL parsing은 앱 parser가 담당한다.
- navigator는 parser가 반환한 typed deep link를 실행만 한다.
- deep link는 `push`, `replace`, `present(style:)` 중 하나의 action으로 연결한다.

### 참고

- `RouteRegistry.build(route:)`는 현재 `builders.first(where:)`를 사용하므로 route 1개당 `O(B)`다.
- `backTo`와 `backOrPush`는 현재 stack에서 마지막 일치 화면을 찾기 위해 선형 탐색을 사용한다.
- `switchTab`은 탭 controller 딕셔너리 조회를 사용하므로 기본적으로 `O(1)`이다.

## 샘플 앱

가장 먼저 보는 걸 추천하는 파일은 아래다.

- 진입점: [SampleApp.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SampleApp.swift)
- 라우팅 조립: [AppRouter.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppRouter.swift)
- 딥링크 parser: [AppDeepLinkParser.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/AppDeepLinkParser.swift)
- 홈 테스트 화면: [HomeView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/HomeView.swift)
- 디테일 테스트 화면: [DetailView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/DetailView.swift)
- MVVM 샘플 화면: [MVVMSampleView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/MVVMSampleView.swift)
- 설정 테스트 화면: [SettingsView.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp/SettingsView.swift)
- Xcode 프로젝트: [MinimalSampleApp.xcodeproj](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/MinimalSampleApp.xcodeproj)

`MinimalSampleApp`은 단순 소개용이 아니라 연산 테스트용 샘플이다.

추가로 `MVVMSampleView`는 View가 상태를 직접 만들지 않고, `MVVMSampleViewModel`이 `ObservableObject`로 상태와 네비게이션 액션을 관리하는 예제다. 홈 화면의 `Push MVVM Sample`, `Present MVVM Sample` 버튼이나 `nextnavigator://mvvm` 딥링크로 바로 확인할 수 있다.
홈/디테일/설정 화면에서 stack, modal, tab 연산을 직접 눌러볼 수 있다.

## 참고

- 자세한 설계/요구사항: [REQUIREMENTS.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/REQUIREMENTS.md)
- 다음 작업 목록: [TODO.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/TODO.md)
- route 개념 샘플: [RouteConceptSamples/README.md](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/README.md)
