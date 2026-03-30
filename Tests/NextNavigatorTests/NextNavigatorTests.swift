import UIKit
import XCTest
@testable import NextNavigator

final class NextNavigatorTests: XCTestCase {
  func test_레지스트리가_일치하는_컨트롤러를_생성한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let built = registry.build(
      route: TestRoute.home,
      navigator: navigator,
      dependencies: ())

    XCTAssertNotNil(built)
    XCTAssertEqual(built?.anyRoute, AnyHashable(TestRoute.home))
  }

  func test_push를_호출하면_root_stack에_컨트롤러가_추가된다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = UINavigationController()
    rootController.setViewControllers(navigator.launch([TestRoute.home]), animated: false)
    navigator.rootController = rootController

    navigator.push(TestRoute.detail, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 2)
    XCTAssertEqual((rootController.viewControllers.last as? TestViewController)?.route, TestRoute.detail)
  }

  func test_backOrPush는_이미_존재하는_route가_있으면_pop한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = UINavigationController()
    rootController.setViewControllers(
      navigator.launch([TestRoute.home, TestRoute.detail, TestRoute.settings]),
      animated: false)
    navigator.rootController = rootController

    navigator.backOrPush(TestRoute.detail, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 2)
    XCTAssertEqual((rootController.viewControllers.last as? TestViewController)?.route, TestRoute.detail)
  }

  func test_replace는_현재_stack을_새_route들로_교체한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let rootController = UINavigationController()
    rootController.setViewControllers(
      navigator.launch([TestRoute.home, TestRoute.detail]),
      animated: false)
    navigator.rootController = rootController

    navigator.replace(with: [TestRoute.settings], animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 1)
    XCTAssertEqual((rootController.viewControllers.first as? TestViewController)?.route, TestRoute.settings)
  }

  func test_backTo는_마지막으로_일치하는_route까지_이동한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let rootController = UINavigationController()
    rootController.setViewControllers(
      navigator.launch([TestRoute.home, TestRoute.detail, TestRoute.settings, TestRoute.detail, TestRoute.settings]),
      animated: false)
    navigator.rootController = rootController

    navigator.backTo(TestRoute.detail, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 4)
    XCTAssertEqual((rootController.viewControllers.last as? TestViewController)?.route, TestRoute.detail)
  }

  func test_extracting_builder는_연관값_route를_생성한다() {
    let registry = RouteRegistry<Void, AssociatedRoute>()
      .registering(
        extracting: { route in
          guard case let AssociatedRoute.detail(id) = route else { return nil }
          return id
        },
        build: { context, id in
          AssociatedTestViewController(route: context.route, extractedID: id)
        })

    let navigator = Navigator<Void, AssociatedRoute>(
      dependencies: (),
      registry: registry)

    let built = registry.build(
      route: AssociatedRoute.detail(id: "42"),
      navigator: navigator,
      dependencies: ())

    XCTAssertNotNil(built)
    XCTAssertEqual((built as? AssociatedTestViewController)?.extractedID, "42")
  }

  func test_present를_호출하면_모달_컨트롤러가_생성된다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.present(TestRoute.settings, animated: false)

    XCTAssertTrue(navigator.isModalActive)
    XCTAssertNotNil(navigator.modalController)
    XCTAssertEqual(rootController.presentCallCount, 1)
    XCTAssertEqual((navigator.modalController?.viewControllers.first as? TestViewController)?.route, TestRoute.settings)
  }

  func test_등록되지_않은_route를_push하면_stack이_변하지_않는다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let rootController = UINavigationController()
    rootController.setViewControllers(navigator.launch([TestRoute.home]), animated: false)
    navigator.rootController = rootController

    navigator.push(TestRoute.missing, animated: false)

    XCTAssertEqual(rootController.viewControllers.count, 1)
    XCTAssertEqual((rootController.viewControllers.first as? TestViewController)?.route, TestRoute.home)
  }

  func test_presentFullScreen은_fullScreen_스타일을_적용한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.presentFullScreen(TestRoute.settings, animated: false)

    XCTAssertEqual(navigator.modalController?.modalPresentationStyle, .fullScreen)
  }

  func test_modal의_root에서_back을_호출하면_dismiss된다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController
    navigator.present(TestRoute.settings, animated: false)

    let modalController = navigator.modalController as? PresenterNavigationController
    XCTAssertNotNil(modalController)

    navigator.back(animated: false)

    XCTAssertEqual(modalController?.dismissCallCount, 1)
  }

  func test_present는_기존_모달이_있으면_교체한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let rootController = PresenterNavigationController()
    navigator.rootController = rootController

    navigator.present(TestRoute.home, animated: false)
    let firstModal = navigator.modalController as? PresenterNavigationController

    navigator.present(TestRoute.settings, animated: false)
    let secondModal = navigator.modalController as? PresenterNavigationController

    XCTAssertNotNil(firstModal)
    XCTAssertNotNil(secondModal)
    XCTAssertFalse(firstModal === secondModal)
    XCTAssertEqual(firstModal?.dismissCallCount, 1)
    XCTAssertEqual(rootController.presentCallCount, 2)
  }

  func test_switchTab은_선택된_탭_컨트롤러를_변경한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: TestRoute.home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: TestRoute.settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 0
    tabBarController.selectedViewController = controllers[0]
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(0)

    navigator.switchTab(tag: 1, popToRootIfSelected: false)

    XCTAssertEqual(navigator.tabCoordinator.currentTag, 1)
    XCTAssertTrue(tabBarController.selectedViewController === controllers[1])
  }

  func test_같은_탭을_다시_선택하면_root로_pop한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: TestRoute.home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: TestRoute.settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 0
    tabBarController.selectedViewController = controllers[0]
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(0)

    let selectedController = controllers[0]
    selectedController.pushViewController(TestViewController(route: TestRoute.detail), animated: false)
    XCTAssertEqual(selectedController.viewControllers.count, 2)

    navigator.switchTab(tag: 0, popToRootIfSelected: true)

    XCTAssertEqual(selectedController.viewControllers.count, 1)
    XCTAssertEqual((selectedController.viewControllers.first as? TestViewController)?.route, TestRoute.home)
  }

  func test_같은_탭을_다시_선택해도_pop옵션이_false면_stack을_유지한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: TestRoute.home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: TestRoute.settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 0
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(0)

    let selectedController = controllers[0]
    selectedController.pushViewController(TestViewController(route: TestRoute.detail), animated: false)
    XCTAssertEqual(selectedController.viewControllers.count, 2)

    navigator.switchTab(tag: 0, popToRootIfSelected: false)

    XCTAssertEqual(selectedController.viewControllers.count, 2)
    XCTAssertEqual((selectedController.viewControllers.last as? TestViewController)?.route, TestRoute.detail)
  }

  func test_activeController는_선택된_탭_컨트롤러를_사용한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.home) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.detail) { context in
        TestViewController(route: context.route)
      }
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry)

    let items = [
      TabNavigationItem(tag: 0, route: TestRoute.home, tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0)),
      TabNavigationItem(tag: 1, route: TestRoute.settings, tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1)),
    ]

    let tabBarController = UITabBarController()
    let controllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    tabBarController.setViewControllers(controllers, animated: false)
    tabBarController.selectedIndex = 1
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(1)

    navigator.push(TestRoute.detail, animated: false)

    let selectedController = controllers[1]
    XCTAssertEqual(selectedController.viewControllers.count, 2)
    XCTAssertEqual((selectedController.viewControllers.last as? TestViewController)?.route, TestRoute.detail)
  }

  func test_탭_환경의_present는_선택된_탭_컨트롤러를_presenter로_사용한다() {
    let registry = RouteRegistry<Void, TestRoute>()
      .registering(TestRoute.settings) { context in
        TestViewController(route: context.route)
      }

    let navigator = Navigator<Void, TestRoute>(
      dependencies: (),
      registry: registry,
      modalCoordinator: ModalCoordinator(makeNavigationController: { PresenterNavigationController() }))

    let tabBarController = UITabBarController()
    let first = PresenterNavigationController()
    let second = PresenterNavigationController()
    second.setViewControllers([TestViewController(route: TestRoute.settings)], animated: false)
    tabBarController.setViewControllers([first, second], animated: false)
    tabBarController.selectedViewController = second
    navigator.tabCoordinator.tabBarController = tabBarController
    navigator.tabCoordinator.setSelectedTag(1)

    navigator.present(TestRoute.settings, animated: false)

    XCTAssertEqual(second.presentCallCount, 1)
    XCTAssertNotNil(navigator.modalController)
  }
}

private enum TestRoute: Hashable {
  case home
  case detail
  case settings
  case missing
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
