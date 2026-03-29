public final class NavigatorSpy<Dependencies, Route: Hashable> {
  public private(set) var pushedRoutes: [[Route]] = []
  public private(set) var replacedRoutes: [[Route]] = []
  public private(set) var presentedRoutes: [[Route]] = []
  public private(set) var didCallBack = false
  public private(set) var didDismissModal = false

  public init() { }

  public func recordPush(_ routes: [Route]) {
    pushedRoutes.append(routes)
  }

  public func recordReplace(_ routes: [Route]) {
    replacedRoutes.append(routes)
  }

  public func recordPresent(_ routes: [Route]) {
    presentedRoutes.append(routes)
  }

  public func recordBack() {
    didCallBack = true
  }

  public func recordDismissModal() {
    didDismissModal = true
  }
}

