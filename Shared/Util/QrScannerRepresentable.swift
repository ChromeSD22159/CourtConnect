//
//  QrScannerRepresentable.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import SwiftUI
import VisionKit
import Auth

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var shouldStartScanning: Bool
    @Binding var scannedText: String
    var dataToScanFor: Set<DataScannerViewController.RecognizedDataType>
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
       var parent: DataScannerRepresentable
       
       init(_ parent: DataScannerRepresentable) {
           self.parent = parent
       }
               
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scannedText = text.transcript
            case .barcode(let barcode):
                parent.scannedText = barcode.payloadStringValue ?? "Unable to decode the scanned code"
            default:
                print("unexpected item")
            }
        }
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: dataToScanFor,
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        dataScannerVC.delegate = context.coordinator
       
       return dataScannerVC
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
       if shouldStartScanning {
           try? uiViewController.startScanning()
       } else {
           uiViewController.stopScanning()
       }
    }

    func makeCoordinator() -> Coordinator {
       Coordinator(self)
    }
} 

struct QRScannerView : View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel = QRScannerViewModel()
    var body: some View {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            ZStack(alignment: .bottom) {
                DataScannerRepresentable(
                    shouldStartScanning: $viewModel.isShowingScanner,
                    scannedText: $viewModel.scannedText,
                    dataToScanFor: [.barcode(symbologies: [.qr])]
                )
                    .ignoresSafeArea()
                    .overlay(alignment: .top) {
                        ListInfomationSection(text: "Tap a QR code when it has been recognized you can join the team!")
                            .padding(20)
                            .background(Material.ultraThinMaterial)
                            .borderRadius(15)
                    }
                
                if !viewModel.scannedText.isEmpty {
                    Text("Join Team")
                        .font(.subheadline)
                        .onTapGesture {
                            Task {
                                do {
                                    try await viewModel.joinTeam(viewModel.scannedText)
                                    dismiss()
                                } catch {
                                    ErrorHandlerViewModel.shared.handleError(error: error)
                                }
                            }
                        }
                        .errorAlert()
                        .padding(20)
                        .foregroundColor(Theme.white)
                        .shadow(radius: 2)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(Theme.headlineReversed)
                                
                                Circle()
                                    .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 0)
                                    .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 15)
                                    .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 30)
                            }
                            .frame(width: 70, height: 70)
                        )
                      
                }
            }
           
        } else if !DataScannerViewController.isSupported {
            Text("It looks like this device doesn't support the DataScannerViewController")
        } else {
            Text("It appears your camera may not be available")
        }
    }
}

#Preview {
    @Previewable @State var text: String = "152632"
    ZStack(alignment: .bottom) {
        if !text.isEmpty {
            Text("Join Team")
                .font(.caption2)
                .onTapGesture {
                    
                }
                .padding(20)
                .foregroundColor(Theme.white)
                .shadow(color: .black, radius: 7)
                .background(
                    ZStack {
                        Circle()
                            .fill(Theme.headlineReversed)
                        
                        Circle()
                            .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 0)
                            .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 15)
                            .stroke(Theme.headlineReversed.opacity(0.3), lineWidth: 30)
                    }
                    .frame(width: 70, height: 70)
                )
              
        }
    }
}
