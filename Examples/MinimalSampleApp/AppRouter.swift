import NextNavigator

enum AppRouter {
  static func buildNavigator() -> Navigator<AppDependencies, AppRoute> {
    let registry = RouteRegistry<AppDependencies, AppRoute>()
      .registering(.home) { context in
        WrappingController(route: context.route, title: "Home") {
          HomeView(navigator: context.navigator)
        }
      }
      .registering(
        extracting: { (route: AppRoute) -> String? in
          guard case let .detail(id) = route else { return nil }
          return id
        },
        build: { context, id in
          WrappingController(route: context.route, title: "Detail") {
            DetailView(
              userID: id,
              repository: context.dependencies.userRepository,
              navigator: context.navigator)
          }
        })
      .registering(.mvvmSample) { context in
        WrappingController(route: context.route, title: "MVVM Sample") {
          MVVMSampleView(
            viewModel: MVVMSampleViewModel(
              navigator: context.navigator,
              analytics: context.dependencies.analytics,
              userRepository: context.dependencies.userRepository))
        }
      }
      .registering(.settings) { context in
        WrappingController(route: context.route, title: "Settings") {
          SettingsView(navigator: context.navigator)
        }
      }

    return Navigator(
      dependencies: AppDependencies(
        userRepository: DefaultUserRepository(),
        analytics: DefaultAnalyticsClient()),
      registry: registry)
  }
}
