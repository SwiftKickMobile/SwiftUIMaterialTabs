//
//  Created by Timothy Moose on 1/21/24.
//

import SwiftUI

struct PrimaryTab: View {

    // MARK: - API

    init(
        isSelected: Bool,
        tapped: @escaping () -> Void,
        title: String,
        icon: Image
    ) {
        self.isSelected = isSelected
        self.tapped = tapped
        self.title = title
        self.icon = AnyView(icon.resizable().aspectRatio(contentMode: .fit))
    }

    init<Icon>(
        isSelected: Bool,
        tapped: @escaping () -> Void,
        title: String,
        icon: Icon
    ) where Icon: View {
        self.isSelected = isSelected
        self.tapped = tapped
        self.title = title
        self.icon = AnyView(icon)
    }

    // MARK: - Constants

    // MARK: - Variables

    private let isSelected: Bool
    private let tapped: () -> Void
    private let title: String
    private let icon: AnyView
    @Environment(\.font) private var font: Font?

    // MARK: - Body

    var body: some View {
        Button(action: tapped) {
            VStack(spacing: 0) {
                icon
                    .frame(height: 30)
                    .padding(.top, 10)
                Text(title)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                    .background(alignment: .bottom) {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.primary)
                                .frame(height: 8)
                                .offset(CGSize(width: 0, height: 4))
                        }
                    }
                    .clipped()
                    .padding(.horizontal, 10)
                Rectangle().fill(.secondary)
                    .frame(height: 1)
            }
            .contentShape(Rectangle())
            .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}

#Preview {
    VStack() {
        PrimaryTab(isSelected: true, tapped: { print("tapped" )}, title: "Tab Title", icon: Image(systemName: "medal"))
            .background(.black.opacity(0.05))
        PrimaryTab(isSelected: false, tapped: { print("tapped" )}, title: "Tab Title", icon: Image(systemName: "lamp.table"))
            .background(.black.opacity(0.05))
    }
    .padding()
}
