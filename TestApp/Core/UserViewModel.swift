import Foundation
import Combine
import SwiftUI

@MainActor
final class UserViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(UserModel)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let repository: RandomUserRepository
    private var bag = Set<AnyCancellable>()

    init(repository: RandomUserRepository? = nil) {
        self.repository = repository ?? RandomUserRepository()
    }

    func fetchUser() {
        state = .loading
        repository.fetchRandomUser()
            .handleEvents(receiveOutput: { [weak self] user in
                self?.repository.saveLastUser(user)
            })
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.state = .failed(String(describing: error))
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                withAnimation(.spring()) {
                    self.state = .loaded(user)
                }
            }
            .store(in: &bag)
    }

    func fetchUserAnimated() {
        fetchUser()
    }

    func loadFromCacheIfAvailable() {
        if let cached = repository.loadLastUser() {
            state = .loaded(cached)
        }
    }
}
