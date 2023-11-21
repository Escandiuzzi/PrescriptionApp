//
//  ContentView.swift
//  PrescriptionApp
//
//  Created by Luiz Felipe Escandiuzzi on 20/11/23.
//

import SwiftUI
import PDFKit

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var url: String
    var activityItems: [Any] {
        [URL(string: url)!]
    }
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
    
}

struct ContentView: View {
    @State private var name: String = ""
    @State private var prescription: String = ""
    @State private var date: String = ""
    @State private var isSharePresented: Bool = false
    @State private var fileUrl: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 4) {
                Text("Create Prescription")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            
            TextField("Name", text: $name)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
                .font(.headline)
                .foregroundColor(.primary)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Prescription")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $prescription)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .frame(minHeight: 20)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
            .padding()
            
            TextField("Date", text:$date)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
                .font(.headline)
                .foregroundColor(.primary)
                .onAppear {
                    setup()
                }
            
            Button(action: {
                generatePdf()
            }) {
                Text("Generate")
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.blue)
                    )
                    .font(.headline)
            }
            .padding()
            
            Button("Share file") {
                self.isSharePresented = true
            }
            .sheet(isPresented: $isSharePresented, onDismiss: {
                print("Dismiss")
            }, content: {
                ActivityViewController(url: $fileUrl)
            })
            
        }
        .padding()
    }
    
    func setup() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMMM"
        
        var monthString = dateFormatter.string(from: currentDate)
        monthString = monthString.prefix(1).capitalized + monthString.dropFirst()
        
        let year = calendar.component(.year, from: currentDate)
        
        date = "\(String(day)) de \(monthString) de \(String(year))"
    }
    
    func generatePdf() {
        if let templateURL = Bundle.main.url(forResource: "prescription", withExtension: "pdf") {
            do {
                // Load the PDF document
                guard let pdfDocument = PDFDocument(url: templateURL) else {
                    print("Failed to load PDF document.")
                    return
                }
                
                guard let page = pdfDocument.page(at: 0) else {
                    print("Failed to get first page.")
                    return
                }
                
                let pdfData = NSMutableData()
                UIGraphicsBeginPDFContextToData(pdfData, page.bounds(for: .mediaBox), nil)
                
                UIGraphicsBeginPDFPage()
                
                // Apply a transformation to handle the orientation
                if let pdfContext = UIGraphicsGetCurrentContext() {
                    pdfContext.translateBy(x: 0, y: page.bounds(for: .mediaBox).size.height)
                    pdfContext.scaleBy(x: 1.0, y: -1.0)
                }
                
                // Draw the existing PDF content
                page.draw(with: .mediaBox, to: UIGraphicsGetCurrentContext()!)
                
                drawText(x: 130, y: 621, text: name)
                drawText(x: 140, y: 570, text: prescription)
                drawText(x: 94, y: 380, text: date)
                
                UIGraphicsEndPDFContext()
                
                if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    
                    let documentName = "receita_\(name)_\(getCurrentTimestampAsString()).pdf"
                    fileUrl = (documentsPath as NSString).appendingPathComponent(documentName)
                    
                    do {
                        try pdfData.write(toFile: fileUrl, options: .atomic)
                        print("PDF saved successfully at path: \(fileUrl)")
                    } catch {
                        print("Error saving PDF: \(error.localizedDescription)")
                    }
                    
                } else {
                    print("Error finding documents directory.")
                }
            }
        } else {
            print("Could not find file")
        }
    }
    
    func drawText(x: Int, y: Int, text: String) {
        let font = UIFont.systemFont(ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        if let pdfContext = UIGraphicsGetCurrentContext() {
            let rect = CGRect(x: x, y: y, width: 400, height: 200)
            
            pdfContext.saveGState()
            pdfContext.translateBy(x: rect.origin.x, y: rect.origin.y)
            pdfContext.scaleBy(x: 1.0, y: -1.0)
            pdfContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)
            
            text.draw(in: rect, withAttributes: attributes)
            
            pdfContext.restoreGState()
        }
    }
    
    func getCurrentTimestampAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestampString = dateFormatter.string(from: Date())
        return timestampString
    }
}

#Preview {
    ContentView()
}
