import SwiftUI
import UIKit

public struct NavigationHost<Dependencies, Route: Hashable>: UIViewControllerRepresentable {
  public let navigator: Navigator<Dependencies, Route>
  public let initialRoutes: [Route]
  public let prefersLargeTitles: Bool

  public init(
    navigator: Navigator<Dependencies, Route>,
    initialRoutes: [Route],
    prefersLargeTitles: Bool = false)
  {
    self.navigator = navigator
    self.initialRoutes = initialRoutes
    self.prefersLargeTitles = prefersLargeTitles
  }

  public func makeUIViewController(context: Context) -> UINavigationController {
    let controller = UINavigationController()
    controller.navigationBar.prefersLargeTitles = prefersLargeTitles
    controller.setViewControllers(navigator.launch(initialRoutes), animated: false)
    navigator.rootController = controller
    return controller
  }

  public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    navigator.rootController = uiViewController
  }
}

