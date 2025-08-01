import SwiftUI

// MARK: - Card View
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isDisabled: Bool
    
    init(_ title: String, icon: String, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(_ title: String, icon: String, color: Color = .green, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Background Gradient
struct BackgroundGradient: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "1A1A2E"),
                        Color(hex: "16213E")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E0F2FF"),
                        Color(hex: "F5F9FF")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Modifiers
extension View {
    func standardBackground() -> some View {
        self.background(BackgroundGradient())
    }
    
    func standardPadding() -> some View {
        self.padding(.horizontal)
            .padding(.vertical, 8)
    }
}


