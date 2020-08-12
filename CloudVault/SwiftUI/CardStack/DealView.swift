//
//  DealView.swift
//  DealStack
//
//  Created by Guilherme Rambo on 04/07/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import SwiftUI

struct Deal: Identifiable {
    var order: Int
    let id: UUID
    let title: String
    let imageName: String
    let formattedPrice: String
}

struct DealView: View {
    
    @State var deal: Deal

    var body: some View {
        
        ZStack {
            Image(self.deal.imageName)
                .cornerRadius(8)

            VStack {
                HStack {
                    Spacer()
                    PriceView(formattedPrice: self.deal.formattedPrice).shadow(radius: 10)
                }
                .padding()

                Spacer()

                ZStack {
                    Text(deal.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .padding()
                        .shadow(color: .init(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 2, x: 0, y: 1)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom))
                        .blendMode(.overlay)
                )
            }
        }
    }
}

#if DEBUG
extension Deal {
    static let previewContent: [Deal] = [
        Deal(
            order: 0,
            id: UUID(),
            title: "Buffet Livre de Sushi com Pratos Quentes e 1 Temaki",
            imageName: "deal1",
            formattedPrice: "R$ 69,90"
        ),
        Deal(
            order: 1,
            id: UUID(),
            title: "Festival de Pizza e Massas para até 2 Pessoas",
            imageName: "deal2",
            formattedPrice: "R$ 44,90"
        ),
        Deal(
            order: 2,
            id: UUID(),
            title: "Fondue de Queijo e Chocolate para 2 pessoas",
            imageName: "deal3",
            formattedPrice: "R$ 69,90"
        ),
        Deal(
            order: 3,
            id: UUID(),
            title: "Rodízio de Carnes Completo com Buffet pra até 2 pessoas",
            imageName: "deal4",
            formattedPrice: "R$ 47,90"
        )
    ]
}
#endif

#if DEBUG
struct DealView_Previews : PreviewProvider {
    static var previews: some View {
        DealView(deal: Deal.previewContent[0])
            .previewLayout(.fixed(width: 338, height: 220))
    }
}
#endif
