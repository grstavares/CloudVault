//
//  DummyData.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
struct DummyData: Identifiable, Hashable {
    
    private static let dataTitle = ["Section 1",
                                    "Section 2",
                                    "Section 3"]
    
    private static let dataSubtitle = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ultricies porttitor hendrerit. Morbi tempus placerat justo. Vivamus finibus arcu in magna venenatis, et rutrum massa facilisis. Duis pretium maximus est, a imperdiet libero mollis et. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum dignissim egestas fermentum. Donec cursus, mauris id ullamcorper aliquam, purus felis pretium enim, et bibendum sem ex in risus. Pellentesque gravida lacus sed mattis consectetur.",
                                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ultricies porttitor hendrerit. Morbi tempus placerat justo. Vivamus finibus arcu in magna venenatis, et rutrum massa facilisis. Duis pretium maximus est, a imperdiet libero mollis et. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum dignissim egestas fermentum. Donec cursus, mauris id ullamcorper aliquam, purus felis pretium enim, et bibendum sem ex in risus. Pellentesque gravida lacus sed mattis consectetur.",
                                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ultricies porttitor hendrerit. Morbi tempus placerat justo. Vivamus finibus arcu in magna venenatis, et rutrum massa facilisis. Duis pretium maximus est, a imperdiet libero mollis et. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum dignissim egestas fermentum. Donec cursus, mauris id ullamcorper aliquam, purus felis pretium enim, et bibendum sem ex in risus. Pellentesque gravida lacus sed mattis consectetur."]
    
    // MARK: - Variables
    let id: Int
    let title: String
    let subTitle: String
    
    // MARK: - Methods
    static func dataArray() -> [DummyData] {
        (0 ..< dataTitle.count).map(DummyData.mapDummyObject)
    }
    
    private static func mapDummyObject(_ row: Int) -> DummyData {
        DummyData(id: row, title: dataTitle[row], subTitle: dataSubtitle[row])
    }
}
