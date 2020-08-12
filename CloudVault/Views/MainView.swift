//
//  MainView.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 17.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

enum NavigationOption: CaseIterable, Identifiable {
    
    case links, photos, videos, docs, text, contacts, passwd, cards, plus
    
    var id: String {
        switch self {
        case .links: return "link"
        case .photos: return "photo"
        case .videos: return "video"
        case .docs: return "doc"
        case .text: return "doc.text"
        case .contacts: return "person"
        case .passwd: return "pencil.and.ellipsis.rectangle"
        case .cards: return "creditcard"
        case .plus: return "plus"
        }
    }
    
    var label: String {
        switch self {
        case .links: return NSLocalizedString("MainView-Button-Web links", comment: "Main View Navigation Button")
        case .photos: return NSLocalizedString("MainView-Button-Photos", comment: "Main View Navigation Button")
        case .videos: return NSLocalizedString("MainView-Button-Videos", comment: "Main View Navigation Button")
        case .docs: return NSLocalizedString("MainView-Button-Documents", comment: "Main View Navigation Button")
        case .text: return NSLocalizedString("MainView-Button-Annotations", comment: "Main View Navigation Button")
        case .contacts: return NSLocalizedString("MainView-Button-Contacts", comment: "Main View Navigation Button")
        case .passwd: return NSLocalizedString("MainView-Button-Passwords", comment: "Main View Navigation Button")
        case .cards: return NSLocalizedString("MainView-Button-CreditCard", comment: "Main View Navigation Button")
        case .plus: return NSLocalizedString("MainView-Button-Add Item", comment: "Main View Navigation Button")
        }
    }
    
    var systemImage: String {
        switch self {
        case .links: return "link"
        case .photos: return "photo"
        case .videos: return "video"
        case .docs: return "doc"
        case .text: return "doc.text"
        case .contacts: return "person"
        case .passwd: return "pencil.and.ellipsis.rectangle"
        case .cards: return "creditcard"
        case .plus: return "plus"
        }
    }
    
    var assetView: some View {
        switch self {
        case .links: return AssetList(assetType: .url)
        case .photos: return AssetList(assetType: .image)
        case .videos: return AssetList(assetType: .movie)
        case .docs: return AssetList(assetType: .pdf)
        case .text: return AssetList(assetType: .text)
        case .contacts: return AssetList(assetType: .contact)
        case .passwd: return AssetList(assetType: .password)
        case .cards: return AssetList(assetType: .creditCard)
        case .plus: return AssetList(assetType: .url)
        }
    }
    
}

struct MainViewBackground: View {
    
    let assetName = "background"
    
    var body: some View {
        
        ZStack {
            
            Image(assetName)
                .resizable()
                .scaledToFill()
                .blur(radius: 5)
                .edgesIgnoringSafeArea(.all)
            
            Color.gray
                .edgesIgnoringSafeArea(.all)
                .opacity(0.05)
            
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
        
    }
    
}

struct MainView: View {
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                MainViewBackground()
                MainViewButtonSet()
                    .preferredColorScheme(.dark)
            }.navigationViewStyle(StackNavigationViewStyle())
                .navigationBarItems(trailing:
                    NavigationLink(
                        destination: Settings().environmentObject(AppSettings.shared),
                        label: { Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(.largeTitle) }
                    )
            )
        }

    }
    
    
}

struct MainViewButtonSet: View {

    var numberOfButtons: Int { AppSystem.shared.isPortrait ? 3 : 5 }
    
    var preferedButtonSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let preferedSize = (screenWidth / CGFloat(numberOfButtons)) * 0.8
        return preferedSize
    }
    
    var buttonsArray: [[NavigationOption]] {
        
        var mainArray: [[NavigationOption]] = []
        var pointer = 0
        while pointer < NavigationOption.allCases.count {
            
            let endIndex = (pointer + numberOfButtons) >= NavigationOption.allCases.count ? NavigationOption.allCases.count - 1 : pointer + numberOfButtons - 1
            let slice = NavigationOption.allCases[pointer...endIndex]
            mainArray.append(Array(slice))
            pointer = pointer + numberOfButtons
            
        }

        return mainArray
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {

            ForEach(self.buttonsArray, id: \.self) { line in
                MainViewButtonLine(buttonSize: self.preferedButtonSize, options: line)
                    .padding()
            }
            
        }
        
    }
    
}

struct MainViewButtonLine: View {

    let buttonSize: CGFloat
    let options: [NavigationOption]
    
    var body: some View {
        
        HStack {
            ForEach(options) {option in
                MainViewButton(buttonSize: self.buttonSize, option: option).padding(self.buttonSize * 0.05)
            }
        }
        .padding(10)
        
    }

}

struct MainViewButton: View {
    
    let buttonSize: CGFloat
    let option: NavigationOption
    let paddingSize: CGFloat = 20
    let buttonColor: Color = .white
    
    var lineSize: CGFloat { (buttonSize * 3) + (paddingSize) }
    var imageSize: CGFloat { buttonSize * 0.6 }
    
    var body: some View {
        
        NavigationLink(destination: option.assetView) {
            VStack {
                
                Image(systemName: option.systemImage)
                    .foregroundColor(buttonColor)
                    .font(.system(size: 50))
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .padding(paddingSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: buttonSize + (paddingSize * 2) / 2)
                            .stroke(buttonColor, lineWidth: 2)
                )
                
                Text(option.label.split(separator: "-")[2])
                    .foregroundColor(buttonColor)
                
            }
            .frame(width: buttonSize, height: buttonSize, alignment: .center)
            
        }
        
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView().previewDevice(.init(rawValue: "iPhone 11"))
            MainView().previewDevice(.init(rawValue: "iPhone SE"))
        }
        
    }
}
