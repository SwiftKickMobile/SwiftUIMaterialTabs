//
//  Created by Timothy Moose on 1/21/24.
//

import SwiftUI

public struct SecondaryTab: View {

    // MARK: - API

    public struct Config {
        public var font: Font?
        public var textStyle: (any ShapeStyle)?
        public var underlineStyle: (any ShapeStyle)?
        public var underlineThickness: CGFloat
        public var backgroundStyle: (any ShapeStyle)?
        public var padding: EdgeInsets

        public init(
            font: Font? = .system(size: 13, weight: .bold),
            textStyle: (any ShapeStyle)? = nil,
            selectedTextStyle: (any ShapeStyle)? = nil,
            underlineStyle: (any ShapeStyle)? = nil,
            underlineThickness: CGFloat = 2,
            backgroundStyle: (any ShapeStyle)? = nil,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 10, bottom: 10, trailing: 10)
        ) {
            self.font = font
            self.textStyle = textStyle
            self.underlineStyle = underlineStyle
            self.underlineThickness = underlineThickness
            self.backgroundStyle = backgroundStyle
            self.padding = padding
        }
    }

    init(
        isSelected: Bool,
        tapped: @escaping () -> Void,
        title: String,
        config: Config,
        deselectedConfig: Config?
    ) {
        self.isSelected = isSelected
        self.tapped = tapped
        self.title = title
        self.config = config
        switch deselectedConfig {
        case let deselectedConfig?:
            self.deselectedConfig = deselectedConfig
        case .none:
            var deselectedConfig = config
            deselectedConfig.underlineStyle = Color.clear
            switch deselectedConfig.textStyle {
            case let textStyle?:
                deselectedConfig.textStyle = textStyle.opacity(0.7)
            case .none:
                deselectedConfig.textStyle = .secondary
            }
            self.deselectedConfig = deselectedConfig
        }
    }

    // MARK: - Constants

    // MARK: - Variables

    @Environment(\.font) private var font
    private let isSelected: Bool
    private let tapped: () -> Void
    private let title: String
    private let config: Config
    private let deselectedConfig: Config

    private var activeConfig: Config {
        switch isSelected {
        case true: config
        case false: deselectedConfig
        }
    }

    private var textForegroundStyle: AnyShapeStyle {
        activeConfig.textStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.foreground)
    }

    private var backgroundStyle: AnyShapeStyle {
        activeConfig.backgroundStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(Color.clear)
    }

    private var underlineFillStyle: AnyShapeStyle {
        activeConfig.underlineStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.primary)
    }

    // MARK: - Body

    public var body: some View {
        Button(action: tapped) {
            VStack(spacing: 0) {
                Text(title)
                    .font(activeConfig.font ?? font)
                    .foregroundStyle(textForegroundStyle)
                    .padding(activeConfig.padding)
                Rectangle()
                    .fill(underlineFillStyle)
                    .frame(height: activeConfig.underlineThickness)
            }
            .contentShape(Rectangle())
            .background(backgroundStyle)
        }
    }
}

#Preview {
    let customConfig = SecondaryTab.Config(
        font: .system(size: 18, weight: .light).italic(),
        textStyle: Color.black,
        underlineStyle: Color.purple,
        underlineThickness: 4,
        backgroundStyle: Color.green
    )

    let customDeselectedConfig = SecondaryTab.Config(
        font: .system(size: 10, weight: .black),
        textStyle: Color.purple,
        underlineStyle: Color.red,
        underlineThickness: 10,
        backgroundStyle: Gradient(colors: [.yellow, .orange])
    )

    return VStack() {
        SecondaryTab(isSelected: true, tapped: { print("tapped" )}, title: "Tab Title", config: .init(), deselectedConfig: nil)
            .background(.black.opacity(0.05))
        SecondaryTab(isSelected: false, tapped: { print("tapped" )}, title: "Tab Title", config: .init(), deselectedConfig: nil)
            .background(.black.opacity(0.05))
        SecondaryTab(isSelected: true, tapped: { print("tapped" )}, title: "Tab Title", config: customConfig, deselectedConfig: customDeselectedConfig)
            .background(.black.opacity(0.05))
        SecondaryTab(isSelected: false, tapped: { print("tapped" )}, title: "Tab Title", config: customConfig, deselectedConfig: customDeselectedConfig)
            .background(.black.opacity(0.05))
    }
    .padding()
}
