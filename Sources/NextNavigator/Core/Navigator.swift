import UIKit

/// The main entry point of NextNavigator.
///
/// `Navigator` receives typed routes, asks the registry to build matching view
/// controllers, and delegates stack/modal/tab mutations to smaller coordinator
/// types.
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

  /// Returns the navigation controller that should currently receive stack
  /// mutations. Modal takes precedence over tab, tab takes precedence over root.
  public var activeController: UINavigationController? {
    modalController ?? tabCoordinator.currentNavigationController ?? rootController
  }

  /// Indicates whether a modal navigation stack is currently active.
  public var isModalActive: Bool {
    modalController != nil
  }

  private var presentationController: UINavigationController? {
    tabCoordinator.currentNavigationController ?? rootController
  }

  /// Builds the initial set of controllers for the given routes.
  public func launch(_ routes: [Route]) -> [UIViewController] {
    registry.build(routes: routes, navigator: self, dependencies: dependencies)
  }

  /// Returns the typed routes represented by the active stack.
  public func currentRoutes() -> [AnyHashable] {
    singleStackCoordinator.currentRoutes(controller: activeController)
  }

  /// Pushes a single route onto the active stack.
  public func push(_ route: Route, animated: Bool = true) {
    push([route], animated: animated)
  }

  /// Pushes multiple routes in order onto the active stack.
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

  /// Replaces the entire active stack with controllers built from the provided
  /// routes.
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

  /// Goes back one level in the active stack. If the active stack is a modal
  /// with a single controller, it dismisses the modal instead.
  public func back(animated: Bool = true) {
    guard let activeController else { return }

    if activeController.viewControllers.count > 1 {
      activeController.popViewController(animated: animated)
      return
    }

    guard modalController === activeController else { return }
    dismissModal(animated: animated)
  }

  /// Pops back to the last view controller whose route matches the target route.
  public func backTo(_ route: Route, animated: Bool = true) {
    guard
      let activeController,
      let target = singleStackCoordinator.lastMatchedViewController(
        route: route,
        in: activeController)
    else { return }

    activeController.popToViewController(target, animated: animated)
  }

  /// Pops back to an existing matching route if one exists, otherwise pushes a
  /// new screen for that route.
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

  /// Presents a modal navigation stack whose root is built from a single route.
  public func present(
    _ route: Route,
    animated: Bool = true,
    style: ModalPresentationStyle = .automatic)
  {
    present([route], animated: animated, style: style)
  }

  /// Presents a modal navigation stack built from the provided routes.
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

  /// Convenience API for presenting a single route as a full screen modal.
  public func presentFullScreen(_ route: Route, animated: Bool = true) {
    present(route, animated: animated, style: .fullScreen)
  }

  /// Convenience API for presenting multiple routes as a full screen modal.
  public func presentFullScreen(_ routes: [Route], animated: Bool = true) {
    present(routes, animated: animated, style: .fullScreen)
  }

  /// Dismisses the current modal navigation stack.
  public func dismissModal(animated: Bool = true) {
    modalCoordinator.dismiss(modalController: modalController, animated: animated) { [weak self] in
      self?.modalController = nil
    }
  }

  /// Switches to a tab by tag. Re-selecting the same tag can optionally pop the
  /// tab stack back to root.
  public func switchTab(tag: Int, popToRootIfSelected: Bool = true) {
    tabCoordinator.switchTab(tag: tag, popToRootIfSelected: popToRootIfSelected)
  }
}
