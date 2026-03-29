public struct RouteContext<Dependencies, Route: Hashable> {
  public let navigator: Navigator<Dependencies, Route>
  public let route: Route
  public let dependencies: Dependencies

  public init(
    navigator: Navigator<Dependencies, Route>,
    route: Route,
    dependencies: Dependencies)
  {
    self.navigator = navigator
    self.route = route
    self.dependencies = dependencies
  }
}

