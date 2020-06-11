//
//  ExpandableListCell.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct ExpandableListCell: View {
    
    // MARK: - Variables
    let data: DummyData
    let isExpanded: Bool
    
    // MARK: - Views
    /// Body of Content View
    var body: some View {
        HStack {
            content
            Spacer()
        }
        .contentShape(Rectangle())
    }
    
    /// Content
    private var content: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(data.title)
                    .font(.headline)
                
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.trailing, 40)
            }
            
            if isExpanded {
                VStack(alignment: .leading) {
                    Text(data.subTitle)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.top,  16)
                        .padding(.trailing, 32)
                }
            }
        }
    }
}
