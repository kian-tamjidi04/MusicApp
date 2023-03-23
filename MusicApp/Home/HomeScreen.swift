//
//  HomeScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 10/09/2022.
//

import SwiftUI
import CoreData

@available(iOS 16.0, *)
struct HomeScreen: View {
    //Keeps track of whether side menu is visible or not
    @State private var isShowing = false
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name),
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            ZStack {
                //Displays the sideMenu if the button is pressed
                if isShowing {
                    SideMenuView(isShowing: $isShowing, currentInstrument: selectProfile())
                }
                
                //Main home screen with some editing to blend with the side menu
                HomeView()
                    .cornerRadius(isShowing ? 20 : 10)
                    .offset(x: isShowing ? 300 : 0, y: isShowing ? 44: 0)
                    .scaleEffect(isShowing ? 0.8 : 1)
                    .navigationBarItems(leading: Button(action: {
                        withAnimation(.spring()) {
                            isShowing.toggle()
                        }
                    }, label: { Image(systemName: "music.note.list")
                            .foregroundColor(Color.customColour)
                    }))
                    .navigationTitle("Home Screen")
            }
        }
        .navigationBarBackButtonHidden(true)
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
}

@available(iOS 16.0, *)
struct HomeView: View {
    @State private var isShowingPrePracticeScreen = false
    
    let levels = [0: 1, 10: 2, 50: 3, 125: 4, 250: 5, 500: 6, 1000: 7]
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name),
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var date = Date.now
    
    var body: some View {
        NavigationStack {
            ScrollView{
                ZStack {
                    Color(.white)
                    //Creates a button that takes the user to the pre practice screen
                    NavigationLink(destination: PrePracticeScreen(), isActive: $isShowingPrePracticeScreen) { }
                    
                    VStack{
                        HStack {
                            //Shows gamification information
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
                        }
                        
                        Button {
                            isShowingPrePracticeScreen = true
                        } label: {
                            Text("Start Practice Session")
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 75, leading: 75, bottom: 75, trailing: 75))
                                .background(Color.customColour)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        //Displays the calendar
                        Text("Calendar")
                            .underline()
                            .font(.system(size: 25))
                            .padding()
                            .foregroundColor(.customColour)
                            .bold()
                        
                        DatePicker("Calendar", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)
                            .accentColor(.customColour)
                        
                        NavigationLink(destination: PracticeDetailView(selectedDate: formatDate(date: date))) {
                            Text("Show practice sessions on \(formatDate(date:date))")
                                .foregroundColor(.black)
                                .padding(EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40))
                                .background(Color.customColour)
                                .clipShape(Capsule())
                                .bold()
                        }
                    }
                    
                    Spacer()
                    
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    //Puts date taken as a parameter into the same format as that stored in CoreData
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func displayNextPoints(points: Int) -> Int {
        var points = 0
        let sortedLevels = levels.sorted(by: <)
        
        var totalPoints = 0
        for instrument in instruments {
            if instrument.isSelected == true {
                totalPoints = points + Int(instrument.points)
            }
        }
        
        for (key, _) in sortedLevels {
            if key > totalPoints {
                points = key
                break
            }
        }
        
        return points
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
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
