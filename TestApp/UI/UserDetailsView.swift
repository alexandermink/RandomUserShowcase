import SwiftUI

struct UserDetailsView: View {
    let user: UserModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: user.avatarURL ?? user.avatarMediumURL ?? user.avatarThumbURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 140, height: 140)
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    case .failure(_):
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .padding(20)
                            .background(Circle().fill(Color.backgroundAccent))
                    @unknown default:
                        Color.clear.frame(width: 140, height: 140)
                    }
                }
                .shadow(radius: 4)
                .padding(.top, 24)

                Text(user.fullName)
                    .font(.title2).bold()

                if let username = user.username, !username.isEmpty {
                    Text("@\(username)").foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    if let email = user.email { Label(email, systemImage: "envelope") }
                    if let phone = user.phone { Label(phone, systemImage: "phone") }
                    if let cell = user.cell { Label(cell, systemImage: "teletype") }

                    let loc = [user.city, user.state, user.countryName].compactMap { $0 }.joined(separator: ", ")
                    if !loc.isEmpty { Label(loc, systemImage: "mappin.and.ellipse") }

                    if let pc = user.postcode, !pc.isEmpty {
                        Label("Postcode: \(pc)", systemImage: "number.square")
                    }

                    if let lat = user.latitude, let lon = user.longitude {
                        Label(String(format: "Lat %.4f, Lon %.4f", lat, lon), systemImage: "location.north.line")
                    }

                    if let tz = user.timezoneOffset {
                        Label("Timezone: \(tz)", systemImage: "clock")
                    }
                    if let reg = user.registeredDate {
                        Label("Registered: \(reg.asShortString())", systemImage: "calendar")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.backgroundAccent))
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Details \(flagEmoji(from: user.country))")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(user: .init(
            id: UUID().uuidString,
            gender: "female",
            fullName: "Jane Doe",
            title: "Ms",
            age: 29,
            dobDate: Date(timeIntervalSince1970: 0),
            country: "US",
            countryName: "United States",
            city: "New York",
            state: "NY",
            postcode: "10001",
            latitude: 40.7128,
            longitude: -74.0060,
            email: "jane@example.com",
            phone: "+1 555 123",
            cell: "+1 555 321",
            avatarURL: nil,
            avatarMediumURL: nil,
            avatarThumbURL: nil,
            username: "jane_doe",
            registeredDate: Date(),
            registeredAge: 5,
            timezoneOffset: "-05:00",
            timezoneDescription: "Eastern Time"
        ))
    }
}
