//
//  PDFContentView.swift
//  PrescriptionApp
//
//  Created by Luiz Felipe Escandiuzzi on 23/11/23.
//

import SwiftUI
import PDFKit

struct PDFContentView: View {
    var url: String
    
    var body: some View {
        VStack{
            PDFKitView(url: URL(string: url)!)
                .scaledToFill()
        }
        .padding()
    }
}

// Add this:
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    PDFContentView(url: "")
}
