import UIKit
import XCTest
@testable import NextNavigator

final class NextNavigatorTests: XCTestCase {
  func testRegistryBuildsMatchingController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let built = registry.build(
      route: .home,
      navigator: navigator,
      dependencies: ())

    XCTAssertNotNil(built)
    XCTAssertEqual(built?.anyRoute, AnyHashable(TestRoute.home))
  }

  func testPushAppendsControllerToRootStack() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }
      .registering(.detail) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = UINavigationController()
    rootController.setViewControllers(navigator.launch([.home]), animated: false)
    navigator.rootController = rootController

    navigator.push(.detail, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 2)
    XCTAssertEqual((rootController.viewControllers.last as? TestViewController)?.route, .detail)
  }

  func testBackOrPushPopsWhenRouteAlreadyExists() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }
      .registering(.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = UINavigationController()
    rootController.setViewControllers(
      navigator.launch([.home, .detail, .settings]),
      animated: false)
    navigator.rootController = rootController

    navigator.backOrPush(.detail, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 2)
    XCTAssertEqual((rootController.viewControllers.last as? TestViewController)?.route, .detail)
  }

  func testRegistryExtractingBuilderBuildsAssociatedValueRoute() {
    let registry = RouteRegistry<Void, AssociatedRoute>()
      .registering(
        extracting: { route in
          guard case let .detail(id) = route else { return nil }
          return id
        },
        build: { context, id in
          AssociatedTestViewController(route: context.route, extractedID: id)
        })

    let navigator = Navigator<Void, AssociatedRoute>(
      dependencies: (),
      registry: registry)

    let built = registry.build(
      route: .detail(id: "42"),
      navigator: navigator,
      dependencies: ())

    XCTAssertNotNil(built)
    XCTAssertEqual((built as? AssociatedTestViewController)?.extractedID, "42")
  }

  func testPresentCreatesModalController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.present(.settings, animated: false)

    XCTAssertTrue(navigator.isModalActive)
    XCTAssertNotNil(navigator.modalController)
    XCTAssertEqual(rootController.presentCallCount, 1)
    XCTAssertEqual((navigator.modalController?.viewControllers.first as? TestViewController)?.route, .settings)
  }

  func testPresentFullScreenAppliesPresentationStyle() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.presentFullScreen(.settings, animated: false)

    XCTAssertEqual(navigator.modalController?.modalPresentationStyle, .fullScreen)
  }

  func testBackDismissesModalWhenModalHasSingleController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController
    navigator.present(.settings, animated: false)

    let modalController = navigator.modalController as? PresenterNavigationController
    XCTAssertNotNil(modalController)

    navigator.back(animated: false)

    XCTAssertEqual(modalController?.dismissCallCount, 1)
  }

  func testPresentReplacesExistingModalController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.present(.home, animated: false)
    let firstModal = navigator.modalController as? PresenterNavigationController

    navigator.present(.settings, animated: false)
    let secondModal = navigator.modalController as? PresenterNavigationController

    XCTAssertNotNil(firstModal)
    XCTAssertNotNil(secondModal)
    XCTAssertFalse(firstModal === secondModal)
    XCTAssertEqual(firstModal?.dismissCallCount, 1)
    XCTAssertEqual(rootController.presentCallCount, 2)
  }

  func testSwitchTabChangesSelectedController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: .home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: .settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 0
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(0)

    navigator.switchTab(tag: 1, popToRootIfSelected: false)

    XCTAssertEqual(navigator.tabCoordinator.currentTag, 1)
    XCTAssertTrue(tabBarController.selectedViewController === controllers[1])
  }

  func testActiveControllerUsesSelectedTabController() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.home) { context in
        TestViewController(route: context.route)
      }
      .registering(.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: .home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: .settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 1
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(1)

    navigator.push(.detail, animated: false)

    let selectedController = controllers[1]
    XCTAssertEqual(selectedController.viewControllers.count, 2)
    XCTAssertEqual((selectedController.viewControllers.last as? TestViewController)?.route, .detail)
  }

  func testPresentUsesSelectedTabControllerAsPresenter() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let tabBarController = UITabBarController()
    let first = PresenterNavigationController()
    let second = PresenterNavigationController()
    second.setViewControllers([TestViewController(route: .settings)], animated: false)
    tabBarController.setViewControllers([first, second], animated: false)
    tabBarController.selectedViewController = second
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(1)

    navigator.present(.settings, animated: false)

    XCTAssertEqual(second.presentCallCount, 1)
    XCTAssertNotNil(navigator.modalController)
  }
}

private enum TestRoute: Hashable {
  case home
  case detail
  case settings
}

private enum AssociatedRoute: Hashable {
  case detail(id: String)
}

private final class TestViewController: UIViewController, AnyRouteIdentifiable {
  let route: TestRoute
  let anyRoute: AnyHashable

  init(route: TestRoute) {
    self.route = route
    anyRoute = AnyHashable(route)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private final class AssociatedTestViewController: UIViewController, AnyRouteIdentifiable {
  let route: AssociatedRoute
  let extractedID: String
  let anyRoute: AnyHashable

  init(route: AssociatedRoute, extractedID: String) {
    self.route = route
    self.extractedID = extractedID
    anyRoute = AnyHashable(route)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private final class PresenterNavigationController: UINavigationController {
  private(set) var presentCallCount = 0
  private(set) var dismissCallCount = 0

  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    presentCallCount += 1
    completion?()
  }

  override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    dismissCallCount += 1
    completion?()
  }
}
