//
//  SideMenuView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 27/10/2022.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @State var currentInstrument: String
    var body: some View {
        ZStack {
            Color("colour1")
                .ignoresSafeArea()
            
            //Has 2 components: the main header displaying the current profile and the list of instruments
            VStack {
                SideMenuHeaderView(currentInstrument: $currentInstrument, isShowing: $isShowing)
                    .frame(height: 240)
                
                SideMenuOptionView(currentInstrument: $currentInstrument)
                
                Spacer()
            }
        }.navigationBarHidden(true)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowing: .constant(true), currentInstrument: "Piano")
    }
}
