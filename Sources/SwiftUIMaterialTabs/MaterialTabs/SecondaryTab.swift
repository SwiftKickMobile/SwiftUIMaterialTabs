//
//  Created by Timothy Moose on 1/21/24.
//

import SwiftUI

/// An implementation of the [Google Material 3 secondary tab style](https://m3.material.io/components/tabs/overview).
/// While these views may be constructed directly, typically, they are only directly referenced in the `materialTabItem()` view modifier configuration
/// parameters and subsequently constructed by the system.
public struct SecondaryTab<Tab>: View where Tab: Hashable {

    // MARK: - API

    public struct Config {
        public var font: Font?
        public var titleStyle: (any ShapeStyle)?
        public var underlineStyle: (any ShapeStyle)?
        public var underlineThickness: CGFloat
        public var backgroundStyle: (any ShapeStyle)?
        public var padding: EdgeInsets

        public init(
            font: Font? = .system(size: 13, weight: .bold),
            titleStyle: (any ShapeStyle)? = nil,
            selectedTextStyle: (any ShapeStyle)? = nil,
            underlineStyle: (any ShapeStyle)? = nil,
            underlineThickness: CGFloat = 2,
            backgroundStyle: (any ShapeStyle)? = nil,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 10, bottom: 10, trailing: 10)
        ) {
            self.font = font
            self.titleStyle = titleStyle
            self.underlineStyle = underlineStyle
            self.underlineThickness = underlineThickness
            self.backgroundStyle = backgroundStyle
            self.padding = padding
        }
    }

    public init(
        tab: Tab,
        context: MaterialTabsHeaderContext<Tab>,
        tapped: @escaping () -> Void,
        title: String,
        config: Config,
        deselectedConfig: Config?
    ) {
        self.tab = tab
        self.context = context
        self.tapped = tapped
        self.title = title
        self.config = config
        self.deselectedConfig = deselectedConfig ?? config.makeDeselectedConfig()
    }

    // MARK: - Constants

    // MARK: - Variables

    @Environment(\.font) private var font
    private let tab: Tab
    private let context: MaterialTabsHeaderContext<Tab>
    private let tapped: () -> Void
    private let title: String
    private let config: Config
    private let deselectedConfig: Config
    @Namespace private var initialNamespace

    private var activeConfig: Config {
        return switch tab == context.selectedTab {
        case true: config
        case false: deselectedConfig
        }
    }

    private var titleStyle: AnyShapeStyle {
        activeConfig.titleStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.tint)
    }

    private var underlineStyle: AnyShapeStyle {
        activeConfig.underlineStyle.map { AnyShapeStyle($0) }
            ?? (tab == context.selectedTab ? titleStyle : AnyShapeStyle(Color.clear))
    }

    private var deselectedUnderlineStyle: AnyShapeStyle {
        deselectedConfig.underlineStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(Color.clear)
    }

    private var backgroundStyle: AnyShapeStyle {
        activeConfig.backgroundStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(Color.clear)
    }

    // MARK: - Body

    public var body: some View {
        Button(action: tapped) {
            VStack(spacing: 0) {
                Text(title)
                    .font(activeConfig.font ?? font)
                    .foregroundStyle(titleStyle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(activeConfig.padding)
            }
            .contentShape(Rectangle())
        }
        .background(alignment: .bottom) {
            ZStack {
                Rectangle()
                    .fill(deselectedUnderlineStyle)
                    .frame(height: deselectedConfig.underlineThickness)
                    .zIndex(-1)
                if tab == context.selectedTab {
                    Rectangle()
                        .fill(underlineStyle)
                        .transition(.noTransition)
                        .matchedGeometryEffect(
                            id: "underline",
                            in: context.animationNamespace ?? initialNamespace
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: activeConfig.underlineThickness)
        }
        .background(backgroundStyle)
        .transaction(value: context.selectedTab) { transform in
            transform.animation = .snappy(duration: 0.35, extraBounce: 0.07)
        }
    }
}

public extension SecondaryTab.Config {
    func makeDeselectedConfig() -> Self {
        var config = self
        switch config.titleStyle {
        case let textStyle?:
            config.titleStyle = textStyle.opacity(0.7)
        case .none:
            config.titleStyle = .secondary
        }
        config.underlineStyle = nil
        return config
    }
}

#Preview {
    let customConfig = SecondaryTab<Int>.Config(
        font: .system(size: 18, weight: .light).italic(),
        titleStyle: Color.black,
        underlineStyle: Color.purple,
        underlineThickness: 4,
        backgroundStyle: Color.green
    )

    let customDeselectedConfig = SecondaryTab<Int>.Config(
        font: .system(size: 10, weight: .black),
        titleStyle: Color.purple,
        underlineStyle: Color.red,
        underlineThickness: 10,
        backgroundStyle: Gradient(colors: [.yellow, .orange])
    )

    let context = MaterialTabsHeaderContext<Int>(selectedTab: 0)

    return VStack() {
        SecondaryTab(
            tab: 0,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            config: .init(),
            deselectedConfig: nil
        )
        .background(.black.opacity(0.05))
        SecondaryTab(
            tab: 1,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            config: .init(),
            deselectedConfig: nil
        )
        .background(.black.opacity(0.05))
        SecondaryTab(
            tab: 0,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            config: customConfig,
            deselectedConfig: customDeselectedConfig
        )
        SecondaryTab(
            tab: 1,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            config: customConfig,
            deselectedConfig: customDeselectedConfig
        )
    }
    .padding()
}
