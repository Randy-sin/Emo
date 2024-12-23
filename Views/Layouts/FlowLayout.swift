import SwiftUI

public struct FlowLayout: Layout {
    public var spacing: CGFloat
    
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        
        for (index, frame) in result.frames.enumerated() {
            let position = CGPoint(
                x: bounds.minX + frame.minX,
                y: bounds.minY + frame.minY
            )
            subviews[index].place(at: position, proposal: ProposedViewSize(frame.size))
        }
    }
    
    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        var frames = [CGRect](repeating: .zero, count: subviews.count)
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        let maxContainerWidth = proposal.width ?? .infinity
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxContainerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames[index] = CGRect(x: currentX, y: currentY, width: size.width, height: size.height)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX)
        }
        
        return (
            frames: frames,
            size: CGSize(
                width: min(maxWidth, maxContainerWidth),
                height: currentY + lineHeight
            )
        )
    }
} 