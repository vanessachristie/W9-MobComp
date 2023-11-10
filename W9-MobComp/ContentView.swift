//
//  ContentView.swift
//  W9-MobComp
//
//  Created by MacBook Pro on 10/11/23.
//

import SwiftUI

struct MTGCardView: View {
    var card: MTGCard
    
    var body: some View {
        VStack(spacing: 16) {
            // Display card image
            AsyncImage(url: URL(string: card.image_uris?.large ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15) // Add corner radius for a rounded image
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .cornerRadius(15) // Add corner radius for a rounded image
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
            .frame(maxHeight: 200) // Set a maximum height for the image view

            // Display card name
            Text(card.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            
            VStack(alignment: .leading, spacing: 8) {
                Text("Type: \(card.type_line)")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Oracle Text: \(card.oracle_text)")
                    .font(.body)
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
    }
}


struct ContentView: View {
    @State private var mtgCards: [MTGCard] = []
    @State private var searchText: String = ""

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // Three cards per row

    var filteredCards: [MTGCard] {
        if searchText.isEmpty {
            return mtgCards
        } else {
            return mtgCards.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    struct SearchBar: View {
        @Binding var text: String

        var body: some View {
            HStack {
                TextField("Search", text: $text)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
            }
            .padding(.top, 8)
        }
    }
    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    // Search Bar
                    SearchBar(text: $searchText)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredCards) { card in
                            NavigationLink(destination: MTGCardView(card: card)) {
                                CardImageView(card: card)
                                    .frame(height: 200) // Adjust the image height as needed
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    // Load data from a JSON file
                    if let data = loadJSON() {
                        do {
                            let decoder = JSONDecoder()
                            let cards = try decoder.decode(MTGCardList.self, from: data)
                            mtgCards = cards.data
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
                .navigationBarTitle("MTG Cards")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }


            Text("Collection")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Collection")
                }

            Text("Decks")
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Decks")
                }

            Text("Scan")
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }
        }
    }
    
    // Function to load data from a JSON file
    func loadJSON() -> Data? {
        if let path = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardImageView: View {
    var card: MTGCard
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: card.image_uris?.large ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Adjust the corner radius as needed
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Adjust the corner radius as needed
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
            
            Text(card.name)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.top, 8)
        }
    }
}

