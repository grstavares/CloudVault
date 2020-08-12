//
//  CardViewTest.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 23.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct CardViewTest<Content>: View where Content: View {
    let color: Color
    let radius: CGFloat
    let content: () -> Content
    
    init(
        color: Color = Color.gray.opacity(0.4),
        radius: CGFloat = 8,
        @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.radius = radius
    }
    
    var body: some View {
        content()
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color, radius: radius, x: 4, y: 4)
        .padding(radius + 8)
    }
}

struct ExapleCardViewTest: View {
    var body: some View {
        VStack {
            CardViewTest {
                Text("Snorlax")
            }

            CardViewTest {
                Image("icon")
                    .resizable()
                    .frame(width: 60, height: 60)
            }

            CardViewTest(color: Color.red.opacity(0.4)) {
                Text("RedShadow")
            }

            CardViewTest(
                color: Color.green.opacity(0.4),
                radius: 24) {
                    Text("BigShadow")
            }
        }
    }
}


struct ExapleCardViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ExapleCardViewTest()
    }
}
