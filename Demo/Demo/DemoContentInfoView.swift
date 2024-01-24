//
//  Created by Timothy Moose on 1/23/24.
//

import SwiftUI

struct DemoContentInfoView: View {

    // MARK: - API

    init<Content> (
        foregroundStyle: any ShapeStyle,
        backgroundStyle: any ShapeStyle,
        borderStyle: any ShapeStyle,
        @ViewBuilder content: @escaping () -> Content
    ) where Content: View {
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
        self.backgroundStyle = AnyShapeStyle(backgroundStyle)
        self.borderStyle = AnyShapeStyle(borderStyle)
        self.content = { AnyView(content()) }
    }

    // MARK: - Constants

    // MARK: - Variables

    private var foregroundStyle: AnyShapeStyle
    private var backgroundStyle: AnyShapeStyle
    private var borderStyle: AnyShapeStyle
    @ViewBuilder private var content: () -> AnyView

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            content()
        }
        .font(.footnote)
        .lineSpacing(3)
        .frame(maxWidth: .infinity)
        .foregroundStyle(foregroundStyle)
        .padding(25)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundStyle)
                .stroke(borderStyle, lineWidth: 2)
        }
    }
}

#Preview {
    DemoContentInfoView(foregroundStyle: Color.white, backgroundStyle: Color.black, borderStyle: Color.yellow) {
        Text("kasjhd lakjd lakjsdf laksjdhf laskjdfh laskdjfh alsdkjfh alskdjfh alsdf")
            .frame(maxWidth: .infinity)
    }
}
