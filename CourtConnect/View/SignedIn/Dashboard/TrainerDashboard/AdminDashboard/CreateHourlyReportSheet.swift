//
//  CreateHourlyReportSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
// 
import SwiftUI
  
struct CreateHourlyReportSheet: View {
    @State var viewModel = CreateHourlyReportSheetViewModel()
    var body: some View {
        SheetStlye(title: "Create hourly report", detents: [.medium], isLoading: .constant(false)) {
            ZStack {
                VStack {
                    DatePicker("Start date", selection: $viewModel.start, in: ...Date(), displayedComponents: .date)
                    
                    DatePicker("End date", selection: $viewModel.end, in: viewModel.start...Date(), displayedComponents: .date)
                    
                    Button("Generate pdf") {
                        Task {
                            await viewModel.getTrainerData()
                        }
                    }
                    .buttonStyle(DarkButtonStlye())
                    .padding(.bottom, 20)
                     
                    if !viewModel.currentList.isEmpty {
                        let page = PDFInfo(image: Image(.appIcon), list: viewModel.currentList, createdAt: Date())
                        ShareLinkPDFView(page: page)
                    } else {
                        NoConfirmedCoaches()
                    }
                }
                
                LoadingCard(isLoading: $viewModel.isLoading)
            }
            .errorAlert()
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    @Previewable let cal = Calendar.current
    @Previewable @State var isSheet = true
    @Previewable @State var start: Date = Date().startOfMonth
    @Previewable @State var end = Date().endOfMonth
    AdminDashboardView()
        .sheet(isPresented: $isSheet) {
            CreateHourlyReportSheet()
        }
}
