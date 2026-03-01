import SwiftUI

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder
    func apply<V: View>(@ViewBuilder _ transform: (Self) -> V) -> some View {
        transform(self)
    }
}

struct MainTabView: View {
    @EnvironmentObject var store: ContentStore
    @State private var selectedDate: String = ""
    @State private var contentTab: ContentTab = .book
    
    enum ContentTab: Int, CaseIterable {
        case book = 0
        case quote = 1
        case settings = 2
        
        var title: String {
            switch self {
            case .book: return "Book"
            case .quote: return "Quote"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .book: return "book.fill"
            case .quote: return "quote.opening"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    private var currentItem: DailyContent? {
        store.item(for: selectedDate)
    }

    var body: some View {
        TabView(selection: $contentTab) {
            contentView(for: .book)
                .tabItem {
                    Label(ContentTab.book.title, systemImage: ContentTab.book.icon)
                }
                .tag(ContentTab.book)
            
            contentView(for: .quote)
                .tabItem {
                    Label(ContentTab.quote.title, systemImage: ContentTab.quote.icon)
                }
                .tag(ContentTab.quote)
            
            SettingsView()
                .tabItem {
                    Label(ContentTab.settings.title, systemImage: ContentTab.settings.icon)
                }
                .tag(ContentTab.settings)
        }
        .onAppear {
            if selectedDate.isEmpty {
                selectedDate = store.today?.date ?? ""
            }
        }
        .onChange(of: store.items.count) { _ in
            if selectedDate.isEmpty {
                selectedDate = store.today?.date ?? ""
            }
        }
        .onChange(of: selectedDate) { _ in
            if contentTab != .settings {
                contentTab = .book // Reset to book tab when date changes (unless on settings)
            }
        }
    }
    
    @ViewBuilder
    private func contentView(for tab: ContentTab) -> some View {
        NavigationStack {
            ZStack {
                if store.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let item = currentItem {
                    // Standard layout for content tabs
                    VStack(spacing: 0) {
                        // Date header
                        HStack {
                            Text(formattedDate(selectedDate))
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        // Calendar strip
                        CalendarStripView(selectedDate: $selectedDate)
                        
                        // Content based on selected tab
                        switch tab {
                        case .book:
                            BookPageView(item: item)
                        case .quote:
                            QuotePageView(item: item)
                        case .settings:
                            EmptyView()
                        }
                    }
                    
                    // Tomorrow countdown overlay
                    if store.isTomorrow(item.date) {
                        CountdownOverlayView(targetDate: item.date)
                    }
                } else if !store.isLoading {
                    Text("No content available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formattedDate(_ dateStr: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: dateStr) else { return dateStr }
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: date)
    }
}
