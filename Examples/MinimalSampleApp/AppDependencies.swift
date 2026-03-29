struct AppDependencies {
  let userRepository: UserRepository
  let analytics: AnalyticsClient
}

protocol UserRepository {
  func displayName(for id: String) -> String
}

struct DefaultUserRepository: UserRepository {
  func displayName(for id: String) -> String {
    "User-\(id)"
  }
}

protocol AnalyticsClient {
  func track(_ event: String)
}

struct DefaultAnalyticsClient: AnalyticsClient {
  func track(_ event: String) {
    print("analytics:", event)
  }
}

