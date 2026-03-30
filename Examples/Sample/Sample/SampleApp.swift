//
//  SampleApp.swift
//  Sample
//
//  Created by 김동현 on 3/30/26.
//

import SwiftUI
import NextNavigator

struct AppDependencies {
    
}

enum AppRoute: Hashable {
    case home
    case detail(id: String)
    case settings
}

enum AppRouter {
    static func buildNavigator() -> Navigator<AppDependencies, AppRoute> {
        let registry = RouteRegistry<AppDependencies, AppRoute>()
            .registering(.home) { context in
              WrappingController(route: context.route, title: "Home") {
                HomeView(navigator: context.navigator)
              }
            }
        return Navigator(
            dependencies: AppDependencies(),
            registry: registry
        )
    }
}

struct HomeView: View {
    let navigator: Navigator<AppDependencies, AppRoute>
    var body: some View {
        VStack {
            Text("HomeView")
        }
    }
}

@main
struct SampleApp: App {
    private let navigator = AppRouter.buildNavigator()
    var body: some Scene {
        WindowGroup {
            NavigationHost(
                navigator: navigator,
                initialRoutes: [.home]
            )
        }
    }
}
