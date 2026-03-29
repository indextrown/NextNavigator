import UIKit

public struct ModalCoordinator<Dependencies, Route: Hashable> {
  public let makeNavigationController: () -> UINavigationController

  public init(
    makeNavigationController: @escaping () -> UINavigationController = { UINavigationController() })
  {
    self.makeNavigationController = makeNavigationController
  }

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

  public func dismiss(
    modalController: UINavigationController?,
    animated: Bool,
    completion: (() -> Void)? = nil)
  {
    modalController?.dismiss(animated: animated, completion: completion)
  }
}
