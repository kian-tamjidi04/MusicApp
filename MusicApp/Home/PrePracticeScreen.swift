//
//  PrePracticeScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 14/10/2022.
//

import SwiftUI
import Foundation
import CoreData

@available(iOS 16.0, *)
struct PrePracticeScreen: View {
    @State var hourSelection: Int = 0
    @State var minuteSelection: Int = 0
    @State var isShowingPracticeScreen = false
    @State var totalDurationInMinutes = 0
    @State var totalDurationInSeconds = 0

    var hours = [Int](0..<24)
    var minutes = [Int](0..<60)
    
    var categoryChooserOptions = ["Major Scales", "Minor Scales", "Major Arpeggios", "Minor Arpeggios", "Pieces", "Ear Training"]
    
    @State var categorySelection = ""
        
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.duration),
    ]) var sessions: FetchedResults<CorePractice>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.categoryName)
    ]) var categories: FetchedResults<CoreCategory>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showingAlert = false
    
    var body: some View {
        VStack{
            NavigationLink(destination: PracticeScreen(timeRemaining: $totalDurationInSeconds), isActive: $isShowingPracticeScreen) { }
            
            Text("Instrument: " + selectProfile())
                .fontWeight(.bold)
                .font(.system(size: 26))
                .foregroundColor(Color.customColour)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Text("Streak: " + getStreak())
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            //Links to the practice screen, as well as converting the time to minutes to be stored in CoreData
            Button {
                //Checks for user input
                if categorySelection == "" || (hourSelection == 0 && minuteSelection == 0){
                    showingAlert = true
                } else {
                    convertTimeToMinutes(hours: hourSelection, minutes: minuteSelection)
                    savePracticeInputs()
                    isShowingPracticeScreen = true
                }
            } label: {
                Text("Start")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 75, leading: 75, bottom: 75, trailing: 75))
                    .background(Color.customColour)
                    .clipShape(Capsule())
            }
            //Appears if the user has not chosen either a time or category (both are mandatory)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text("You must choose a category and a time for your practice"), dismissButton: .default(Text("Ok")))
            }
            
            //Displays an input box and the category the user has selected
            Text("Category: \(categorySelection)")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Picker("Select category", selection: $categorySelection) {
                ForEach(categoryChooserOptions, id: \.self) {
                    Text(String($0))
                        .fontWeight(.bold)
                        .foregroundColor(Color.customColour)
                }
            }
            .pickerStyle(.menu)
            
            Spacer()
            
            Text("Duration: \(hourSelection) hours \(minuteSelection) minutes")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            
            Spacer()
            
            //TESTING PURPOSES: MAKES SURE DATA IS SAVED IN CORE DATA
            //SESSIONS
//            List(){
//                ForEach(sessions) { session in
//                    Text(String(session.duration))
//                    Text(session.category ?? "")
//                    Text(session.profile ?? "")
//                    Text(session.date ?? "")
//                    Text(session.timeStarted ?? "")
//                }.onDelete(perform: deleteItems)
//            }
            //STREAK
//            List() {
//                ForEach(instruments) { instrument in
//                    Text(String(instrument.streak))
//                }
//            }
            //CATEGORIES
//            List(){
//                ForEach(categories) { category in
//                    Text(String(category.difficulty))
//                    Text(category.categoryName!)
//                    Text(category.profile ?? "")
//                    Text(category.date ?? "")
//                }.onDelete(perform: deleteItems2)
//            }
            
            //Wheelpicker for the user to choose how long they want to practise for
            GeometryReader { geometry in
                HStack {
                    Picker(selection: self.$hourSelection, label: Text("")) {
                        ForEach(0 ..< self.hours.count, id: \.self) { index in
                            Text("\(self.hours[index]) h").tag(index)
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geometry.size.width/2, height: 100, alignment: .center)
                    .compositingGroup()
                    .clipped()
                    
                    Picker(selection: self.$minuteSelection, label: Text("")) {
                        ForEach(0 ..< self.minutes.count, id: \.self) { index in
                            Text("\(self.minutes[index]) min").tag(index)
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geometry.size.width/2, height: 100, alignment: .center)
                    .compositingGroup()
                    .clipped()
                }
            }
            
        }.navigationBarTitle("Pre Practice Screen")
    }
    
    //Returns the streak of the instrument that is currently selected
    func getStreak() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return String(profile.streak)
            }
        }
        return "ERROR"
    }
    
    
    //Iterates through saved instruments
    //and outputs profile string if instrument is selected in the side menu
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name ?? ""
            }
        }
        return "ERROR"
    }
    
    //Saves the user input (details for the practice session) to CoreData
    func savePracticeInputs() {
        let newCorePractice = CorePractice(context: viewContext)
        newCorePractice.duration = Int64(totalDurationInMinutes)
        newCorePractice.category = categorySelection
        newCorePractice.profile = selectProfile()
        newCorePractice.date = grabDate()
        newCorePractice.timeStarted = grabTime()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func grabDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: currentDate)
        return result
    }
    
    func grabTime() -> String {
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let result = formatter.string(from: currentTime)
        return result
    }
    
    func convertTimeToMinutes(hours: Int, minutes: Int) {
        totalDurationInMinutes = (hours*60) + minutes
        totalDurationInSeconds = totalDurationInMinutes * 60
    }
    
    //TESTING PURPOSES ONLY, DELETES FROM A LIST
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { sessions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems2(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

@available(iOS 16.0, *)
struct PrePracticeScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrePracticeScreen()
    }
}
