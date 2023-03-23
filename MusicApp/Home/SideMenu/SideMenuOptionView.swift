//
//  SideMenuOptionView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 28/10/2022.
//
import SwiftUI
import Foundation
import CoreData

struct SideMenuOptionView: View {
    @State var instrumentChoice: String = ""
    @State var addInstrument: Bool = true
    @Binding var currentInstrument: String
    @State var delete: String = "Delete"
    
    //Fetches required items from CoreData
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.name),
            SortDescriptor(\.isSelected)
        ],
        animation: .default)
    private var instruments: FetchedResults<CoreInstrument>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            //Iterates through each instrument and outputs the name alongside 2 buttons to
            //select of delete the instrument profile
            ForEach(instruments) { instrument in
                HStack {
                    Text(instrument.name ?? "")
                        .background(Color.white.opacity(0.5))
                        .font(.system(size: 20.0))
                        .padding()
                        .foregroundColor(Color.black)
                    
                    Button {
                        self.currentInstrument = instrument.name ?? ""
                        selectInstrumentProfile(currentInstrument: currentInstrument)
                    } label: {
                        Text("Select")
                    }
                    
                    Button {
                        deleteInstrument(instrument: instrument)
                    } label: {
                        Text("Delete")
                    }
                    
                }
            }
            
            TextField("Enter Instrument:", text: $instrumentChoice)
            
            Button("Add") {
                addProfile()
            }.padding(.bottom)
            
            Spacer()
        }
        .padding()
    }
    
    //Validation: checks the instrument isn't already saved to prevent duplicates
    func checkInstrument(){
        for instrument in instruments {
            if instrumentChoice == instrument.name {
                addInstrument = false
                break
            } else {
                addInstrument = true
            }
        }
    }

    //Saves the instrument to CoreData
    func addProfile() {
        checkInstrument()
        if addInstrument == true {
            let newCoreInstrument = CoreInstrument(context: viewContext)
            newCoreInstrument.name = instrumentChoice
            newCoreInstrument.points = 0
            newCoreInstrument.streak = 0
            newCoreInstrument.level = 1
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
        instrumentChoice = ""
    }
    
    //Deletes instrument from CoreData
    func deleteInstrument(instrument: CoreInstrument) {
        viewContext.delete(instrument)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    //Changes the state of the isSelected attribute in memory
    //for when the user wants to set a practice session
    func selectInstrumentProfile(currentInstrument: String) {
        for instrument in instruments{
            if instrument.name == currentInstrument {
                instrument.isSelected = true
            } else {
                instrument.isSelected = false
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(currentInstrument: .constant("Piano"))
    }
}
