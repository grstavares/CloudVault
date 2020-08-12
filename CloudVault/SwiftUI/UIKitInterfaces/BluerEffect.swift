//
//  BluerEffect.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 17.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import SwiftUI

struct BlurEffect: UIViewRepresentable {
    
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        
//        return UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
//        view.insertSubview(blurView, at: 0)
//        NSLayoutConstraint.activate([
//            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
//        ])
//
//        return view
        
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//        uiView.effect = UIBlurEffect(style: style)
    }
    
}

struct VibrancyEffect: UIViewRepresentable {
    
    var style: UIBlurEffect.Style = .systemMaterial
    var vibrancy: UIVibrancyEffectStyle = .fill
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: style), style: vibrancy))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: style), style: vibrancy)
    }
    
}
