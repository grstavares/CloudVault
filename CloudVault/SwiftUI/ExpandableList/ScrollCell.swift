//
//  ScrollCell.swift
//  Expandable List View
//
//  Copyright © MITLicense. All rights reserved.
//  source: git@github.com:NilaakashSingh/ExpandableList.git

import SwiftUI

struct ScrollCell: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
            Divider()
        }.offset(x: 20)
    }
}
