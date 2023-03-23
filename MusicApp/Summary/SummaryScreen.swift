//
//  SummaryScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 10/09/2022.
//

import SwiftUI
import Foundation
import CoreData

@available(iOS 16.0, *)
struct SummaryScreen: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date),
    ]) var sessions: FetchedResults<CorePractice>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.task),
    ]) var targets: FetchedResults<CoreTarget>
    
    public let range = Date.oneWeekAgo...Date()
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack {
                    Text("Instrument: " + selectProfile())
                        .font(.system(size: 30))
                        .foregroundColor(Color.customColour)
                        .padding()
                        .bold()
                        .underline()
                    
                    Text("Total number of practise sessions: " + numberOfSessions())
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                    
                    Spacer()
                    
                    CategoryView()
                    
                    ForEach(sessions, id: \.self) { session in
                        if session.profile == selectProfile() && range.contains(convertStringToDate(dateAsString: session.date!)) {
                            Text(session.date! + " - " + session.category!)
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                                .padding()
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                )
                            Spacer()
                        }
                    }
                    
                    Text("Time practised: " + timeString(time: durationCalculator()))
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                        .padding()
                    
                    Spacer()
                    
                    Text("Targets completed: ")
                        .font(.system(size: 20))
                        .foregroundColor(Color.customColour)
                        .underline()
                    
                    ForEach(targets, id: \.self) { target in
                        if let dateCompleted = target.dateCompleted {
                            if target.profile == selectProfile() && range.contains(convertStringToDate(dateAsString: dateCompleted)) && target.isCompleted == true {
                                Spacer()
                                Text(target.task ?? "")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.customColour)
                            }
                        }
                        
                    }
                }
            }.navigationTitle("Summary Screen")
        }
    }

    //Selects current profile that is in use
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name!
            }
        }
        return "ERROR"
    }
    
    //Date is stored as a String in core data, so must be converted to a Date to be correctly manipulated
    func convertStringToDate(dateAsString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let date = dateFormatter.date(from:dateAsString)
        return date!
    }
    
    //Calculates how long the user practised for in the past week
    func durationCalculator() -> Int {
        var duration = 0
        for session in sessions {
            if session.profile == selectProfile() && range.contains(convertStringToDate(dateAsString: session.date!)) {
                duration += Int(session.timeCompleted)
            }
        }
        return duration
    }
    
    //Calculates how many practice sessions were completed for each profile in the last week
    func numberOfSessions() -> String {
        var count = 0
        for session in sessions {
            if session.profile == selectProfile() && range.contains(convertStringToDate(dateAsString: session.date!)) {
                count += 1
            }
        }
        return String(count)
    }
    
    func timeString(time: Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

@available(iOS 16.0, *)
struct CategoryView: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date)
    ]) var categories: FetchedResults<CoreCategory>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    public let range = Date.oneWeekAgo...Date()
    
    var body: some View {
        Text("Most difficult category: " + calculateMostDifficultCategory())
            .frame(maxWidth: .infinity, alignment: .center)
            .fontWeight(.bold)
            .foregroundColor(Color.customColour)
        
        Spacer()
        Text("Categories Practised: ")
            .font(.system(size: 20))
            .foregroundColor(Color.customColour)
            .underline()
    }
    
    func calculateMostDifficultCategory() -> String {
        var mostDifficultCategory = ""
        var difficultyValue = 1
        for category in categories {
            if category.profile == selectProfile() && range.contains(convertStringToDate(dateAsString: category.date!)) {
                //If there are multiple categories with the same difficulty
                //categories are appended to a single string
                if category.difficulty == difficultyValue {
                    mostDifficultCategory += ", \(category.categoryName!)"
                } else if category.difficulty > difficultyValue {
                    difficultyValue = Int(category.difficulty)
                    if let name = category.categoryName {
                        mostDifficultCategory = name
                    }
                }
            }
        }
        return mostDifficultCategory
    }
    
    //Date is stored as a String in core data, so must be converted to a Date to be correctly manipulated
    func convertStringToDate(dateAsString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let date = dateFormatter.date(from:dateAsString)
        return date!
    }
    
    //Selects current profile that is in use
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name!
            }
        }
        return "ERROR"
    }
}

@available(iOS 16.0, *)
struct SummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SummaryScreen()
    }
}
