import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .fill(randomPastelColor())
                    .frame(width: 10, height: 10)
                    .offset(x: CGFloat.random(in: -150...150),
                            y: isAnimating ? 600 : -CGFloat.random(in: 0...500))
                    .opacity(0.8)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(
                        .interpolatingSpring(stiffness: 50, damping: 8)
                            .delay(Double(i) * 0.025),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    func randomPastelColor() -> Color {
        let pastelColors: [Color] = [
            Color.pink.opacity(0.8),
            Color.purple.opacity(0.7),
            Color.mint.opacity(0.8),
            Color.yellow.opacity(0.8),
            Color.orange.opacity(0.7)
        ]
        return pastelColors.randomElement() ?? .pink
    }
}
