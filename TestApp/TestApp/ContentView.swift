//
//  ContentView.swift
//  TestApp
//
//  Created by Tran, Heather on 4/13/26.
//

import SwiftUI

// MARK: - Models

struct Destination: Identifiable {
    let id = UUID()
    let name: String
    let image: String
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

// MARK: - Sample Data

let destinations = [
    Destination(name: "Vietnam", image: "vietnam"),
    Destination(name: "Tokyo", image: "tokyo"),
    Destination(name: "Brazil", image: "brazil"),
    Destination(name: "Paris", image: "paris")
]

let categories = [
    CategoryItem(name: "Food", icon: "fork.knife", color: .orange),
    CategoryItem(name: "Activities", icon: "figure.walk", color: .blue),
    CategoryItem(name: "Local", icon: "building.2", color: .green)
]

// MARK: - Main View

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Explore")
                }
                .tag(1)
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Text("Discover")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(destinations.enumerated()), id: \.offset) { index, destination in
                            DestinationCard(destination: destination)
                                .padding(.horizontal)
                                .scaleEffect(selectedIndex == index ? 1.0 : 0.9)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedIndex)
                                .tag(index)
                        }
                    }
                    .frame(height: 260)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    
                    Text("Popular")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    LazyVStack {
                        ForEach(destinations) { destination in
                            SmallCard(destination: destination)
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Destination Card (Top Carousel)

struct DestinationCard: View {
    let destination: Destination
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(destination.image)
                .resizable()
                .scaledToFill()
                .frame(height: 250)
                .clipped()
                .cornerRadius(20)
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(20)
            
            Text(destination.name)
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding()
        }
        .shadow(radius: 8)
    }
}

// MARK: - Small Card

struct SmallCard: View {
    let destination: Destination
    @State private var appear = false
    
    var body: some View {
        HStack {
            Image(destination.image)
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            
            Text(destination.name)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
    }
}

// MARK: - Explore View

struct ExploreView: View {
    @State private var animate = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Explore")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(categories) { category in
                        CategoryCard(category: category, animate: animate)
                    }
                }
                .padding()
            }
            .onAppear {
                animate = true
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: CategoryItem
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: category.icon)
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text(category.name)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [category.color, category.color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(radius: 8)
        .scaleEffect(animate ? 1 : 0.8)
        .opacity(animate ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animate)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
