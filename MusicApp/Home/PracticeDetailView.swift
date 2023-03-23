//
//  PracticeDetailView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 06/03/2023.
//

import SwiftUI
import CoreData

struct PracticeDetailView: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date),
    ]) var sessions: FetchedResults<CorePractice>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name),
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.task)
    ]) var targets: FetchedResults<CoreTarget>
    
    @Environment(\.managedObjectContext) private var viewContext

    var selectedDate: String

    var body: some View {
        ScrollView {
            Text("\(selectedDate)")
                .underline()
                .fontWeight(.bold)
                .font(.largeTitle)
                .foregroundColor(Color.customColour)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                Text("Practice Sessions: ")
                    .underline()
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .foregroundColor(Color.customColour)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                //Outputs the practice sessions that have been practised on the day
                //the user selected on the calendar
                ForEach(sessions) { session in
                    if session.date! == selectedDate && session.profile == selectProfile() {
                        Text("Category: " + session.category!)
                            .fontWeight(.bold)
                            .foregroundColor(Color.customColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                        
                        Text("Duration: " + String(timeString(time: Int(session.timeCompleted))))
                            .fontWeight(.bold)
                            .foregroundColor(Color.customColour)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            Group {
                Text("Categories Practised: ")
                    .underline()
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .foregroundColor(Color.customColour)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(sessions, id: \.self) { session in
                    if session.profile == selectProfile() && session.date == selectedDate {
                        Text("• " + session.category!)
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .foregroundColor(Color.customColour)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            Spacer()
            
            Group {
                Text("Targets Completed: ")
                    .underline()
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .foregroundColor(Color.customColour)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                //Outputs targets completed on the day the user selected on the calendar
                ForEach(targets) { target in
                    if target.dateCompleted == selectedDate {
                        HStack{
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(Color.customColour)
                            Text(target.task!)
                                .fontWeight(.bold)
                                .foregroundColor(Color.customColour)
                                
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            Group {
                Text("Other Statistics: ")
                    .underline()
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .foregroundColor(Color.customColour)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Total sessions: \(numberOfSessions())")
                    .fontWeight(.bold)
                    .foregroundColor(Color.customColour)
                    .font(.system(size: 25))
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Time practised: " + timeString(time: durationCalculator()))
                    .fontWeight(.bold)
                    .foregroundColor(Color.customColour)
                    .padding(.leading)
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            
            }.navigationTitle("Statistics")
    }
    
    //Calculates total time the user has practised on that day
    func durationCalculator() -> Int {
        var duration = 0
        for session in sessions {
            if session.profile == selectProfile() && session.date == selectedDate {
                duration += Int(session.timeCompleted)
            }
        }
        return duration
    }
    
    //Calculates how many sessions were completed on that day
    func numberOfSessions() -> String {
        var count = 0
        for session in sessions {
            if session.profile == selectProfile() && session.date == selectedDate {
                count += 1
            }
        }
        return String(count)
    }
    
    //Puts the time the user practised for each session into the correct format
    func timeString(time: Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name ?? ""
            }
        }
        return "ERROR"
    }
}

struct PracticeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeDetailView(selectedDate: "")
    }
}
