//
//  PDFKitView.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//  source: https://stackoverflow.com/questions/61478290/how-can-i-open-a-local-pdf-file-using-a-swiftui-button

import SwiftUI
import PDFKit

struct PDFKitView: View {
    
    var data: Data?;
    var placeHolder:() -> AnyView;
    
    init(_ url: URL, placeHolder: @escaping () -> AnyView = { Text("Placeholder").eraseToAnyView() }) {
        self.data = try? Data.init(contentsOf: url, options: .mappedIfSafe)
        self.placeHolder = placeHolder
    }

    init(_ data: Data, placeHolder: @escaping () -> AnyView = { Text("Placeholder").eraseToAnyView() }) {
        self.data = data
        self.placeHolder = placeHolder
    }
    
    var body: some View { getView() }
    
    func getView() -> some View {
        
        guard let data = self.data else {
            return placeHolder().eraseToAnyView()
        }
        
        return PDFKitRepresentedView(data).eraseToAnyView()
        
    }
    
}

struct PDFKitRepresentedView: UIViewRepresentable {
    
    let data: Data
    init(_ data: Data) {
        self.data = data
    }

    func makeUIView(context: UIViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.UIViewType {
        let pdfView = PDFView()
        pdfView.document = PDFDocument.init(data: self.data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFKitRepresentedView>) {
        // Update the view.
    }
}
