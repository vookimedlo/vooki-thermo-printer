//
//  IndicatorValueSlider.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct IndicatorValueSlider<Label> : View where Label : View  {
    
    @Binding var value: Int
    private let minValue: Int
    private let maxValue: Int
    
    @ViewBuilder private let label: Label
    
    private let controlColor = Color(NSColor.disabledControlTextColor)
    private let controlAccentColor = Color.accentColor
    private let controlBackgroundColor = Color(NSColor.controlBackgroundColor)
    private let textColor = Color(nsColor: NSColor.labelColor)

    private let indicatorRadius: CGFloat = 12
    @State private var isDragging: Bool = false
    
    init(value: Binding<Int>, minValue: Int, maxValue: Int, @ViewBuilder label: @escaping () -> Label) {
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.label = label()
    }
    
    var body: some View {
        LabeledContent {
            GeometryReader { geometry in
                ZStack(alignment: .leading){
                    renderTrack(geometry: geometry)

                    marker(geometryProxy: geometry, divider: 1 / 4)
                    marker(geometryProxy: geometry, divider: 1 / 2)
                    marker(geometryProxy: geometry, divider: 3 / 4)
                    
                    ZStack { renderHighlightedTrack(geometry: geometry) }
                    
                    renderIndicator(geometry: geometry)
                }.gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ gesture in
                        if gesture.velocity != CGSize(width: 0, height: 0) {
                            isDragging = true
                            updateValue(with: gesture, in: geometry)
                        }
                    })
                        .onEnded({gesture in
                            if isDragging {
                                isDragging = false
                            } else {
                                updateValue(with: gesture, in: geometry)
                            }
                        })
                ).animation(isDragging ? .none : .interpolatingSpring, value: value)
            }
            .padding(.horizontal)
        } label: {
            self.label.offset(y: -25/3)
        }.frame(height: 25)
    }
    
    @ViewBuilder
    private func renderTrack(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(controlColor.opacity(0.5))
            .frame(width: geometry.size.width, height: 3)
    }
    
    private func originPoint() -> Int {
        if minValue <= 0 && 0 <= maxValue {
            return 0
        }
        return maxValue < 0 ? maxValue : minValue
    }

    @ViewBuilder
    private func renderHighlightedTrack(geometry: GeometryProxy) -> some View {
        let percentsOfTrackForSelectedValue = geometry.size.width * percents(from: value)
        let percentsOfTrackForOrigin = geometry.size.width * percents(from: originPoint())
        let highlightedTrackWidth = abs(percentsOfTrackForSelectedValue - percentsOfTrackForOrigin)
        let offset = value >= originPoint() ? percentsOfTrackForOrigin : percentsOfTrackForSelectedValue

        Rectangle()
            .fill(controlAccentColor)
            .frame(width: highlightedTrackWidth, height: 4)
            .offset(x: offset)
    }
    
    @ViewBuilder
    private func renderIndicator(geometry: GeometryProxy) -> some View {
        let percentsOfTrackForSelectedValue = percents(from: value) * geometry.size.width
        Circle()
            .fill(controlBackgroundColor)
            .stroke(controlAccentColor, lineWidth: 3)
            .frame(width: indicatorRadius * 2, alignment: .center)
            .offset(x: percentsOfTrackForSelectedValue - indicatorRadius )
            .overlay {
                Text("\(value)")
                    .foregroundStyle(textColor)
                    .frame(width: 35, height: 35, alignment: .center)
                    .offset(x: percentsOfTrackForSelectedValue - indicatorRadius)
                    .fontWidth(Font.Width.compressed)
                    .animation(isDragging ? .none : .interpolatingSpring(duration: 1.5), value: value)
            }
    }
    
    @ViewBuilder
    private func marker(geometryProxy: GeometryProxy, divider: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(controlColor.opacity(0.5))
            .frame(width: 2, height: 10, alignment: .center)
            .offset(x: geometryProxy.size.width * divider - 1)
    }
    
    private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let percents = min(max(gesture.location.x / geometry.size.width, 0), 1)
        self.value = Int((Double(maxValue - minValue) * percents + Double(minValue)).rounded(.down))
    }
    
    private func percents(from value: Int) -> CGFloat {
        if (value == minValue) { return 0 }
        if (value == maxValue) { return 1 }
        return Double(value - minValue) / Double((maxValue - minValue))
    }
}

struct IndicatorValueSliderPreview: PreviewProvider {
    struct ContainerView: View {
        @State var value1: Int = 0
        @State var value2: Int = 0
        @State var value3: Int = 0
        @State var value4: Int = 0
        @State var value5: Int = 30
        @State var value6: Int = -30

        var body: some View {
            Form {
                IndicatorValueSlider(value: $value1,
                                     minValue: 0,
                                     maxValue: 100,
                                     label: { Text("Font size").font(.headline) } )
                IndicatorValueSlider(value: $value2,
                                     minValue: -100,
                                     maxValue: 100,
                                     label: { Text("Font size").font(.headline) } )
                IndicatorValueSlider(value: $value3,
                                     minValue: -20,
                                     maxValue: 70,
                                     label: { Text("Font size").font(.headline) } )
                IndicatorValueSlider(value: $value4,
                                     minValue: -70,
                                     maxValue: 20,
                                     label: { Text("Font size").font(.headline) } )
                IndicatorValueSlider(value: $value5,
                                     minValue: 20,
                                     maxValue: 70,
                                     label: { Text("Font size").font(.headline) } )
                IndicatorValueSlider(value: $value6,
                                     minValue: -70,
                                     maxValue: -20,
                                     label: { Text("Font size").font(.headline) } )
            }
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

#Preview {
    IndicatorValueSliderPreview.previews
}
