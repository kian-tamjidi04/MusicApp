//
//  MusicApp.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 08/09/2022.
//

import SwiftUI

@available(iOS 16.0, *)
@main
struct MusicApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            //Creates tabs at the bottom of the screen so the user can navigate my app
            TabView {
                HomeScreen()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Home", systemImage: "music.note.house.fill")
                    }
                MainTargetScreen()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Targets", systemImage: "target")
                    }
                AchievementScreen()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Achievements", systemImage: "star.circle.fill")
                    }
                MainTheoryScreen(sortedList: topics, toggleIsOn: true)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Theory", systemImage: "music.note")
                    }
                SummaryScreen()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Summary", systemImage: "list.bullet.rectangle.fill")
                    }
            }
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            
        }
    }
}

public extension Color {
    static let customColour = Color("colour1")
}

public extension Date {
    static var oneWeekAgo: Date { return Date().weekBefore }
    static var oneDayAgo: Date { return Date().dayBefore }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
    }
    var weekBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: midnight)!
    }
    var midnight: Date {
        return Calendar.current.date(bySettingHour: 00, minute: 0, second: 0, of: self)!
    }
}

struct Previews_MusicApp_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
