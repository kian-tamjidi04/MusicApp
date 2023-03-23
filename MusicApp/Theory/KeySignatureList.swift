//
//  KeySignatureList.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 09/09/2022.
//

import Foundation
import SwiftUI

struct Key: Identifiable {
    var id: UUID
    var key: String
    var minor_scale: String
    var major_scale: String
    var minor_arp: String
    var major_arp: String
}

var keys: [Key] = [Key(id: UUID(), key: "C", minor_scale: "CMinSc", major_scale: "CMajSc", minor_arp: "CMinArp", major_arp: "CMajArp"),
                   Key(id: UUID(), key: "C#", minor_scale: "C#MinSc", major_scale: "C#MajSc", minor_arp: "C#MinArp", major_arp: "C#MajArp"),
                   Key(id: UUID(), key: "D", minor_scale: "DMinSc", major_scale: "DMajSc", minor_arp: "DMinArp", major_arp: "DMajArp"),
                   Key(id: UUID(), key: "Eb", minor_scale: "EbMinSc", major_scale: "EbMajSc", minor_arp: "EbMinArp", major_arp: "EbMajArp"),
                   Key(id: UUID(), key: "E", minor_scale: "EMinSc", major_scale: "EMajSc", minor_arp: "EMinArp", major_arp: "EMajArp"),
                   Key(id: UUID(), key: "F", minor_scale: "FMinSc", major_scale: "FMajSc", minor_arp: "FMinArp", major_arp: "FMajArp"),
                   Key(id: UUID(), key: "F#", minor_scale: "F#MinSc", major_scale: "F#MajSc", minor_arp: "F#MinArp", major_arp: "F#MajArp"),
                   Key(id: UUID(), key: "G", minor_scale: "GMinSc", major_scale: "GMajSc", minor_arp: "GMinArp", major_arp: "GMajArp"),
                   Key(id: UUID(), key: "Ab", minor_scale: "AbMinSc", major_scale: "AbMajSc", minor_arp: "AbMinArp", major_arp: "AbMajArp"),
                   Key(id: UUID(), key: "A", minor_scale: "AMinSc", major_scale: "AMajSc", minor_arp: "AMinArp", major_arp: "AMajArp"),
                   Key(id: UUID(), key: "Bb", minor_scale: "BbMinSc", major_scale: "BbMajSc", minor_arp: "BbMinArp", major_arp: "BbMajArp"),
                   Key(id: UUID(), key: "B", minor_scale: "BMinSc", major_scale: "BMajSc", minor_arp: "BMinArp", major_arp: "BMajArp")]
