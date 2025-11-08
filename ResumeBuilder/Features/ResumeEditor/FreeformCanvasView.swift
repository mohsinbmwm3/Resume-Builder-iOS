import SwiftUI

struct FreeformCanvasView: View {
    @Binding var resume: Resume
    @State private var selectedID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { addTextBlock() } label: { Label("Text", systemImage: "text.cursor") }
                Button { addImageBlock() } label: { Label("Image", systemImage: "photo") }
                Spacer()
                Text("Drag blocks. Snap to 8pt.").font(.footnote).foregroundStyle(.secondary)
            }.padding(8)

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Color(UIColor.secondarySystemBackground)
                    ForEach(resume.blocks) { block in
                        DraggableBlockView(block: block, isSelected: selectedID == block.id) { newOrigin in
                            update(block.id, to: newOrigin, canvas: geo.size)
                        }
                        .onTapGesture { selectedID = block.id }
                        .zIndex(block.z + (selectedID == block.id ? 1000 : 0))
                    }
                }
            }
        }
    }

    private func addTextBlock() {
        resume.blocks.append(Block(kind: .text, text: "New Text", frame: CGRect(x: 48, y: 48, width: 220, height: 24), z: (resume.blocks.map{ $0.z }.max() ?? 0) + 1))
    }

    private func addImageBlock() { /* present picker later; placeholder */
        resume.blocks.append(Block(kind: .image, imageData: nil, frame: CGRect(x: 64, y: 120, width: 120, height: 80), z: (resume.blocks.map{ $0.z }.max() ?? 0) + 1))
    }

    private func update(_ id: UUID, to origin: CGPoint, canvas: CGSize) {
        guard let i = resume.blocks.firstIndex(where: { $0.id == id }) else { return }
        func snap(_ v: CGFloat) -> CGFloat { (v / 8).rounded() * 8 }
        var x = snap(origin.x)
        var y = snap(origin.y)
        // clamp within canvas
        let w = resume.blocks[i].frame.width
        let h = resume.blocks[i].frame.height
        x = max(0, min(x, canvas.width - w))
        y = max(0, min(y, canvas.height - h))
        resume.blocks[i].frame.origin = CGPoint(x: x, y: y)
    }
}

struct DraggableBlockView: View {
    var block: Block
    var isSelected: Bool
    var onCommit: (CGPoint) -> Void

    @GestureState private var drag = CGSize.zero
    @State private var start: CGPoint = .zero

    var body: some View {
        Group {
            switch block.kind {
            case .text:
                Text(block.text)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: block.frame.width, height: block.frame.height, alignment: .leading)
            case .image:
                ZStack { Rectangle().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4,4])) ; Image(systemName: "photo") }
                    .frame(width: block.frame.width, height: block.frame.height)
            }
        }
        .position(x: block.frame.minX + block.frame.width/2 + drag.width,
                  y: block.frame.minY + block.frame.height/2 + drag.height)
        .padding(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(isSelected ? Color.primary.opacity(0.6) : .clear, lineWidth: 1)
        )
        .gesture(
            DragGesture()
                .updating($drag) { value, state, _ in state = value.translation }
                .onChanged { _ in start = block.frame.origin }
                .onEnded { value in
                    let newOrigin = CGPoint(x: start.x + value.translation.width,
                                            y: start.y + value.translation.height)
                    onCommit(newOrigin)
                }
        )
    }
}

