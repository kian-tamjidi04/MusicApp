//
//  KeyListView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 09/09/2022.
//

import SwiftUI

struct KeyListView: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.keySignature),
    ]) var difficulties: FetchedResults<CoreDifficulty>
    @Environment(\.managedObjectContext) var viewContext
    
    var listedTopic: Topic
    
    var body: some View {
        //Displays a list of key signatures and links to a ContentDetailView about the specific key
        List(keys) { listedKey in
            NavigationLink(destination: ContentDetailView(key_signature_and_topic: listedKey, clickedTopic: listedTopic)) {
                Text(listedKey.key)
            }
        }.navigationTitle("\(listedTopic.name)" + " " + String(repeating: "✩", count: grabDifficulty(name: listedTopic.name)))
    }
    
    func grabDifficulty(name: String) -> Int {
        var output = 0.0
        for difficulty in difficulties {
            if difficulty.topicArea == name {
                output = output + Double(difficulty.difficultyValue)
            }
        }
        output = round(output/12)
        return Int(output)
    }
}

struct KeyListView_Previews: PreviewProvider {
    static var previews: some View {
        KeyListView(listedTopic: Topic(id: UUID(), name: "Major Scales"))
    }
}
