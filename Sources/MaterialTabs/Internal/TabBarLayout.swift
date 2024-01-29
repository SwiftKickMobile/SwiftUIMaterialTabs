//
//  Created by Timothy Moose on 1/21/24.
//

import SwiftUI

public struct TabBarLayout<Tab>: Layout where Tab: Hashable {

    // MARK: - API

    public init(fittingWidth: CGFloat, sizing: MaterialTabBar<Tab>.Sizing) {
        self.fittingWidth = fittingWidth
        self.sizing = sizing
    }

    // MARK: - Constants

    public struct Cache {
        fileprivate var sizes: [Int: CGSize] = [:]
    }

    // MARK: - Variables

    private let fittingWidth: CGFloat
    private let sizing: MaterialTabBar<Tab>.Sizing

    // MARK: - Layout

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let nillProposal = ProposedViewSize(width: nil, height: nil)
        for (index, subview) in subviews.enumerated() {
            cache.sizes[index] = subview.sizeThatFits(nillProposal)
        }
        let maxSize: CGSize = cache.sizes.reduce(CGSize(width: 0, height: proposal.height ?? 0)) { maxSize, element in
            CGSize(width: max(element.value.width, maxSize.width), height: max(element.value.height, maxSize.height))
        }
        let totalWidth: CGFloat = {
            switch sizing {
            case .proportionalWidth:
                cache.sizes.reduce(0) { sum, element in
                   sum + element.value.width
               }
            case .equalWidth:
                maxSize.width * CGFloat(subviews.count)
            }
        }()
        let height = max(proposal.height ?? 0, maxSize.height)
        let horizontalPadding: CGFloat = max(0, (fittingWidth - totalWidth) / CGFloat(subviews.count))
        for (index, size) in cache.sizes {
            cache.sizes[index] = CGSize(
                width: {
                    switch sizing {
                    case .proportionalWidth: size.width + horizontalPadding
                    case .equalWidth: maxSize.width + horizontalPadding
                    }
                }(),
                height: height
            )
        }
        return CGSize(width: max(fittingWidth, totalWidth), height: maxSize.height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var origin = bounds.origin
        for (index, subview) in subviews.enumerated() {
            let size = cache.sizes[index]!
            subview.place(at: origin, proposal: ProposedViewSize(size))
            origin.x += size.width
        }
    }

    public func makeCache(subviews: Self.Subviews) -> Cache {
        return Cache()
    }
}

#Preview("Scrolling, proportional") {
    GeometryReader { proxy in
        ScrollView(.horizontal) {
            TabBarLayout<Int>(fittingWidth: proxy.size.width, sizing: .proportionalWidth) {
                Text("AAAAAAAAAA")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                Text("BBB")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(.green)
                Text("CCCCCCC")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(.orange)
                Text("D")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(.purple)
                Text("EEEEEEEEEEEEEEEEEEE")
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    .background(.teal)
            }
        }
    }
}

#Preview("Scrolling, equal") {
    GeometryReader { proxy in
        ScrollView(.horizontal) {
            TabBarLayout<Int>(fittingWidth: proxy.size.width, sizing: .equalWidth) {
                Text("AAAAAAAAAA")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                Text("BBB")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green)
                Text("CCCCCCC")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.orange)
                Text("D")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.purple)
                Text("EEEEEEEEEEEEEEEEEEE")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.teal)
            }
        }
    }
}

#Preview("Fitting, proportional") {
    GeometryReader { proxy in
        ScrollView(.horizontal) {
            TabBarLayout<Int>(fittingWidth: proxy.size.width, sizing: .proportionalWidth) {
                Text("AAAAAAA")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                Text("BB")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green)
                Text("CCCCC")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.orange)
            }
        }
    }
}

#Preview("Fitting, equal") {
    GeometryReader { proxy in
        ScrollView(.horizontal) {
            TabBarLayout<Int>(fittingWidth: proxy.size.width, sizing: .equalWidth) {
                Text("AAAAAAA")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                Text("BB")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.green)
                Text("CCCCC")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.orange)
            }
        }
    }
}

