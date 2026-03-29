enum AppRoute: Hashable, CustomStringConvertible {
  case home
  case detail(id: String)
  case settings

  var description: String {
    switch self {
    case .home:
      "home"
    case let .detail(id):
      "detail(id: \(id))"
    case .settings:
      "settings"
    }
  }
}
