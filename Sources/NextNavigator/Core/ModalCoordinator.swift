import UIKit

/// Manages modal presentation and dismissal using a dedicated navigation
/// controller.
public struct ModalCoordinator<Dependencies, Route: Hashable> {
  /// A factory kept injectable so tests can substitute a spy navigation
  /// controller.
  public let makeNavigationController: () -> UINavigationController

  public init(
    makeNavigationController: @escaping () -> UINavigationController = { UINavigationController() })
  {
    self.makeNavigationController = makeNavigationController
  }

  /// Builds a modal navigation stack for the given routes and presents it from
  /// the provided presenter.
  public func present(
    routes: [Route],
    from presenter: UINavigationController?,
    existingModalController: UINavigationController?,
    navigator: Navigator<Dependencies, Route>,
    animated: Bool,
    presentationStyle: ModalPresentationStyle)
    -> UINavigationController?
  {
    guard let presenter else { return nil }

    existingModalController?.dismiss(animated: false)

    let modalController = makeNavigationController()
    modalController.modalPresentationStyle = presentationStyle.uiKitStyle
    let viewControllers = navigator.registry.build(
      routes: routes,
      navigator: navigator,
      dependencies: navigator.dependencies)

    modalController.setViewControllers(viewControllers, animated: false)
    presenter.present(modalController, animated: animated)
    return modalController
  }

  /// Dismisses the currently presented modal navigation controller.
  public func dismiss(
    modalController: UINavigationController?,
    animated: Bool,
    completion: (() -> Void)? = nil)
  {
    modalController?.dismiss(animated: animated, completion: completion)
  }
}
