import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var router: NavigationRouter

    @State private var swipe: CardAction? = nil

    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                VStack {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("Loading user...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundAccent)
                
            case .failed(let message):
                VStack(spacing: 16) {
                    Text("Failed to load")
                        .font(.title2)
                    Text(message)
                        .font(.caption)
                    Button("Retry") {
                        vm.fetchUserAnimated()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let user):
                ZStack {
                    Color.backgroundAccent.ignoresSafeArea()
                    VStack {
                        Spacer(minLength: 0)
                        
                        DatingCard(user: user, onAction: { action in
                            switch action {
                            case .like, .dislike:
                                vm.fetchUserAnimated()
                            }
                        }, programmaticSwipe: $swipe)
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 20)
                        
                        HStack(spacing: 24) {
                            SmallCircleButton(systemName: "xmark") {
                                swipe = .dislike
                            }
                            SmallCircleButton(systemName: "heart.fill") {
                                swipe = .like
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .animation(.easeInOut, value: user.id)
                }
            }
        }
        .navigationTitle("RandomUser Showcase")
        .task {
            if case .idle = vm.state {
                vm.loadFromCacheIfAvailable()
                vm.fetchUser()
            }
        }
    }
}

struct SmallCircleButton: View {
    let systemName: String
    let action: ()->Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .frame(width: 56, height: 56)
                .background(RoundedRectangle(cornerRadius: 28).fill(Color.white))
                .shadow(radius: 3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserViewModel())
            .environmentObject(NavigationRouter())
    }
}
