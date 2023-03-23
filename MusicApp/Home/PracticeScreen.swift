//
//  PracticeScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 28/11/2022.
//

import SwiftUI
import Foundation
import CoreData
import Combine

@available(iOS 16.0, *)
struct PracticeScreen: View {
    @State var isShowingStatsScreen: Bool = false
    @Binding var timeRemaining: Int
    @State var timeComplete: Int = 0
    @State var showingAlert = false
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    @State var completedTargets: [String] = []
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.task)
    ]) var targets: FetchedResults<CoreTarget>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    var body: some View {
        
        VStack {
            //Displays a list of targets relevant to the instrument the user is playing
            NavigationLink(destination: PostPracticeScreen(timeComplete: timeComplete, completedTargets: completedTargets), isActive: $isShowingStatsScreen) { }
            
            Text("Targets: ")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            ForEach(targets) { target in
                //Checks profile corresponds to target profile
                if target.profile == selectProfile() {
                    HStack{
                        Image(systemName: target.isCompleted ? "checkmark.square" : "square")
                            .onTapGesture {
                                changeIsCompleted(target: target)
                            }
                            .foregroundColor(Color.customColour)
                        
                        Text(target.task ?? "error")
                            .strikethrough(target.isCompleted)
                            .fontWeight(.bold)
                            .foregroundColor(Color.customColour)
                        
                    }
                }
            }
            Spacer()
            MetronomeView()
            Text("\(timeString(time: timeRemaining))")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Color.customColour.opacity(0.75))
                .clipShape(Capsule())
                .fontWeight(.bold)
            
            //User can press a button to end the session early
            Button {
                showingAlert = true
                //Stops the time that the user has been practising
                timer.upstream.connect().cancel()
            } label: {
                Text("End")
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 75, leading: 75, bottom: 75, trailing: 75))
                    .background(Color.customColour)
                    .clipShape(Capsule())
                    .fontWeight(.bold)
            }
            //Displays an alert to confirm the user wants to end the session early
            .alert(isPresented:$showingAlert) {
                Alert(
                    title: Text("Are you sure you would like to end the session?"),
                    primaryButton: .destructive(Text("Yes")){
                        isShowingStatsScreen = true
                    },
                    secondaryButton: .cancel() {
                        //Resumes session if user does not want to end early
                        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Practice Screen")
        //Prevents timer from running when the app has closed
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
            
            if timeComplete >= 0 {
                timeComplete += 1
            }
            
            //If time is up, practice session ends and user is redirected
            if timeRemaining == 0 {
                isShowingStatsScreen = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                isActive = true
            } else {
                isActive = false
            }
        }
        
    }
    
    //Converts time from seconds into a string of hours, minutes and seconds
    func timeString(time: Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func grabDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: currentDate)
        return result
    }
    
    //Returns the correct profile that is selected in the side bar
    func selectProfile() -> String {
        for profile in instruments {
            if profile.isSelected == true {
                return profile.name ?? ""
            }
        }
        return "ERROR"
    }
    
    //Changes whether the target is completed or not in core data
    func changeIsCompleted(target: CoreTarget) {
        if target.isCompleted == false {
            target.isCompleted = true
            target.dateCompleted = grabDate()
            completedTargets.append(target.task!)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct MetronomeView: View {
    @StateObject var metro: Metronome = Metronome()
    
    var body: some View {
        //Diplays the relevant information relating to the metronome, including
        //the slider to control the speed and the 4 dots to represent the time
        VStack {
            Text("Metronome")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            Text("\(metro.beatsPerMinute) BPM")
                .fontWeight(.bold)
                .foregroundColor(Color.customColour)
            Slider(value: $metro.sliderPercent)
            BeatView(currentBeat: metro.crotchet.current, totalBeats: 4)
            Spacer()
        }
    }
}

struct BeatView: View {
    let currentBeat: Int
    let totalBeats: Int
    var body: some View {
        HStack {
            ForEach(0...(totalBeats - 1), id: \.self) { beat in
                Circle().foregroundColor(beat == self.currentBeat ? .blue : Color.customColour)
            }
        }
    }
}

@available(iOS 16.0, *)
struct PracticeScreen_Previews: PreviewProvider {
    static var previews: some View {
        PracticeScreen(timeRemaining: .constant(100), timeComplete: 10)
    }
}
