import SwiftUI

/// A button that presents an informational popover when tapped.
///
/// The popover displays a title and either a message string or custom content.
/// The button shows a system image icon representing information and can be tinted with a custom color.
/// The popover’s arrow edge can be configured.
///
/// Example usage:
/// ```swift
/// InfoButton(message: "This is important information.")
///
/// InfoButton {
///     VStack {
///         Text("Custom content here")
///         Image(systemName: "star.fill")
///             .foregroundColor(.yellow)
///     }
/// }
/// ```
public struct InfoButton<Content: View>: View {
    @State private var isPresented = false
    
    private let title: String
    private let icon: String
    private let tint: Color?
    private let arrowEdge: Edge?
    private let payload: Payload
    
    /// Initialize with a simple message string to show in the popover.
    /// - Parameters:
    ///   - title: The title displayed in the popover header. Defaults to `"Info"`.
    ///   - message: The message string displayed in the popover body.
    ///   - icon: The system image name for the button icon. Defaults to `"info.circle"`.
    ///   - tint: Optional color to tint the icon. Defaults to `nil`, which applies a secondary label color.
    ///   - arrowEdge: The edge where the popover arrow appears. Defaults to `.top`.
    public init(title: String = "Info", message: String, icon: String = "info.circle", tint: Color? = nil, arrowEdge: Edge? = .top) where Content == EmptyView {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.arrowEdge = arrowEdge
        self.payload = .message(message)
    }
    
    /// Initialize with custom content in the popover.
    /// - Parameters:
    ///   - title: The title displayed in the popover header. Defaults to `"Info"`.
    ///   - icon: The system image name for the button icon. Defaults to `"info.circle"`.
    ///   - tint: Optional color to tint the icon. Defaults to `nil`.
    ///   - arrowEdge: The edge where the popover arrow appears. Defaults to `.top`.
    ///   - content: A view builder returning custom content to show inside the popover.
    public init(title: String = "Info", icon: String = "info.circle", tint: Color? = nil, arrowEdge: Edge? = .top, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.arrowEdge = arrowEdge
        self.payload = .custom(AnyView(content()))
    }
    
    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: icon)
                .foregroundColor(tint ?? .secondary)
        }
        .accessibilityLabel("Information: \(title)")
        .popover(isPresented: $isPresented, arrowEdge: arrowEdge ?? .top) {
            VStack(spacing: 16) {
                Text(title)
                    .font(.appHeader())
                contentView()
                Button("Got it") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: 340)
        }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch payload {
        case .message(let message):
            Text(message)
                .font(.body)
        case .custom(let anyView):
            anyView
        }
    }
    
    private enum Payload {
        case message(String)
        case custom(AnyView)
    }
}

#Preview {
    VStack(spacing: 40) {
        InfoButton(message: "This is a simple informational message to show in the popover.")
        
        InfoButton(title: "Custom Info", icon: "info.circle.fill", tint: .blue) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Here is a list:")
                    .font(.body)
                VStack(alignment: .leading) {
                    Label("First item", systemImage: "1.circle")
                    Label("Second item", systemImage: "2.circle")
                    Label("Third item", systemImage: "3.circle")
                }
                .font(.callout)
                Image(systemName: "hand.tap")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .padding(.top, 8)
            }
        }
    }
    .padding()
    .frame(maxWidth: 400)
}
