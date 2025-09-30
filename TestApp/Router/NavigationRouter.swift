import Foundation
import SwiftUI
import Combine

enum Route: Hashable {
    case details(UserModel)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .details(let user):
            hasher.combine("details")
            hasher.combine(user.id)
        }
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.details(let l), .details(let r)):
            return l.id == r.id
        }
    }
}

@MainActor
final class NavigationRouter: ObservableObject {
    
    @Published var path: [Route] = []

    func showDetails(_ user: UserModel) {
        path.append(.details(user))
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

struct CoordinatorHost: View {
    @ObservedObject var viewModel: UserViewModel
    @ObservedObject var router: NavigationRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(router)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .details(let user):
                        UserDetailsView(user: user)
                    }
                }
        }
    }
}

struct CoordinatorHost_Previews: PreviewProvider {
    static var previews: some View {
        let vm = UserViewModel()
        let router = NavigationRouter()
        CoordinatorHost(viewModel: vm, router: router)
            .environmentObject(vm)
            .environmentObject(router)
    }
}
