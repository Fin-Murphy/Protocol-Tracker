//
//  ProtocolListView.swift
//  ScatterBrainVVD
//
//  Created by Finnian Murphy on 7/22/25.
//

import SwiftUI
import SwiftData

struct ProtocolListView: View {

    @Query(sort: \habItem.name, animation: .default)
    private var habitData: [habItem]
    
    @State var listOfProtocols: [HabitProtocol] = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
    @State var displayProtocolLibrary: Bool = false
    
    private func habits(in prot: HabitProtocol) -> [habItem] {
        habitData.filter { $0.whichProtocol == prot.ProtocolName }
    }

    private func protocolPage(_ prot: HabitProtocol) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(prot.ProtocolName)
                    .font(Theme.detailTitle)
                    .foregroundStyle(Theme.text1)
                    .accessibilityAddTraits(.isHeader)

                if habits(in: prot).isEmpty == false {
                    RowCard {
                        ForEach(habits(in: prot)){ hab in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(habitColor(hab.colorName))
                                    .frame(width: 10, height: 10)
                                    .accessibilityHidden(true)
                                Text(hab.name)
                                    .font(Theme.body)
                                    .foregroundStyle(Theme.text1)
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationBarTitleDisplayMode(.inline)
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                ScreenHeader(title: "Protocols") {
                    IconButton(systemName: "books.vertical", label: "Browse library") {
                        displayProtocolLibrary = true
                    }
                }

                if listOfProtocols.isEmpty {

                    EmptyState(symbol: "list.bullet.rectangle",
                               title: "No protocols",
                               sentence: "A protocol is a named group of habits.",
                               buttonTitle: "Browse library") {
                        displayProtocolLibrary = true
                    }

                } else {

                    List {

                        ForEach(listOfProtocols) { prot in

                            NavigationLink{

                                protocolPage(prot)

                            } label: {
                                HStack {
                                    Text(prot.ProtocolName)
                                        .font(Theme.body)
                                        .foregroundStyle(Theme.text1)
                                    Spacer(minLength: 0)
                                    Text("\(habits(in: prot).count)")
                                        .font(Theme.value)
                                        .foregroundStyle(Theme.text2)
                                        .accessibilityLabel("\(habits(in: prot).count) habits")
                                }
                                .frame(minHeight: 44)
                            } // End navlinklabel
                            .listRowBackground(Theme.surface)
                            .listRowSeparatorTint(Theme.separator)

                        } // End foreach

                    } // End list
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.bg)
            .toolbar(.hidden, for: .navigationBar)

        }// End navstack
        .sheet(isPresented: $displayProtocolLibrary) {
            ProtocolLibraryModal(isPresented: $displayProtocolLibrary, onIncorporate: {
                listOfProtocols = UserDefaults.standard.getDecodable([HabitProtocol].self, forKey: "protocol") ?? []
            })
        }

    } // end body
}

#Preview {
    ProtocolListView()
}
