//
//  SideMenuOptionView.swift
//  MusicApp
//
//  Created by Kian Tamjidi on 27/10/2022.
//

import SwiftUI

struct SideMenuHeaderView: View {
    //Binding allows the isShowing variable to be bound between each view
    @Binding var currentInstrument: String
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing){
            Button(action: {
                withAnimation(.spring()) {
                    isShowing.toggle()
                }}, label: {
                Image(systemName: "xmark")
                    .frame(width: 32, height: 32)
                    .foregroundColor(.black)
                    .padding()
            })
            VStack(alignment: .leading){
                Image("profilePicture")
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .frame(width: 64, height:64)
                    .clipShape(Circle())
                    .padding(.bottom, 16)
                
                Text(currentInstrument)
                    .font(.system(size: 24, weight: .semibold))
                
                HStack {
                    Spacer()
                }  
            }.padding()
        }
    }
}

struct SideMenuHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuHeaderView(currentInstrument: .constant("Piano"), isShowing: .constant(true))
    }
}
