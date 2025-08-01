import SwiftUI

enum Theme {
    // MARK: - Colors
    static let primary = Color(hex: "007AFF")  // iOS Blue
    static let secondary = Color.secondary
    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let success = Color(hex: "34C759")  // iOS Green
    static let warning = Color(hex: "FF9500")  // iOS Orange
    static let error = Color(hex: "FF3B30")    // iOS Red
    
    // MARK: - Gradients
    enum Gradients {
        static let background = LinearGradient(
            colors: [
                Color(hex: "E0F2FF"),  // Soft Sky Blue
                Color(hex: "F5F9FF"),  // Light Blue White
                Color(hex: "F0F8FF")   // Alice Blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let darkBackground = LinearGradient(
            colors: [
                Color(hex: "1A1A2E"),  // Deep Navy
                Color(hex: "16213E"),  // Midnight Blue
                Color(hex: "1A1A2E")   // Deep Navy
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardBackground = LinearGradient(
            colors: [
                Color.white.opacity(0.95),
                Color.white.opacity(0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let darkCardBackground = LinearGradient(
            colors: [
                Color(hex: "2C3E50").opacity(0.8),
                Color(hex: "2C3E50").opacity(0.6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let accentOverlay = LinearGradient(
            colors: [
                primary.opacity(0.1),
                primary.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography with Accessibility
    enum Typography {
        static func title(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .dynamicTypeSize(...(.accessibility3))
                .foregroundColor(.primary)
                .accessibilityHeading(.h1)
        }
        
        static func heading(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .dynamicTypeSize(...(.accessibility2))
                .foregroundColor(.primary)
                .accessibilityHeading(.h2)
        }
        
        static func body(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .dynamicTypeSize(...(.accessibility1))
                .foregroundColor(.primary)
        }
        
        static func caption(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .dynamicTypeSize(...(.accessibility1))
        }
    }
    
    // MARK: - Layout with Accessibility
    enum Layout {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let minimumTapArea: CGFloat = 44
        
        static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            content()
                .padding()
                .background(
                    Group {
                        if UITraitCollection.current.userInterfaceStyle == .dark {
                            Theme.Gradients.darkCardBackground
                        } else {
                            Theme.Gradients.cardBackground
                        }
                    }
                )
                .cornerRadius(cornerRadius)
                .shadow(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        }
        
        static func accessibleButton<Content: View>(
            action: @escaping () -> Void,
            @ViewBuilder label: () -> Content
        ) -> some View {
            Button(action: action) {
                label()
                    .frame(minWidth: minimumTapArea, minHeight: minimumTapArea)
            }
            .hoverEffect()
            .accessibilityAddTraits(.isButton)
        }
    }
    
    // MARK: - Animation
    enum Animation {
        static let `default` = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let slow = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    }
    
    // MARK: - Accessibility
    enum Accessibility {
        static func buttonLabel(_ label: String, hint: String? = nil) -> some View {
            Text(label)
                .accessibilityLabel(label)
                .accessibilityHint(hint ?? "")
                .accessibilityAddTraits(.isButton)
        }
        
        static func image(_ name: String, label: String) -> some View {
            Image(systemName: name)
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isImage)
        }
    }
}

// MARK: - View Extensions for Accessibility
extension View {
    func accessibleTapArea() -> some View {
        self.frame(minWidth: Theme.Layout.minimumTapArea, minHeight: Theme.Layout.minimumTapArea)
    }
    
    func hoverEffect(_ effect: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: effect)
            generator.impactOccurred()
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
