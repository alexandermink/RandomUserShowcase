import SwiftUI

enum CardAction {
    case like
    case dislike
}

struct DatingCard: View {
    let user: UserModel
    var onAction: (CardAction)->Void

    @Binding var programmaticSwipe: CardAction?

    @State private var offset: CGSize = .zero
    @State private var cardScale: CGFloat = 1.0
    @GestureState private var isDragging = false

    private let badgeColumns = [GridItem(.adaptive(minimum: 120), spacing: 8, alignment: .leading)]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                backgroundView(geo: geo)

                headerView(geo: geo)

                VStack {
                    Spacer()
                }

                flagView()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .scaleEffect(cardScale)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .offset(offset)
            .gesture(dragGesture(geo: geo))
            .onChange(of: isDragging) { _, dragging in
                withAnimation(.spring()) { cardScale = dragging ? 0.99 : 1.0 }
            }
            .onChange(of: programmaticSwipe) { _, newValue in
                guard let action = newValue else { return }
                switch action {
                case .like:
                    withAnimation(.easeIn(duration: 0.2)) {
                        offset = CGSize(width: geo.size.width * 1.2, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onAction(.like)
                        programmaticSwipe = nil
                    }
                case .dislike:
                    withAnimation(.easeIn(duration: 0.2)) {
                        offset = CGSize(width: -geo.size.width * 1.2, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onAction(.dislike)
                        programmaticSwipe = nil
                    }
                }
            }
            .animation(.interactiveSpring(), value: offset)
        }
        .frame(height: 480)
    }

    @ViewBuilder
    private func backgroundView(geo: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(gradient: Gradient(colors: gradientColors(for: user.gender)),
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.14))
            )
            .shadow(radius: 6)

        Circle()
            .fill(Color.white.opacity(0.05))
            .frame(width: 140, height: 140)
            .offset(x: geo.size.width * 0.55, y: -30)
        Circle()
            .fill(Color.white.opacity(0.025))
            .frame(width: 90, height: 90)
            .offset(x: geo.size.width * 0.75, y: 40)
    }

    private func headerView(geo: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: user.avatarURL ?? user.avatarMediumURL ?? user.avatarThumbURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 120, height: 120)
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    case .failure(_):
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .padding(20)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    @unknown default:
                        Color.clear.frame(width: 120, height: 120)
                    }
                }
                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 2))
                .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(user.fullName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            if let age = user.age {
                                Text("\(age)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }

                        if let username = user.username, !username.isEmpty {
                            Text("@\(username)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .padding(.trailing, 60)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(makeBadges()) { badge in
                                BadgeChip(icon: badge.icon, text: badge.text)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .transaction { t in t.animation = nil }
                    .padding(.top, 2)
                }
            }

            detailsSection()

            Spacer()
        }
        .padding()
    }

    private func detailsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let email = user.email {
                InfoRow(systemImage: "envelope.fill", text: email)
            }
            if let phone = user.phone {
                InfoRow(systemImage: "phone.fill", text: phone)
            }
            if let cell = user.cell {
                InfoRow(systemImage: "teletype", text: cell)
            }

            if user.city != nil || user.state != nil || user.countryName != nil {
                let parts = [user.city, user.state, user.countryName].compactMap { $0 }.joined(separator: ", ")
                InfoRow(systemImage: "mappin.and.ellipse", text: parts)
            }

            if let pc = user.postcode, !pc.isEmpty {
                InfoRow(systemImage: "number.square", text: "Postcode: \(pc)")
            }

            if let lat = user.latitude, let lon = user.longitude {
                InfoRow(systemImage: "location.north.line", text: String(format: "Lat %.4f, Lon %.4f", lat, lon))
            }

            if let tz = user.timezoneOffset {
                InfoRow(systemImage: "clock", text: "Timezone: \(tz)")
            }
            if let reg = user.registeredDate {
                InfoRow(systemImage: "calendar", text: "Registered: \(reg.asShortString())")
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
    }

    private func flagView() -> some View {
        Text(flagEmoji(from: user.country))
            .font(.system(size: 32))
            .frame(width: 44, height: 44, alignment: .center)
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 12)
            .padding(.trailing, 12)
    }


    private func dragGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { v in
                offset = CGSize(width: v.translation.width, height: 0)
            }
            .onEnded { v in
                let threshold = geo.size.width * 0.25
                if v.translation.width > threshold {
                    withAnimation(.easeIn(duration: 0.2)) {
                        offset = CGSize(width: geo.size.width * 1.2, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onAction(.like) }
                } else if v.translation.width < -threshold {
                    withAnimation(.easeIn(duration: 0.2)) {
                        offset = CGSize(width: -geo.size.width * 1.2, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onAction(.dislike) }
                } else {
                    withAnimation(.spring()) { offset = .zero }
                }
            }
    }

    struct Badge: Identifiable, Hashable {
        let id: String
        let icon: String
        let text: String

        init(icon: String, text: String) {
            self.icon = icon
            self.text = text
            self.id = icon + "|" + text
        }
    }

    private func makeBadges() -> [Badge] {
        var items: [Badge] = []

        if let reg = user.registeredDate {
            items.append(Badge(icon: "calendar", text: "Member since \(reg.asShortString())"))
        }

        let locParts = [user.city, user.state, user.countryName].compactMap { $0 }
        if !locParts.isEmpty {
            items.append(Badge(icon: "mappin", text: locParts.joined(separator: ", ")))
        }

        if let age = user.age {
            items.append(Badge(icon: "figure.stand", text: "Age \(age)"))
        }

        return items
    }

    struct BadgeChip: View {
        let icon: String
        let text: String

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.16))
            )
        }
    }

    struct InfoRow: View {
        let systemImage: String
        let text: String

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))
                    .frame(width: 16)

                Text(text)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }
        }
    }

    func gradientColors(for gender: String?) -> [Color] {
        switch gender?.lowercased() {
        case "female":
            return [Color(red: 0.70, green: 0.30, blue: 0.55),
                    Color(red: 0.45, green: 0.15, blue: 0.40)]
        case "male":
            return [Color(red: 0.20, green: 0.35, blue: 0.75),
                    Color(red: 0.10, green: 0.20, blue: 0.55)]
        default:
            return [Color(red: 0.25, green: 0.27, blue: 0.35),
                    Color(red: 0.15, green: 0.17, blue: 0.25)]
        }
    }
}
