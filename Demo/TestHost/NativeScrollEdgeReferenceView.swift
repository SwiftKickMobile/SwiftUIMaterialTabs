import SwiftUI

/// Native-only reference for comparing SwiftUI's top scroll-edge effect.
@available(iOS 26.0, *)
struct NativeScrollEdgeReferenceView: View {
    private let environment = ProcessInfo.processInfo.environment
    @State private var referenceOffset: CGFloat = 0
    private var titleHeight: CGFloat { CGFloat(Double(environment["SUIMT_TITLE_HEIGHT"] ?? "150") ?? 150) }
    private var rowCount: Int { Int(environment["SUIMT_ROW_COUNT"] ?? "40") ?? 40 }
    private var visualPattern: Bool { environment["SUIMT_VISUAL_PATTERN"] == "1" }

    var body: some View {
        NavigationStack {
            ScrollView { rows(0) }
                .scrollClipDisabled()
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, offset in referenceOffset = offset }
                .safeAreaBar(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Shared header")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: titleHeight)
                        HStack(spacing: 0) {
                            ForEach(["A", "B", "C"], id: \.self) { title in
                                Button {} label: {
                                    Text(title)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sync-header")
                        .accessibilityValue(Text(verbatim: "tab=0;offset=0;content=\(referenceOffset);max=0;height=\(titleHeight + 46)"))
                    }
                    #if DEBUG
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                        ManualInteractionTrace.recordRowFrame(tab: "native-header", row: -1, frame: frame)
                    }
                    #endif
                }
                .background { if visualPattern { checkerboard.ignoresSafeArea() } }
                .navigationTitle("Native reference")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func rows(_ tab: Int) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { row in
                VStack(spacing: 0) {
                    Text("\(["A", "B", "C"][tab]) — Row \(row)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Divider()
                }
                .frame(height: 100)
                .background {
                    if visualPattern {
                        checkerboard
                    } else {
                        [Color.cyan, .orange, .mint][tab].opacity(row.isMultiple(of: 2) ? 0.2 : 0.4)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("row-\(tab)-\(row)")
                .id(row)
            }
        }
        .scrollTargetLayout()
    }

    private var checkerboard: some View {
        Canvas { context, size in
            let side: CGFloat = 16
            for row in 0..<Int(ceil(size.height / side)) {
                for column in 0..<Int(ceil(size.width / side)) {
                    context.fill(
                        Path(CGRect(x: CGFloat(column) * side, y: CGFloat(row) * side,
                                    width: side, height: side)),
                        with: .color((row + column).isMultiple(of: 2) ? .cyan : .yellow)
                    )
                }
            }
        }
    }
}
