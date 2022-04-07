//
//  Home.swift
//  SmoothHeroEffect
//
//  Created by Дмитрий Межевич on 6.04.22.
//

import SwiftUI

struct Home: View {
    
    // MARK: - Animated View Properties
    @State var currentStateTabBar: String = "Films"
    @State var currentIndex: Int = 0
    
    // MARK: - Detail View Properties
    @State var detailMovie: Movie?
    @State var showDetailMovie: Bool = false
    
    @State var currentCardSize: CGSize = .zero
    
    // Environment Value
    @Namespace var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            // BGView
            BGView()
            // MainViewContent
            VStack {
                
                // Custom TabBar
                TabBar()
                
                // SnapCarousel
                SnapCarousel(index: $currentIndex, list: movies) { movie in
                    CardView(movie: movie)
                }
                .padding(.top, 70)
                
                // Custom Indicatior
                Indecator()
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("Popular")
                            .tint(.white)
                            .font(.system(size: 17).bold())
                    }

                    Spacer()
                    
                    Text("See More")
                        .foregroundColor(.blue)
                    
                }
                .padding()
                
                ScrolView()
            }
            .overlay{
                if let movie = detailMovie, showDetailMovie {
                    DetailView(movie: movie, showDetailView: $showDetailMovie, detailMovie: $detailMovie, currentCardSize: $currentCardSize, animation: animation)
                }
            }
        }
    }
}

extension Home {
    
    @ViewBuilder
    func TabBar() -> some View {
        HStack {
            ForEach(["Films", "Localities"], id: \.self) { item in
                
                Button {
                    withAnimation {
                        currentStateTabBar = item
                    }
                } label: {
                    Text(item)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .background(
                        
                            ZStack {
                                if currentStateTabBar == item {
                                    Capsule()
                                        .fill(.regularMaterial)
                                        .environment(\.colorScheme, .dark)
                                        .matchedGeometryEffect(id: "TAB", in: animation)
                                }
                            }
                        )
                }
                
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func BGView() -> some View {
        GeometryReader { proxy in
            
            let size = proxy.size
            
            TabView(selection: $currentIndex) {
                ForEach(movies.indices, id: \.self) { index in
                    
                    Image(movies[index].image)
                        .resizable()
                        .frame(width: size.width, height: size.height)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeIn, value: currentIndex)
            
            let color: Color = colorScheme == .dark ? .black : .white
            
            // Custom Gradient
            LinearGradient(colors: [
                .black,
                .clear,
                color.opacity(0.15),
                color.opacity(0.5),
                color.opacity(0.8),
                color,
                color
            ], startPoint: .top, endPoint: .bottom)
            
            // Blure Effect
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CardView(movie: Movie) -> some View {
        GeometryReader { proxy in
            Image(movie.image)
                .resizable()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .cornerRadius(15)
                .matchedGeometryEffect(id: movie.id, in: animation)
                .aspectRatio(contentMode: .fill)
                .onTapGesture {
                    detailMovie = movie
                    currentCardSize = proxy.size
                    withAnimation(.easeInOut) {
                        showDetailMovie = true
                    }
                }
        }
    }
    
    @ViewBuilder
    func Indecator() -> some View {
        
        HStack(spacing: 6) {
            ForEach(movies.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? .blue : .gray)
                    .scaleEffect(index == currentIndex ? 1.4 : 1)
                    .frame(width: 7, height: 7)
                    .animation(.linear, value: currentIndex)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func ScrolView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(movies) { movie in
                    Image(movie.image)
                        .resizable()
                        .frame(width: 100, height: 120)
                        .cornerRadius(15)
                        .clipped()
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
