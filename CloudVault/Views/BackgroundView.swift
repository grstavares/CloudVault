//
//  BackgroundView.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 21.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct BackgroundView: View {

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
                .opacity(0.10)
            
        }
        
    }
    
    
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
