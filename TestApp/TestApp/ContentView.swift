//
//  ContentView.swift
//  TestApp
//
//  Created by Tran, Heather on 4/13/26.
//

import SwiftUI

// MARK: - MODELS

struct Destination: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let image: String
    let description: String
    let neighborhoods: [String]
    let foods: [String]
    let itinerary: [ItineraryItem]
}

struct ItineraryItem: Identifiable {
    let id = UUID()
    let time: String
    let activity: String
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct Suggestion: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String
}

// MARK: - GOOGLE PLACES MODELS

struct GooglePlacesResponse: Codable {
    let places: [GooglePlace]?
}

struct GooglePlace: Codable, Identifiable {
    let id: String
    let displayName: DisplayName?
    let formattedAddress: String?
    let rating: Double?
    let photos: [GooglePhoto]?
    
    // A handy computed property to get the name string easily
    var name: String {
        displayName?.text ?? "Unknown Place"
    }
}

struct DisplayName: Codable {
    let text: String
}

struct GooglePhoto: Codable {
    let name: String // Looks like: "places/PLACE_ID/photos/PHOTO_REFERENCE"
}

// MARK: - DATA

let destinations = [
    Destination(
        name: "Vietnam",
        country: "Vietnam",
        image: "rice",
        description: "Street food, culture, tropical beauty, and vibrant city life.",
        neighborhoods: ["Hanoi Old Quarter", "Hoi An", "Da Nang"],
        foods: ["Pho", "Banh Mi", "Egg Coffee"],
        itinerary: [
            ItineraryItem(time: "8:00 AM", activity: "Pho breakfast"),
            ItineraryItem(time: "11:00 AM", activity: "Walk Old Quarter"),
            ItineraryItem(time: "3:00 PM", activity: "Temple visit"),
            ItineraryItem(time: "8:00 PM", activity: "Night market")
        ]
    ),

    Destination(
        name: "Tokyo",
        country: "Japan",
        image: "fuji",
        description: "Tokyo blends futuristic energy with deep tradition.",
        neighborhoods: ["Shibuya", "Shinjuku", "Harajuku", "Asakusa"],
        foods: ["Sushi", "Ramen", "Wagyu", "Matcha"],
        itinerary: [
            ItineraryItem(time: "9:00 AM", activity: "Visit Meiji Shrine"),
            ItineraryItem(time: "12:00 PM", activity: "Lunch in Shibuya"),
            ItineraryItem(time: "3:00 PM", activity: "Shop Harajuku"),
            ItineraryItem(time: "8:00 PM", activity: "Shibuya Crossing")
        ]
    ),

    Destination(
        name: "Paris",
        country: "France",
        image: "paris",
        description: "Romantic streets, timeless architecture, and world-famous cuisine.",
        neighborhoods: ["Le Marais", "Montmartre", "Latin Quarter"],
        foods: ["Croissants", "Macarons", "Steak Frites"],
        itinerary: [
            ItineraryItem(time: "9:00 AM", activity: "Coffee + croissant"),
            ItineraryItem(time: "11:00 AM", activity: "Eiffel Tower"),
            ItineraryItem(time: "2:00 PM", activity: "Louvre Museum"),
            ItineraryItem(time: "7:00 PM", activity: "Seine River walk")
        ]
    )
]

let categories = [
    CategoryItem(name: "Food", icon: "fork.knife", color: .orange),
    CategoryItem(name: "Activities", icon: "figure.walk", color: .blue),
    CategoryItem(name: "Local", icon: "building.2", color: .green),
    CategoryItem(name: "Nightlife", icon: "moon.stars.fill", color: .purple)
]

// MARK: - API VIEWMODEL

class GooglePlacesViewModel: ObservableObject {
    @Published var places: [GooglePlace] = []
    @Published var isLoading = false

    func fetch(category: String, city: String) {
        isLoading = true
        
        let apiKey = "AIzaSyA_VkdtWwqScWsmG-37lnDfH9GWqb-Ne8Y" // ⚠️ Replace with your actual key
        
        guard let url = URL(string: "https://places.googleapis.com/v1/places:searchText") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        
        // The Field Mask is REQUIRED. It tells Google exactly what data to return.
        request.setValue("places.id,places.displayName,places.formattedAddress,places.rating,places.photos", forHTTPHeaderField: "X-Goog-FieldMask")
        
        let requestBody: [String: Any] = [
            "textQuery": "\(category) in \(city)",
            "maxResultCount": 20
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async { self.isLoading = false }
            
            guard let data = data else {
                print("Error or no data: \(String(describing: error))")
                return
            }
            
            if let decoded = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.places = decoded.places ?? []
                }
            } else {
                print("Failed to decode Google JSON")
            }
        }.resume()
    }
}

// MARK: - MAIN APP

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
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

// MARK: - HOME VIEW

struct HomeView: View {
    @State private var selectedIndex = 0
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    Text("Discover")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 16)

                    TabView(selection: $selectedIndex) {
                        ForEach(Array(destinations.enumerated()), id: \.offset) { index, destination in

                            NavigationLink(destination: DestinationDetailView(destination: destination)) {
                                DestinationCard(destination: destination)
                                    .padding(.horizontal, 16)
                                    .tag(index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 260)
                    .tabViewStyle(.page)

                    Text("Popular Categories")
                        .font(.title2.bold())
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories) { category in
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                CategoryCard(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - EXPLORE VIEW

struct ExploreView: View {
    @State private var searchText = ""
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var filteredDestinations: [Destination] {
            if searchText.isEmpty {
                return destinations
            } else {
                return destinations.filter { destination in
                    destination.name.localizedCaseInsensitiveContains(searchText) ||
                    destination.country.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        if searchText.isEmpty {
                            Text("Explore")
                                .font(.largeTitle.bold())
                                .padding(.horizontal, 16)

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(categories) { category in
                                    NavigationLink(destination: CategoryDetailView(category: category)) {
                                        CategoryCard(category: category)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)

                            Text("Trending Cities")
                                .font(.title2.bold())
                                .padding(.horizontal, 16)
                        }

                        LazyVStack(spacing: 14) {
                            if filteredDestinations.isEmpty {
                                Text("No cities found for '\(searchText)'")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(filteredDestinations) { destination in
                                    NavigationLink(destination: DestinationDetailView(destination: destination)) {
                                        SmallCityCard(destination: destination)
                                            .padding(.horizontal, 16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle(searchText.isEmpty ? "" : "Search Results")
                .searchable(text: $searchText, prompt: "Search for a city or country...")
            }
        }
    }
// MARK: - DESTINATION DETAIL PAGE

struct DestinationDetailView: View {
    let destination: Destination

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Image(destination.image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipped()
                    .ignoresSafeArea(edges: .top)

                VStack(alignment: .leading, spacing: 18) {

                    Text(destination.name)
                        .font(.largeTitle.bold())

                    Text(destination.description)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()

                    Text("City Breakdown")
                        .font(.title2.bold())

                    ForEach(destination.neighborhoods, id: \.self) { area in
                        Label(area, systemImage: "location.fill")
                    }

                    Divider()

                    Text("Must Try Food")
                        .font(.title2.bold())

                    ForEach(destination.foods, id: \.self) { food in
                        Label(food, systemImage: "fork.knife")
                    }

                    Divider()

                    Text("1 Day Itinerary")
                        .font(.title2.bold())

                    ForEach(destination.itinerary) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.time)
                                .font(.headline)

                            Text(item.activity)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(destination.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - CATEGORY DETAIL VIEW (Google API Implementation)

struct CategoryDetailView: View {
    let category: CategoryItem
    @StateObject var vm = GooglePlacesViewModel()
    
    @State private var selectedCity = "Tokyo"
    let apiKey = "AIzaSyA_VkdtWwqScWsmG-37lnDfH9GWqb-Ne8Y" // ⚠️ Needed for images to load properly!

    let cities = ["Tokyo", "Paris", "Hanoi", "Bangkok", "New York", "Rio de Janeiro"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(category.name)
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                Picker("City", selection: $selectedCity) {
                    ForEach(cities, id: \.self) { city in
                        Text(city)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if vm.isLoading {
                    ProgressView()
                        .padding()
                }

                ForEach(vm.places) { place in
                    VStack(alignment: .leading, spacing: 10) {
                        
                        // Construct the Google Image URL
                        let photoUrlString = place.photos?.first.map { photo in
                            "https://places.googleapis.com/v1/\(photo.name)/media?key=\(apiKey)&maxHeightPx=400&maxWidthPx=400"
                        } ?? ""

                        AsyncImage(url: URL(string: photoUrlString)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(18)

                        Text(place.name)
                            .font(.headline)

                        Text(place.formattedAddress ?? "Unknown location")
                            .foregroundColor(.secondary)

                        Text("⭐️ \(place.rating ?? 0, specifier: "%.1f")")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.fetch(category: category.name, city: selectedCity)
        }
        // ✨ NEW iOS 17 DEPRECATION FIX ✨
        .onChange(of: selectedCity) { oldValue, newValue in
            vm.fetch(category: category.name, city: newValue)
        }
    }
}

// MARK: - COMPONENTS

struct DestinationCard: View {
    let destination: Destination

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            Image(destination.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipped()
                .cornerRadius(24)

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(24)

            VStack(alignment: .leading, spacing: 4) {
                Text(destination.name)
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text(destination.country)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .shadow(radius: 10)
    }
}

struct SmallCityCard: View {
    let destination: Destination

    var body: some View {
        HStack(spacing: 14) {

            Image(destination.image)
                .resizable()
                .scaledToFill()
                .frame(width: 85, height: 85)
                .clipped()
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(destination.name)
                    .font(.headline)

                Text(destination.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CategoryCard: View {
    let category: CategoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(category.color)
                .frame(width: 44, height: 44)
                .background(category.color.opacity(0.2))
                .cornerRadius(12)

            Text(category.name)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - PREVIEW

#Preview {
    ContentView()
}
