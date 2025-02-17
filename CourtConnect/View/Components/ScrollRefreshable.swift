//
//  ScrollRefreshable.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI

struct ScrollRefreshable<RefreshView: View, Content: View>: View, ScrollRefreshableView {
    var options: ScrollOptions
    var refresh: () -> RefreshView
    var content: () -> Content
    
    init(
        options: ScrollOptions = ScrollOptions(),
        refresh: @escaping () -> RefreshView,
        content: @escaping () -> Content
    ) {
        self.options = options
        self.refresh = refresh
        self.content = content
    }
   
    @State var yOffset: CGFloat = .zero
    @State var isRefreshing = false
    @State var scale: CGFloat = 0.0
    var body: some View {
        ScrollView {
            ScrollViewObserver(yOffset: $yOffset)
            VStack(spacing: options.verticalSpacing) {
                RefreshScreen(isRefreshing: $isRefreshing, scale: $scale, spacingTop: 50, spacingButton: 20) {
                    refresh()
                }
                
                content()
            }
        }
        .contentMargins(.top, 0)
        .contentMargins(.bottom, 75)
        .refrashTrigger(
            offset: $yOffset,
            scale: $scale,
            isRefreshing: $isRefreshing,
            option: RefrashTriggerOption(
                triggerPoint: 150,
                debug: false
            )
        )
    }
}

protocol ScrollRefreshableView: View {
    associatedtype RefreshView: View
    associatedtype Content: View
    var yOffset: CGFloat { get set }
    var isRefreshing: Bool { get set }
    var scale: CGFloat { get set }
    var options: ScrollOptions { get }
    @ViewBuilder var refresh: () -> RefreshView { get }
    @ViewBuilder var content: () -> Content { get }
}

struct ScrollViewObserver: View {
    @Binding var yOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .named("Scrollview")).minY) { _, newValue in
                    yOffset = newValue
                }
        }
        .frame(height: 0)
    }
}

struct RefreshScreen<Content: View>: View {
    @Binding var isRefreshing: Bool
    @Binding var scale: CGFloat
    let spacingTop: CGFloat
    let spacingButton: CGFloat
    @State private var sectionSize: CGSize = .zero
    @ViewBuilder let content: () -> Content
    var body: some View {
        if isRefreshing {
            HStack {
                content()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(maxHeight: isRefreshing ? sectionSize.height : 0)
            .scaleEffect(scale)
            .opacity(isRefreshing ? 1 : 0)
            .viewSize(size: $sectionSize)
            .padding(.top, spacingTop)
            .padding(.bottom, spacingButton)
        }
    }
}

extension View {
    func viewSize(size: Binding<CGSize>) -> some View {
        modifier(ViewSize(size: size))
    }
    
    func refrashTrigger(
        offset: Binding<CGFloat>,
        scale: Binding<CGFloat>,
        isRefreshing: Binding<Bool>,
        option: RefrashTriggerOption
    ) -> some View {
        modifier(
            RefrashTrigger(offset: offset, scale: scale, isRefreshing: isRefreshing, option: option)
        )
    }
}

struct RefrashTrigger: ViewModifier {
    @Binding var offset: CGFloat
    @Binding var scale: CGFloat
    @Binding var isRefreshing: Bool
    let option: RefrashTriggerOption
    func body(content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .onChange(of: offset) {
                if option.debug {
                    print(offset)
                }
                if offset > option.triggerPoint && !isRefreshing {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRefreshing = true
                        scale = 1.0
                    }

                    Task {
                        try await Task.sleep(for: .seconds(option.duration))
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRefreshing = false
                                scale = 0.0
                            }
                        }
                    }
                }
            }
    }
}

struct RefrashTriggerOption {
    let triggerPoint: CGFloat
    let duration: CGFloat
    let debug: Bool
    
    init(triggerPoint: CGFloat, duration: CGFloat = 2, debug: Bool = false) {
        self.triggerPoint = triggerPoint
        self.duration = duration
        self.debug = debug
    }
}

struct ScrollOptions {
    let verticalSpacing: CGFloat
    
    init(verticalSpacing: CGFloat = 20) {
        self.verticalSpacing = verticalSpacing
    }
}

struct ViewSize: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: {
                self.size = $0
            }
    }
}

#Preview {
    NavigationStack {
        
        ScrollRefreshable(
            options: ScrollOptions(
                verticalSpacing: 100
            ),
            refresh: {
                Text("Refreshing...")
                    .onAppear { print("FETCHING") }
                    .onDisappear { print("END FETCHING") }
            },
            content: {
                Group {
                    Rectangle().frame(width: .infinity, height: 400)
                    Rectangle().frame(width: .infinity, height: 400)
                    Rectangle().frame(width: .infinity, height: 400)
                }
            }
        )
        .background(.red)
    }
}
