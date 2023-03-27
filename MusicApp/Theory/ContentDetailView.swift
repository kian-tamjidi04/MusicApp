//
//  ContentDetailView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 08/09/2022.
//

import SwiftUI
import Foundation
import CoreData

struct ContentDetailView: View {
    @State var key_signature_and_topic: Key
    @State var clickedTopic: Topic
    @State var selection = 1
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.keySignature),
    ]) var difficulties: FetchedResults<CoreDifficulty>
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        VStack {
            //Displays a different title depending on the category
            if clickedTopic.name == "Major Scales" {
                VisualContent(title: "\(key_signature_and_topic.key) major scale", image: key_signature_and_topic.major_scale)
            } else if clickedTopic.name == "Natural Minor Scales" {
                VisualContent(title: "\(key_signature_and_topic.key) natural minor scale", image: key_signature_and_topic.minor_scale)
            } else if clickedTopic.name == "Major Arpeggios" {
                VisualContent(title: "\(key_signature_and_topic.key) major arpeggio", image: key_signature_and_topic.major_arp)
            } else if clickedTopic.name == "Minor Arpeggios" {
                VisualContent(title: "\(key_signature_and_topic.key) minor arpeggio", image: key_signature_and_topic.minor_arp)
            }
            
            //Lets user input difficulty from a picker
            Text("Enter difficulty: \(selection)")

            Picker("Select difficulty, where 1 = easy", selection: $selection) {
                Text("\(1)").tag(1)
                Text("\(2)").tag(2)
                Text("\(3)").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            //Button to update the difficulty of the topic
            Button("Update") {
                updateDifficulty()
            }
            Spacer()
            Spacer()
        }
        .onAppear() {
            //Sets this value of selection to be whatever was last stored in core data
            selection = displayDifficulty()
        }
    }
    
    //Iterates through difficulties stores in core data
    //returning the difficulty relating to the relevant topic area and key signature
    func displayDifficulty() -> Int {
        for difficulty in difficulties {
            if difficulty.keySignature == key_signature_and_topic.key && difficulty.topicArea == clickedTopic.name {
                return Int(difficulty.difficultyValue)
            }
        }
        return 1
    }
    
    //Updates the difficulty in core data
    //unless there is no instance of the difficulty saved
    //in which case a new difficulty entity is created
    func updateDifficulty() {
        var found = false
        
        for difficulty in difficulties {
            if difficulty.keySignature == key_signature_and_topic.key && difficulty.topicArea == clickedTopic.name {
                difficulty.difficultyValue = Int64(selection)
                found = true
                break
            }
        }
        
        if found == false {
            let newCoreDifficulty = CoreDifficulty(context: viewContext)
            newCoreDifficulty.difficultyValue = Int64(selection)
            newCoreDifficulty.keySignature = key_signature_and_topic.key
            newCoreDifficulty.topicArea = clickedTopic.name
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct VisualContent: View {
    var title: String
    var image: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.largeTitle)
                .underline()
            Spacer()
            
            Image(image)
                .resizable()
                .scaledToFit()
            
            Spacer()
        }
    }
}

struct TopicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(key_signature_and_topic: Key(id: UUID(), key: "C", minor_scale: "CMinSc", major_scale: "CMajSc", minor_arp: "CMinArp", major_arp: "CMajArp"), clickedTopic: Topic(id: UUID(), name: "Major Scales"))
    }
}
