//
//  AchievementScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 10/09/2022.
//

import SwiftUI
import CoreData
import Foundation

@available(iOS 16.0, *)
struct AchievementScreen: View {

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    @Environment(\.managedObjectContext) private var viewContext
    
    let levels = [0: 1, 10: 2, 50: 3, 125: 4, 250: 5, 500: 6, 1000: 7]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(String(repeating: "⭐️", count: determineLevel()))
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                        .padding()
                    
                    Text("Level: \(determineLevel()) 🏆")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                        .padding()
                    
                    Text("Streak: \(determineStreakStatus()) 🔥")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                        .padding()
                    
                    Text("Points: \(determinePoints()) / \(displayNextPoints(points: determinePoints())) 💎")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                        .padding()
                    
                    NavigationLink(destination: BadgeScreen(streak: determineStreakStatus(), level: determineLevel())) {
                        Text("Badges and Achievements")
                            .background(Color.customColour)
                            .clipShape(Capsule())
                            .foregroundColor(.black)
                            .padding(EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40))
                    }
                    
                }
            }.navigationTitle("Achievement Screen")
        }
    }
    
    //Displays the next threshold the user has to meet in order to level up
    func displayNextPoints(points: Int) -> Int {
        //Sorts the dictionary by ascending keys
        let sortedLevels = levels.sorted(by: <)
        
        var totalPoints = 0
        for instrument in instruments {
            if instrument.isSelected == true {
                totalPoints = points + Int(instrument.points)
            }
        }
        
        for (key, _) in sortedLevels {
            if key > totalPoints {
                return key
            }
        }
        
        return 0
    }
    
    
    //Returns the level the user is on
    func determineLevel() -> Int {
        for instrument in instruments {
            if instrument.isSelected == true {
                return Int(instrument.level)
            }
        }
        return 0
    }
    
    //Returns the user's streak
    func determineStreakStatus() -> Int {
        for instrument in instruments {
            if instrument.isSelected == true {
                return Int(instrument.streak)
            }
        }
        return 0
    }
    
    //Returns the user's total point count
    func determinePoints() -> Int {
        for instrument in instruments {
            if instrument.isSelected == true {
                return Int(instrument.points)
            }
        }
        return 0
    }
}

@available(iOS 16.0, *)
struct AchievementScreen_Previews: PreviewProvider {
    static var previews: some View {
        AchievementScreen()
    }
}
