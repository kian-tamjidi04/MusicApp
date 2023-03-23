//
//  MainTargetScreen.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 10/09/2022.
//

import SwiftUI
import Foundation
import CoreData

@available(iOS 16.0, *)
struct MainTargetScreen: View {
    
    @State var inputTarget: String = ""

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.task)
    ]) var targets: FetchedResults<CoreTarget>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showCompleted: Bool = false
    @State private var showingAlert = false
    
    //Saves target into core data
    func saveTarget() {
        let newTarget = CoreTarget(context: viewContext)
        newTarget.task = inputTarget
        newTarget.isCompleted = false
        newTarget.profile = selectProfile()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Deletes target from core data
    func deleteTarget(target: CoreTarget) {
        viewContext.delete(target)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Checks if the target is already saved
    func checkTarget(inputTarget: String) -> Bool {
        for target in targets {
            if target.task == inputTarget {
                return false
            }
        }
        return true
    }
    
    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    //User enters their target
                    TextField("Enter a target: ", text: $inputTarget)
                        .submitLabel(.go)
                        .onSubmit {
                            if checkTarget(inputTarget: inputTarget){
                                saveTarget()
                            } else {
                                showingAlert = true
                            }
                        }
                        .padding()
                        //Alerts the user that the target is already in progress
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Error"), message: Text("Target already in progress"), dismissButton: .default(Text("Ok")))
                        }
            
                    //Changes whether completed or uncompleted tasks are shown
                    Toggle(isOn: $showCompleted) {
                        Text(showCompleted ? "Completed Tasks": "Tasks To Do")
                            .bold()
                    }.padding()
                        .toggleStyle(SwitchToggleStyle(tint: .customColour))
                    
                }
                Text("Press and hold box to delete")
                List() {
                    ForEach(targets) { target in
                        //Checks profile corresponds to target profile
                        if target.profile == selectProfile() {
                            //Shows target depending on whether is is ticked off or not
                            if (target.isCompleted == false && showCompleted == false) || (target.isCompleted == true && showCompleted == true){
                                HStack{
                                    Image(systemName: target.isCompleted ? "checkmark.square" : "square")
                                        .onTapGesture {
                                            changeIsCompleted(target: target)
                                        }
                                        .foregroundColor(Color.customColour)
                                        .simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.3).onEnded({ _ in
                                                deleteTarget(target: target)
                                            }))
                                    
                                    Text(target.task ?? "error")
                                        .strikethrough(target.isCompleted)
                                    
                                }
                            }
                        }
                    }
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("Targets")
        }
    }
    
    func grabDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let result = formatter.string(from: currentDate)
        return result
    }
}

@available(iOS 16.0, *)
struct MainTargetScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainTargetScreen()
    }
}
