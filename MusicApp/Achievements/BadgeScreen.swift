//
//  BadgeScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 03/03/2023.
//

import SwiftUI

@available(iOS 16.0, *)
struct BadgeScreen: View {
    var streak: Int
    var level: Int
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            HStack {
                //Streak achievement
                VStack {
                    Text("Streak Master")
                        .font(.system(size: 30))
                        .padding()
                        .foregroundColor(.customColour)
                        .bold()
                        .underline()
                    
                    //Displays the relevant image with the length of time the user has maintained the streak
                    if streak >= 7 && streak < 14 {
                        StreakBadge(image: "1_week", lengthOfTime: "1 week")
                    } else if streak >= 14 && streak < 30 {
                        StreakBadge(image: "2_weeks", lengthOfTime: "2 week")
                    } else if streak >= 30 && streak < 90 {
                        StreakBadge(image: "1_month", lengthOfTime: "1 month")
                    } else if streak >= 90 && streak < 180 {
                        StreakBadge(image: "3_months", lengthOfTime: "3 month")
                    } else if streak >= 180 && streak < 360 {
                        StreakBadge(image: "6_months", lengthOfTime: "6 month")
                    } else if streak >= 360 {
                        StreakBadge(image: "1_year", lengthOfTime: "1 year")
                    } else {
                        Image("Hidden Trophy")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Trophy not achieved yet")
                            .font(.system(size: 23))
                            .foregroundColor(.customColour)
                            .bold()
                            .underline()
                    }
                }
                
                //Longest session achievement
                VStack {
                    Text("Longest Session")
                        .font(.system(size: 30))
                        .foregroundColor(.customColour)
                        .bold()
                        .underline()
                    
                    Image("Longest Session")
                        .resizable()
                        .scaledToFit()
                    
                    Text(longestTimeCalculator())
                        .font(.system(size: 23))
                        .foregroundColor(.customColour)
                        .bold()
                        .underline()
                }
            }
            
            //Level up achievement
            VStack{
                Text("Level Up")
                    .font(.system(size: 30))
                    .padding()
                    .foregroundColor(.customColour)
                    .bold()
                    .underline()
                
                //Displays the relevant image depending on the user's level
                Image("Level \(level)")
                    .resizable()
                    .scaledToFit()
                
                Text("Level \(level)")
                    .font(.system(size: 23))
                    .foregroundColor(.customColour)
                    .bold()
                    .underline()
                    .padding()
            }
        }
    }
    
    //Returns the longest session completed by the user in an easy to read format
    func longestTimeCalculator() -> String {
        for instrument in instruments {
            if instrument.isSelected == true {
                return timeString(time: Int(instrument.longestSession))
            }
        }
        
        return ""
    }
    
    //Formats the time into something that is easier to read
    func timeString(time: Int) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

//A view that displays all information relating to the streak badge
struct StreakBadge: View {
    var image: String
    var lengthOfTime: String
    
    var body: some View {
        VStack{
            Image(image)
                .resizable()
                .scaledToFit()
            
            Text("\(lengthOfTime) streak")
                .font(.system(size: 23))
                .foregroundColor(.customColour)
                .bold()
                .underline()
        }
    }
}

@available(iOS 16.0, *)
struct BadgeScreen_Previews: PreviewProvider {
    static var previews: some View {
        BadgeScreen(streak: 33, level: 6)
    }
}

