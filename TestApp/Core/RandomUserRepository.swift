import Foundation
import Combine

protocol RandomUserRepositoryProtocol {
    func fetchRandomUser() -> AnyPublisher<UserModel, Error>
    func saveLastUser(_ user: UserModel)
    func loadLastUser() -> UserModel?
}

final class RandomUserRepository: RandomUserRepositoryProtocol {

    private let session: URLSession
    private let base = "https://randomuser.me/api/"
    private let cacheKey = "LastRandomUserCache"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchRandomUser() -> AnyPublisher<UserModel, Error> {
        guard var comps = URLComponents(string: base) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        comps.queryItems = [
            URLQueryItem(name: "results", value: "1"),
            URLQueryItem(name: "noinfo", value: "1")
        ]
        guard let url = comps.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: RandomUserResponse.self, decoder: JSONDecoder())
            .tryMap { response -> UserModel in
                guard let dto = response.results.first else {
                    throw URLError(.cannotDecodeContentData)
                }
                return UserModel.from(dto: dto)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func saveLastUser(_ user: UserModel) {
        do {
            let cache = CachedUser(from: user)
            let data = try JSONEncoder().encode(cache)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            fatalError("Failed to encode user: \(error)")
        }
    }

    func loadLastUser() -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        do {
            let cache = try JSONDecoder().decode(CachedUser.self, from: data)
            return cache.toModel()
        } catch {
            return nil
        }
    }
}

private struct CachedUser: Codable {
    let id: String
    let gender: String?
    let fullName: String
    let title: String?
    let age: Int?
    let dobDate: Date?

    let country: String?
    let countryName: String?
    let city: String?
    let state: String?
    let postcode: String?
    let latitude: Double?
    let longitude: Double?

    let email: String?
    let phone: String?
    let cell: String?

    let avatarURL: String?
    let avatarMediumURL: String?
    let avatarThumbURL: String?

    let username: String?

    let registeredDate: Date?
    let registeredAge: Int?
    let timezoneOffset: String?
    let timezoneDescription: String?

    init(from model: UserModel) {
        id = model.id
        gender = model.gender
        fullName = model.fullName
        title = model.title
        age = model.age
        dobDate = model.dobDate

        country = model.country
        countryName = model.countryName
        city = model.city
        state = model.state
        postcode = model.postcode
        latitude = model.latitude
        longitude = model.longitude

        email = model.email
        phone = model.phone
        cell = model.cell

        avatarURL = model.avatarURL?.absoluteString
        avatarMediumURL = model.avatarMediumURL?.absoluteString
        avatarThumbURL = model.avatarThumbURL?.absoluteString

        username = model.username

        registeredDate = model.registeredDate
        registeredAge = model.registeredAge
        timezoneOffset = model.timezoneOffset
        timezoneDescription = model.timezoneDescription
    }

    func toModel() -> UserModel {
        UserModel(
            id: id,
            gender: gender,
            fullName: fullName,
            title: title,
            age: age,
            dobDate: dobDate,
            country: country,
            countryName: countryName,
            city: city,
            state: state,
            postcode: postcode,
            latitude: latitude,
            longitude: longitude,
            email: email,
            phone: phone,
            cell: cell,
            avatarURL: avatarURL.flatMap(URL.init(string:)),
            avatarMediumURL: avatarMediumURL.flatMap(URL.init(string:)),
            avatarThumbURL: avatarThumbURL.flatMap(URL.init(string:)),
            username: username,
            registeredDate: registeredDate,
            registeredAge: registeredAge,
            timezoneOffset: timezoneOffset,
            timezoneDescription: timezoneDescription
        )
    }
}
