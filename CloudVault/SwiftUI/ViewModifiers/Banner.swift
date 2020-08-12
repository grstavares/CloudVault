//
//  Banner.swift
//  BannersSwiftUI
//
//  Created by Jean-Marc Boullianne on 11/30/19.
//  Copyright © 2019 Jean-Marc Boullianne. All rights reserved.
//  source: git@github.com:jboullianne/SwiftUIBanner.git

import SwiftUI

public struct Banner {
    
    static func info(title: String, detail: String) -> BannerModifier.BannerData { BannerModifier.BannerData(title: title, detail: detail, type: .Info) }
    static func warning(title: String, detail: String) -> BannerModifier.BannerData { BannerModifier.BannerData(title: title, detail: detail, type: .Warning) }
    static func success(title: String, detail: String) -> BannerModifier.BannerData { BannerModifier.BannerData(title: title, detail: detail, type: .Success) }
    static func error(title: String, detail: String) -> BannerModifier.BannerData { BannerModifier.BannerData(title: title, detail: detail, type: .Error) }
    
}

struct BannerModifier: ViewModifier {
    
    struct BannerData {
        var title:String
        var detail:String
        var type: BannerType
    }
    
    enum BannerType {
        case Info
        case Warning
        case Success
        case Error
        
        var tintColor: Color {
            switch self {
            case .Info:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .Success:
                return Color.green
            case .Warning:
                return Color.yellow
            case .Error:
                return Color.red
            }
        }
    }
    
    // Members for the Banner
    var data:BannerData
    @Binding var show:Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.title)
                                .bold()
                            Text(data.detail)
                                .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(12)
                    .background(data.type.tintColor)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
                .animation(.easeInOut)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }

}

extension View {
    func banner(data: BannerModifier.BannerData, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
    }
}
