import SwiftUI

public final class WrappingController<Route: Hashable, Content: View>: UIHostingController<Content>, AnyRouteIdentifiable {
  public let route: Route
  public let anyRoute: AnyHashable

  public init(
    route: Route,
    title: String? = nil,
    @ViewBuilder content: () -> Content)
  {
    self.route = route
    anyRoute = AnyHashable(route)
    super.init(rootView: content())
    self.title = title
  }

  @available(*, unavailable)
  required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

