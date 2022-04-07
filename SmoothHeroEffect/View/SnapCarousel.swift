//
//  SnapCarousel.swift
//  SmoothHeroEffect
//
//  Created by Дмитрий Межевич on 6.04.22.
//

import SwiftUI

struct SnapCarousel<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]

    var trailingSpace: CGFloat
    var spacing: CGFloat
    @Binding var index: Int
    
    @State var currentIndex: Int = 0
    @GestureState var offset: CGFloat = 0
    
    init(
        trailingSpace: CGFloat = 150,
        spacing: CGFloat = 15,
        index: Binding<Int>,
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.trailingSpace = trailingSpace
        self.spacing = spacing
        self._index = index
        self.list = list
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            
            let width: CGFloat = proxy.size.width - (trailingSpace - spacing)
            let adjustmentSpace: CGFloat = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                        .offset(y: getCardOffset(item: item, width: width))
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? (currentIndex == list.count - 1 ? 2*adjustmentSpace : adjustmentSpace) : 0) + offset)
            .gesture(
            
            DragGesture()
                .updating($offset, body: { value, out, _ in
                    out = value.translation.width / 1.5
                })
                .onChanged({ value in
                    
                    let offsetX = value.translation.width
                    
                    let progress = -offsetX / width
                    
                    let rounded = progress.rounded()
                    
                    index = max(min(currentIndex + Int(rounded), list.count - 1), 0)
                })
                .onEnded({ value in
                    let offsetX = value.translation.width
                    
                    let progress = -offsetX / width
                    
                    let rounded = progress.rounded()
                    
                    currentIndex = max(min(currentIndex + Int(rounded), list.count - 1), 0)
                    
                    index = currentIndex
                })
            )
            .animation(.spring(), value: offset == 0)
        }
    }
    
    func getCardOffset(item: T, width: CGFloat) -> CGFloat {
        
        let progress = ((offset < 0 ? offset : -offset) / width) * 60
        
        let topOffset = -progress < 60 ? progress : -(progress + 120)
        
        let previous = getIndex(item: item) - 1 == currentIndex ? (offset < 0 ? topOffset : -topOffset) : 0
        
        let next = getIndex(item: item) + 1 == currentIndex ? (offset < 0 ? -topOffset : topOffset) : 0
        
        let checkCard = currentIndex >= 0 && currentIndex < list.count ? (getIndex(item: item) - 1 == currentIndex ? previous : next) : 0
        
        return getIndex(item: item) == currentIndex ? -60 - topOffset : checkCard
    }
    
    func getIndex(item: T) -> Int {
        list.firstIndex { object in
            object.id == item.id
        } ?? 0
    }
    
}

extension View {
    func getRect() -> CGRect {
        UIScreen.main.bounds
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
