//
//  PostPracticeScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 29/12/2022.
//

import SwiftUI
import CoreData
import Foundation
import Combine

//Access gamification objects in this view to display the view and change the streak
//Also will display points gained
@available(iOS 16.0, *)
struct PostPracticeScreen: View {
    @State var timeComplete: Int
    @State var completedTargets: [String]
    
    //Fetches all relevant information from CoreData
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date),
    ]) var sessions: FetchedResults<CorePractice>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.categoryName)
    ]) var categories: FetchedResults<CoreCategory>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var saveButtonClicked = false
    @State var alreadyClicked = false
    
    @State var category = ""
    @State var selectedDifficulty = 1
    @State var updated = false
    
    //Dictionary [points: level]
    let levels = [0: 1, 10: 2, 50: 3, 125: 4, 250: 5, 500: 6, 1000: 7]
    
    var body: some View {
        VStack {
            Group {
                Text("Targets completed during this session:")
                    .fontWeight(.bold)
                    .foregroundColor(Color.customColour)
                    .padding()
                
                ForEach(completedTargets, id: \.self) {target in
                    Text("\(target)")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                }
            }
            
            Group {
                Text("Points gained: \(String(Int(floor(Double(timeComplete / 60)))))")
                    .fontWeight(.bold)
                    .foregroundColor(Color.customColour)
                    .padding()
                
                if updated == false {
                    Text("Streak has not been increased")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                } else {
                    Text("Streak has been increased")
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                }
                
                ForEach(instruments) { instrument in
                    if instrument.isSelected == true {
                        if instrument.streak == 1 {
                            Text("Streak: \(instrument.streak) consecutive day")
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                                .padding()
                        } else {
                            Text("Streak: \(instrument.streak) consecutive days")
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                                .padding()
                        }
                    }
                }
            }
            
            
            Text("Level: \(determineLevel())")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
                .padding()
            
            Text("Category completed: \(category)")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            
            Text("Time elapsed: \(timeString(time: timeComplete))")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            
            //Lets the user input how hard they thought the session was
            Picker("From 1-3, how hard did you find this category?", selection: $selectedDifficulty) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button {
                if saveButtonClicked == false {
                    saveCategory(inputDifficulty: selectedDifficulty)
                    saveButtonClicked = true
                } else {
                    alreadyClicked = true
                }
            } label: {
                Text("Save difficulty")
                    .fontWeight(.bold)
                    .foregroundColor(Color.customColour)
            }
            .alert(isPresented: $alreadyClicked) {
                //Prevents user from saving the difficulty after they have done it once
                Alert(title: Text("Error"), message: Text("Difficulty already saved"), dismissButton: .default(Text("Ok")))
            }
            
            NavigationLink(destination: HomeView()) {
                Text("Done")
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50))
                    .background(Color.customColour)
                    .clipShape(Capsule())
                    .fontWeight(.bold)
            }
        }
        .onAppear() {
            category = grabCategory()
            self.setActualTime(time: timeComplete)
            updated = updateStreak()
            self.updatePoints(time: timeComplete)
            self.updateLevel(points: Int(determinePoints())!)
            self.updateLongestSession()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Post Practice Screen")
    }
    
    //Updates the user's level depending on how many points they have
    func updateLevel(points: Int) {
        let sortedLevels = levels.sorted(by: <)
        
        var totalPoints = 0
        for instrument in instruments {
            if instrument.name == selectProfile() {
                totalPoints = points + Int(instrument.points)
            }
        }
        
        //Iterates through the sorted dictionary and
        //saves the user's level when the number of points reaches the correct threshold
        for (key, value) in sortedLevels {
            if key <= totalPoints {
                for instrument in instruments {
                    if instrument.isSelected == true {
                        instrument.level = Int64(value)
                    }
                }
            } else {
                break
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Adds number of points the user earns to their total in CoreData
    func updatePoints(time: Int) {
        let timeInMinutes = time / 60
        for instrument in instruments {
            if instrument.name == selectProfile() {
                instrument.points += floor(Double(timeInMinutes))
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //If the session the user just completed was longer than their record, the record is broken and saved
    func updateLongestSession() {
        for instrument in instruments {
            if instrument.isSelected == true {
                if timeComplete > instrument.longestSession {
                    instrument.longestSession = Int64(timeComplete)
                }
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Returns the level the user is on
    func determineLevel() -> String {
        for instrument in instruments {
            if instrument.isSelected == true {
                return String(Int(instrument.level))
            }
        }
        return ""
    }
    
    //Returns the user's total point count
    func determinePoints() -> String {
        for instrument in instruments {
            if instrument.isSelected == true {
                return String(Int(instrument.points))
            }
        }
        return ""
    }
    
    func updateStreak() -> Bool {
        var alreadyUpdated = false
        //Checks if the user has already practised today
        var count = 0
        for session in sessions {
            //          print(session.date!)
            //          print(alreadyUpdated)
            if session.date! != grabDate() {
                continue
            }
            if session.date! == grabDate() && count != 0 {
                //print("running")
                alreadyUpdated = true
                break
            }
            count = count + 1
        }
        
        //Streak can only be incremented if they have practised for at least 10 minutes
        var practisedYesterday = false
        var incremented = false
        //Testing
        //print("1")
        //print("\(timeComplete): time")
        if timeComplete > 2 {
            //Testing
            //print("2")
            //Streak only updated if user has not already practised today
            if alreadyUpdated == false {
                for session in sessions {
                    if incremented == true {
                        break
                    }
                    //print("3")
                    //Checks if user practised the previous day, if not streak is reset
                    //Testing:
                    //print(convertStringToDate(dateAsString: session.date!))
                    //print(Date.oneDayAgo)
                    if Date.oneDayAgo == convertStringToDate(dateAsString: session.date!) {
                        //Testing:
                        //print("4")
                        practisedYesterday = true
                        for instrument in instruments {
                            if instrument.name == selectProfile() {
                                //Testing:
                                //print("5")
                                instrument.streak += 1
                                incremented = true
                            }
                        }
                    }
                }
            }
        }
        
        for instrument in instruments {
            if instrument.name == selectProfile() && practisedYesterday == false && alreadyUpdated == false {
                instrument.streak = 0
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        if incremented == true {
            return true
        } else {
            return false
        }
    }
    
    
    //Date is stored as a String in core data, so must be converted to a Date to be correctly manipulated
    func convertStringToDate(dateAsString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let date = dateFormatter.date(from:dateAsString)!
        return date
    }
    
    //Converts time from an integer to a string in the correct format
    func timeString(time: Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //Returns the current date as a string
    func grabDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: currentDate)
        return result
    }
    
    //Returns the current time as a string
    func grabTime() -> String {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let time = dateFormatter.string(from: currentTime)
        return time
    }
    
    //Returns the category for the session just completed
    func grabCategory() -> String {
        var returnValue = ""
        for session in sessions {
            if session.timeStarted == findRecentSession() {
                returnValue = session.category!
                break
            }
        }
        return returnValue
    }
    
    //Saves the difficulty of the category into CoreData
    func saveCategory(inputDifficulty: Int) {
        let newCategory = CoreCategory(context: viewContext)
        
        newCategory.categoryName = category
        newCategory.date = grabDate()
        newCategory.difficulty = Int64(inputDifficulty)
        newCategory.profile = selectProfile()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Selects the profile currently in use
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name ?? ""
            }
        }
        return "ERROR"
    }
    
    //Sets the actualTime into CoreData
    func setActualTime(time: Int) {
        for session in sessions {
            if grabDate() == session.date && session.timeStarted! == findRecentSession() {
                session.timeCompleted = Int64(time)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Finds the most recent session in CoreData by calculating the time between each session and the current time
    func findRecentSession() -> String {
        var difference = 0.0
        var min = 10000000.0
        var recentSessionString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let endTime = dateFormatter.date(from: grabTime())
        //Iterates through sessions in CoreData
        for session in sessions {
            if session.date == grabDate() {
                let string = session.timeStarted!
                let startTime = dateFormatter.date(from: string)
                //Calculates the difference in time between the
                //current time and the time that the user started
                difference = endTime!.timeIntervalSince(startTime!)
                
                //If the difference is less than the current minimum
                //the minimum is reassigned to this new difference
                if difference < min {
                    min = difference
                    recentSessionString = String(session.timeStarted!)
                }
            }
        }
        return recentSessionString
    }
}

@available(iOS 16.0, *)
struct PostPracticeScreen_Previews: PreviewProvider {
    static var previews: some View {
        PostPracticeScreen(timeComplete: 100, completedTargets: [])
    }
}
