import UIKit

public final class Navigator<Dependencies, Route: Hashable> {
  public let dependencies: Dependencies
  public let registry: RouteRegistry<Dependencies, Route>

  public weak var rootController: UINavigationController?
  public var modalController: UINavigationController?

  public let singleStackCoordinator: SingleStackCoordinator<Route>
  public let modalCoordinator: ModalCoordinator<Dependencies, Route>
  public let tabCoordinator: TabCoordinator<Dependencies, Route>

  public init(
    dependencies: Dependencies,
    registry: RouteRegistry<Dependencies, Route> = .init(),
    singleStackCoordinator: SingleStackCoordinator<Route> = .init(),
    modalCoordinator: ModalCoordinator<Dependencies, Route> = .init(),
    tabCoordinator: TabCoordinator<Dependencies, Route> = .init())
  {
    self.dependencies = dependencies
    self.registry = registry
    self.singleStackCoordinator = singleStackCoordinator
    self.modalCoordinator = modalCoordinator
    self.tabCoordinator = tabCoordinator
  }

  public var activeController: UINavigationController? {
    modalController ?? tabCoordinator.currentNavigationController ?? rootController
  }

  public var isModalActive: Bool {
    modalController != nil
  }

  private var presentationController: UINavigationController? {
    tabCoordinator.currentNavigationController ?? rootController
  }

  public func launch(_ routes: [Route]) -> [UIViewController] {
    registry.build(routes: routes, navigator: self, dependencies: dependencies)
  }

  public func currentRoutes() -> [AnyHashable] {
    singleStackCoordinator.currentRoutes(controller: activeController)
  }

  public func push(_ route: Route, animated: Bool = true) {
    push([route], animated: animated)
  }

  public func push(_ routes: [Route], animated: Bool = true) {
    let newControllers = registry.build(
      routes: routes,
      navigator: self,
      dependencies: dependencies)

    singleStackCoordinator.append(
      viewControllers: newControllers,
      to: activeController,
      animated: animated)
  }

  public func replace(with routes: [Route], animated: Bool = true) {
    let newControllers = registry.build(
      routes: routes,
      navigator: self,
      dependencies: dependencies)

    singleStackCoordinator.replace(
      viewControllers: newControllers,
      on: activeController,
      animated: animated)
  }

  public func back(animated: Bool = true) {
    guard let activeController else { return }

    if activeController.viewControllers.count > 1 {
      activeController.popViewController(animated: animated)
      return
    }

    guard modalController === activeController else { return }
    dismissModal(animated: animated)
  }

  public func backTo(_ route: Route, animated: Bool = true) {
    guard
      let activeController,
      let target = singleStackCoordinator.lastMatchedViewController(
        route: route,
        in: activeController)
    else { return }

    activeController.popToViewController(target, animated: animated)
  }

  public func backOrPush(_ route: Route, animated: Bool = true) {
    guard
      let activeController,
      let target = singleStackCoordinator.lastMatchedViewController(
        route: route,
        in: activeController)
    else {
      push(route, animated: animated)
      return
    }

    activeController.popToViewController(target, animated: animated)
  }

  public func present(
    _ route: Route,
    animated: Bool = true,
    style: ModalPresentationStyle = .automatic)
  {
    present([route], animated: animated, style: style)
  }

  public func present(
    _ routes: [Route],
    animated: Bool = true,
    style: ModalPresentationStyle = .automatic)
  {
    modalController = modalCoordinator.present(
      routes: routes,
      from: presentationController,
      existingModalController: modalController,
      navigator: self,
      animated: animated,
      presentationStyle: style)
  }

  public func presentFullScreen(_ route: Route, animated: Bool = true) {
    present(route, animated: animated, style: .fullScreen)
  }

  public func presentFullScreen(_ routes: [Route], animated: Bool = true) {
    present(routes, animated: animated, style: .fullScreen)
  }

  public func dismissModal(animated: Bool = true) {
    modalCoordinator.dismiss(modalController: modalController, animated: animated) { [weak self] in
      self?.modalController = nil
    }
  }

  public func switchTab(tag: Int, popToRootIfSelected: Bool = true) {
    tabCoordinator.switchTab(tag: tag, popToRootIfSelected: popToRootIfSelected)
  }
}
