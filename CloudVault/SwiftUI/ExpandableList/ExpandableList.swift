//
//  ExpandableList.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//  source: git@github.com:NilaakashSingh/ExpandableList.git

import SwiftUI

struct ExpandableList: View {
    
    // MARK: - Variables
    @State private var selectedCellArray: Set<DummyData> = []
    let dummyArray: [DummyData]
    
    // MARK: - View
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(dummyArray) { about in
                    ExpandableListCell(data: about,
                                    isExpanded: self.selectedCellArray.contains(about))
                        .modifier(ScrollCell())
                        .onTapGesture { self.handleCellTap(about) }
                        .animation(.linear(duration: 0.3))
                        .padding([.top, .bottom], 2)
                }
            }
            .padding(.top, 10)
            .navigationBarTitle("Expandable List", displayMode: .automatic)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleCellTap(_ about: DummyData) {
        if selectedCellArray.contains(about) {
            selectedCellArray.remove(about)
        } else {
            selectedCellArray.insert(about)
        }
    }
}

struct ExpandableList_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableList(dummyArray: DummyData.dataArray())
    }
}
