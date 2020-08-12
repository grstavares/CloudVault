//
//  CreditCardList.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 22.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct CreditCardList: View {

    @State var deals: [Deal] = []
    @State var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(deals) { deal in
                return DealView(deal: deal)
                    .frame(width: 338, height: 220, alignment: .center)
                    .cornerRadius(8)
                    .scaleEffect(0.8 + CGFloat(self.order(for: deal)) * 0.12)
                    .offset(x: 0, y: CGFloat(self.order(for: deal)) * -50.0)
                    .offset(x: self.dragOffset.width * CGFloat(self.order(for: deal)) * 0.2, y: self.dragOffset.height * CGFloat(self.order(for: deal)) * 0.2)
                    .shadow(radius: 20)
                    .animation(.interpolatingSpring(stiffness: 50, damping: 5)) // This curve will be applied to the offset and scale modifiers
                    .brightness(-0.3 + Double(self.order(for: deal)) * 0.1)
                    .animation(.easeInOut(duration: 0.5)) // This curve will be applied to the brightness modifier
                    .onTapGesture {
                        self.bringToFront(deal)
                }.gesture(DragGesture().onChanged({ value in
                    self.dragOffset = value.translation
                }).onEnded({ _ in
                    self.dragOffset = .zero
                }))
            }
        }.padding()
    }

    private func order(for deal: Deal) -> Int {
        return deals.firstIndex(where: { $0.id == deal.id })!
    }

    private func bringToFront(_ deal: Deal) {
        
        guard let idx = deals.firstIndex(where: { $0.id == deal.id }) else { return }

        var mutableDeals = deals
        var mutableDeal = deal

        mutableDeal.order = deals.count + 1

        mutableDeals.remove(at: idx)
        mutableDeals.append(mutableDeal)

        deals = mutableDeals.sorted(by: { $0.order < $1.order })

    }
    
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        CreditCardList(deals: Deal.previewContent.sorted(by: { $0.order < $1.order }))
    }
}
