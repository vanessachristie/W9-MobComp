//
//  ContentView.swift
//  W9-MobComp
//
//  Created by MacBook Pro on 10/11/23.
//

import SwiftUI
import Foundation

struct MTGCardView: View {
    var card: [MTGCard]
    @State private var isShowingVersions = false
    @State private var isShowingRulings = false
    @State private var currentIndex: Int
    @State private var selectedButton: String?
    
    init(card: [MTGCard], currentIndex: Int) {
        self.card = card
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Display card image
                AsyncImage(url: URL(string: card[currentIndex].image_uris?.large ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                            .cornerRadius(15)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        ProgressView()
                    }
                }
                .frame(maxHeight: 200)
                HStack {
                    Button(action: {
                        navigateToPreviousCard()
                    }) {
                        Image(systemName: "arrow.left.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text(card[currentIndex].name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToNextCard()
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 16)
                
                Text(card[currentIndex].type_line)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .font(.system(size: 20))
                
                // Display Oracle Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(card[currentIndex].oracle_text)")
                        .font(.body)
                }
                .gesture(
                                DragGesture()
                                    .onEnded { gesture in
                                        let swipeThreshold: CGFloat = 50
                                        if gesture.translation.width > swipeThreshold {
                                            navigateToPreviousCard()
                                        } else if gesture.translation.width < -swipeThreshold {
                                            navigateToNextCard()
                                        }
                                    }
                            )
                .padding()
                
                Spacer()
                
            }
            
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal, 16)

            HStack(spacing: 16) {
                Button(action: {
                    isShowingVersions.toggle()
                    isShowingRulings = false
                }) {
                    ZStack {

                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .frame(height: 40)
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(isShowingVersions ? Color.red : Color.clear)
                    }
                    .frame(height: 40)
                    .overlay(
                        Text("Versions")
                            .foregroundColor(isShowingVersions ? Color.white : Color.gray)
                    )
                }
                
                Button(action: {
                    isShowingRulings.toggle()
                    isShowingVersions = false
                }) {
                    ZStack {
                    
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .frame(height: 40)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(isShowingRulings ? Color.red : Color.clear)
                    }
                    .frame(height: 20)
                    .overlay(
                        Text("Ruling")
                            .foregroundColor(isShowingRulings ? Color.white : Color.gray)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            if isShowingVersions {
                VStack {
                    Text("PRICES")
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)

                    ForEach(Array(Mirror(reflecting: card[currentIndex].prices ?? [:]).children), id: \.label) { child in
                        if let label = child.label, let value = child.value as? String {
                            let formattedKey = label.replacingOccurrences(of: "_", with: " ").capitalized
                            PriceItem(value: value, key: formattedKey)
                        }
                    }
                    .padding()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                )
            }

            if isShowingRulings {
                VStack() {
                    HStack {
                        Spacer()
                        Text("LEGALITIES")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    
                    if let legalities = card[currentIndex].legalities {
                        let legalitiesArray = Array(Mirror(reflecting: legalities).children)
                        let midpoint = legalitiesArray.count / 2
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                ForEach(0..<midpoint, id: \.self) { index in
                                
                                    HStack {
                                        Button(action: {
                                      
                                        }) {
                                            Text(legalitiesArray[index].value as? String == "legal" ? "Legal" : "Not Legal")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .frame(width: 100)
                                                .background((legalitiesArray[index].value as? String == "legal") ? Color.green : Color.gray)
                                                .cornerRadius(8)
                                        }
                                        Spacer()
                                        Text("\(legalitiesArray[index].label?.capitalized ?? "")")
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            

                            VStack(spacing: 4) {
                                ForEach(midpoint..<legalitiesArray.count, id: \.self) { index in
                                    
                                    HStack {
                                        Button(action: {
                                      
                                        }) {
                                            Text(legalitiesArray[index].value as? String == "legal" ? "Legal" : "Not Legal")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .frame(width: 100)
                                                .background((legalitiesArray[index].value as? String == "legal") ? Color.green : Color.gray)
                                                .cornerRadius(8)
                                        }
                                        Spacer()
                                        Text("\(legalitiesArray[index].label?.capitalized ?? "")")
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 8)
            }
            
        }
        
    }
    private func navigateToPreviousCard() {
           if currentIndex > 0 {
               currentIndex -= 1
           }
           selectedButton = nil
       }

       private func navigateToNextCard() {
           if currentIndex < card.count - 1 {
               currentIndex += 1
           }
           selectedButton = nil
       }
    struct PriceItem: View {
        var value: String
        var key: String
        
        var body: some View {
            HStack {
                Text("\(key):")
                    .fontWeight(.bold)
                
                Text(value)
            }
        }
    }
}

extension MTGCardView: Identifiable {
    var id: UUID { card[currentIndex].id }
}


struct ContentView: View {
    @State private var mtgCards: [MTGCard] = []
    @State private var searchText: String = ""
    @State private var isAscendingOrder: Bool = true

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var filteredCards: [MTGCard] {
        if searchText.isEmpty {
            return mtgCards
        } else {
            return mtgCards.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    struct SearchBar: View {
        @Binding var text: String
        @Binding var isAscendingOrder: Bool
        var sortAction: () -> Void

        var body: some View {
            HStack {
                TextField("Search", text: $text)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 8)

                Button(action: {
                    sortAction()
                }) {
                  
                    Image(systemName: isAscendingOrder ? "arrow.up" : "arrow.down")
                        .imageScale(.large)
                   
                }
                .padding(.leading, 8)
            }
            .padding(.top, 8)
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    // Search Bar with Sort Button
                    SearchBar(text: $searchText, isAscendingOrder: $isAscendingOrder, sortAction: {
                        isAscendingOrder.toggle()

                        mtgCards.sort { (card1, card2) in
                            if isAscendingOrder {
                                return card1.name.lowercased() < card2.name.lowercased()
                            } else {
                                return card1.name.lowercased() > card2.name.lowercased()
                            }
                        }
                    })
                    

                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(filteredCards.indices, id: \.self) { card in
                            NavigationLink(destination: MTGCardView(card: filteredCards, currentIndex: card)) {
                                CardImageView(card: filteredCards[card])
                                    .frame(height: 200)
                            }
                        }
                    }
                    .padding()
                }                .onAppear {
                    
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
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10)) 
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

