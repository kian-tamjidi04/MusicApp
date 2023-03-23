//
//  TopicList.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 08/09/2022.
//

import Foundation
import SwiftUI
import CoreData

//TASK: Manipulate coredata to get the averages of each difficulty

struct Topic: Identifiable {
    var id: UUID
    var name: String
}

var topics: [Topic] = [Topic(id: UUID(), name: "Major Scales"),
                       Topic(id: UUID(), name: "Natural Minor Scales"),
                       Topic(id: UUID(), name: "Major Arpeggios"),
                       Topic(id: UUID(), name: "Minor Arpeggios")]
