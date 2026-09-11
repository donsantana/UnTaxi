//
//  ReviewView.swift
//  UnTaxi
//
//  Created by Done Santana on 6/23/26.
//  Copyright © 2026 Done Santana. All rights reserved.
//

import SwiftUI
import StoreKit

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Minimal UI; you can customize or hide this as needed
            Text("Gracias por usar UnTaxi")
                .font(.headline)
            Text("Si te gusta la app, ¿podrías calificarnos?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("En otro momento") {
                dismiss()
            }.buttonStyle(.bordered)

//            #if DEBUG
//            Button("Solicitar reseña ahora (DEBUG)") {
//                requestReview()
//            }
//            .buttonStyle(.borderedProminent)
//            #endif
        }
        .padding()
        .onAppear {
            // Trigger once when this view appears
            requestReview()
        }
        .onTapGesture {
            dismiss()
        }
    }

    private func requestReview() {
        
//        let appID = GlobalConstants.appNumberId
//        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
//            UIApplication.shared.open(url)
//        } else {
//            
            // Always prefer requesting in the active UIWindowScene
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                SKStoreReviewController.requestReview(in: scene)
                return
            }
            
            // Fallback: use any connected window scene's windows without using deprecated UIApplication.shared.windows
            if let anyWindowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
               let activeWindow = anyWindowScene.windows.first {
                SKStoreReviewController.requestReview(in: activeWindow.windowScene!)
            }
        }
//    }
}

#Preview {
    ReviewView()
}
