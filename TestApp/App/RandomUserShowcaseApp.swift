import SwiftUI

@main
struct RandomUserShowcaseApp: App {
    @StateObject private var vm = UserViewModel()
    @StateObject private var router = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            CoordinatorHost(viewModel: vm, router: router)
                .ignoresSafeArea()
        }
    }
}
