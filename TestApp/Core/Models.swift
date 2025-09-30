import Foundation

struct RandomUserResponse: Codable {
    let results: [RandomUserDTO]
}

struct RandomUserDTO: Codable {
    let gender: String?
    let name: NameDTO?
    let location: LocationDTO?
    let email: String?
    let login: LoginDTO?
    let dob: DOBDTO?
    let registered: RegisteredDTO?
    let phone: String?
    let cell: String?
    let picture: PictureDTO?
    let nat: String?
}

struct NameDTO: Codable {
    let title: String?
    let first: String?
    let last: String?
}

enum PostcodeValue: Codable {
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) {
            self = .int(i)
        } else if let s = try? c.decode(String.self) {
            self = .string(s)
        } else {
            self = .string("")
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .int(let i): try c.encode(i)
        case .string(let s): try c.encode(s)
        }
    }

    var stringValue: String? {
        switch self {
        case .int(let i): return String(i)
        case .string(let s): return s.isEmpty ? nil : s
        }
    }
}

struct LocationDTO: Codable {
    let street: StreetDTO?
    let city: String?
    let state: String?
    let country: String?
    let postcode: PostcodeValue?
    let coordinates: CoordinatesDTO?
    let timezone: TimezoneDTO?
}

struct StreetDTO: Codable {
    let number: Int?
    let name: String?
}

struct CoordinatesDTO: Codable {
    let latitude: String?
    let longitude: String?
}

struct TimezoneDTO: Codable {
    let offset: String?
    let description: String?
}

struct LoginDTO: Codable {
    let uuid: String?
    let username: String?
}

struct DOBDTO: Codable {
    let date: String?
    let age: Int?
}

struct RegisteredDTO: Codable {
    let date: String?
    let age: Int?
}

struct PictureDTO: Codable {
    let large: String?
    let medium: String?
    let thumbnail: String?
}

struct UserModel: Identifiable {
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

    let avatarURL: URL?
    let avatarMediumURL: URL?
    let avatarThumbURL: URL?

    let username: String?

    let registeredDate: Date?
    let registeredAge: Int?
    let timezoneOffset: String?
    let timezoneDescription: String?

    static func from(dto: RandomUserDTO) -> UserModel {
        let id = dto.login?.uuid ?? UUID().uuidString
        let firstLast = [dto.name?.first, dto.name?.last]
            .compactMap { $0 }
            .joined(separator: " ")
        let fullName = firstLast.isEmpty ? (dto.name?.title ?? "Unknown") : firstLast

        let avatarURL = dto.picture?.large.flatMap { URL(string: $0) }
        let avatarMediumURL = dto.picture?.medium.flatMap { URL(string: $0) }
        let avatarThumbURL = dto.picture?.thumbnail.flatMap { URL(string: $0) }

        func parseISO(_ s: String?) -> Date? {
            guard let s else { return nil }
            let f1 = ISO8601DateFormatter()
            f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = f1.date(from: s) { return d }
            let f2 = ISO8601DateFormatter()
            return f2.date(from: s)
        }

        let dobDate = parseISO(dto.dob?.date)
        let registeredDate = parseISO(dto.registered?.date)

        func parseDouble(_ s: String?) -> Double? {
            guard let s = s else { return nil }
            return Double(s)
        }

        return UserModel(
            id: id,
            gender: dto.gender,
            fullName: fullName,
            title: dto.name?.title,
            age: dto.dob?.age,
            dobDate: dobDate,
            country: dto.nat,
            countryName: dto.location?.country,
            city: dto.location?.city,
            state: dto.location?.state,
            postcode: dto.location?.postcode?.stringValue,
            latitude: parseDouble(dto.location?.coordinates?.latitude),
            longitude: parseDouble(dto.location?.coordinates?.longitude),
            email: dto.email,
            phone: dto.phone,
            cell: dto.cell,
            avatarURL: avatarURL,
            avatarMediumURL: avatarMediumURL,
            avatarThumbURL: avatarThumbURL,
            username: dto.login?.username,
            registeredDate: registeredDate,
            registeredAge: dto.registered?.age,
            timezoneOffset: dto.location?.timezone?.offset,
            timezoneDescription: dto.location?.timezone?.description
        )
    }
}

