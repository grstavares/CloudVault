//
//  DangerButtonStyle.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct Danger: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.red)
            .animation(.spring())
    }

}
