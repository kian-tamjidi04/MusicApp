//
//  MainTheoryScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 08/09/2022.
//

import SwiftUI

@available(iOS 16.0, *)
struct MainTheoryScreen: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.keySignature),
    ]) var coreDataDifficulties: FetchedResults<CoreDifficulty>
    @Environment(\.managedObjectContext) var viewContext
    
    @State var sortedList: [Topic]
    @State var toggleIsOn: Bool
    @State var selection = "All"
    let difficulties = ["All", "Easy", "Medium", "Hard"]
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle()
                    .frame(height: 0)
                    .background(.ultraThinMaterial)
                HStack {
                    //User can select difficulty from a drop down menu
                    Picker("Select difficulty", selection: $selection) {
                        ForEach(difficulties, id: \.self) {
                            Text(String($0))
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selection) { value in
                        filterList(selection: selection)
                    }
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Text(toggleIsOn ? "Hardest at the top": "Easiest at the top")
                        .underline()
                        .bold()
                        .padding()
                    
                    Toggle(isOn: $toggleIsOn) {
                        Text("Change Order: ")
                            .bold()
                            .onChange(of: toggleIsOn) { value in
                                toggleFilter(change: toggleIsOn)
                            }
                    }.padding()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                //Displays a list of the topics alongside stars to indicate difficulty and a colour as a visual aide
                List(sortedList) { topic in
                    NavigationLink(destination: KeyListView(listedTopic: topic)) {
                        Text("\(topic.name) - " + String(repeating: "✩", count: grabDifficulty(name: topic.name)))
                            .foregroundColor(changeColour(difficulty: grabDifficulty(name: topic.name)))
                            .bold()
                        
                    }
                }.scrollContentBackground(.hidden)
            }
            //Displays the title and uses the system colour for the background
            .navigationTitle("Theory Topics")
            .background(Color.customColour)
        }
        
    }
    
    //Calculates the average difficulty for each topic area based on all the user inputs
    func grabDifficulty(name: String) -> Int {
        var output = 0.0
        for difficulty in coreDataDifficulties {
            if difficulty.topicArea == name {
                output = output + Double(difficulty.difficultyValue)
            }
        }
        output = round(output/12)
        return Int(output)
    }
    
    //Changes the colour to give a visual representation of the difficulty
    func changeColour(difficulty: Int) -> Color {
        if difficulty == 1 {
            return .green
        } else if difficulty == 2 {
            return .orange
        } else {
            return .red
        }
    }
    
    //Filters the topics based on their difficulty
    public func filterList(selection: String){
        if selection == "Easy" {
            sortedList = topics.filter({ (topic) -> Bool in
                return grabDifficulty(name: topic.name) == 1
            })
        } else if selection == "Medium" {
            sortedList = topics.filter({ (topic) -> Bool in
                return grabDifficulty(name: topic.name) == 2
            })
        } else if selection == "Hard" {
            sortedList = topics.filter({ (topic) -> Bool in
                return grabDifficulty(name: topic.name) == 3
            })
        } else {
            sortedList = topics
        }
    }

    //Creates a toggle so user can swap between ascending and descending
    public func toggleFilter(change: Bool){
        if change {
            sortedList = topics.sorted{ lhs, rhs in
                grabDifficulty(name: lhs.name) > grabDifficulty(name: rhs.name)
            }
        } else {
            sortedList = topics.sorted{ lhs, rhs in
                grabDifficulty(name: lhs.name) < grabDifficulty(name: rhs.name)
            }
        }
    }
}

@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTheoryScreen(sortedList: topics, toggleIsOn: false)
    }
}
