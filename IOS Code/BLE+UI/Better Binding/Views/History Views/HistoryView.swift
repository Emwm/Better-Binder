import SwiftUI
import Foundation
import Charts
import SwiftData

struct HistoryView: View {
    
    enum Tab {
        case weekview
        case yearview
        case monthview
    }
    
    @State private var selectedTab: Tab = .weekview
    
    private func tabButton(_ title: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(selectedTab == tab ? .appBodyBold() : .appBody())
                .foregroundStyle(selectedTab == tab ? .white : .primary)
                .frame(maxWidth: 80)
                .padding(.vertical, 5)
                .background(
                    selectedTab == tab ? Color.colorCoral : Color.colorLightCoral
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var body: some View {
        VStack {
            // Top Header Section ---------------------------------
            HStack{
                Image("logo_solidOutline_coral")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("History") // list view of each bind today
                    .font(.appHeader())
                    .foregroundStyle(Color.colorDarkCoral)
                InfoButton(title: "History Page Help", tint: .colorCoral) {
                    VStack {
                        Text("Page Overview:")
                            .font(.appBodyBold())
                        Text("This page offers three distinct views to track binding habits and wellness. View trends across a week, a month, or a year.")
                            .font(.appBody())
                            .mediumPaddingBottom()
                        
                        TabView{
                            //Tab 1
                            VStack{
                                Text("Week View")
                                    .font(.appBodyBold())
                                Text("On this page see:")
                                    .font(.appBody())
                                    .smallPaddingBottom()
                                // manual list
                                VStack(alignment: .leading) {
                                    Label("Total binding time for each day of the week, tap on the arrows to see a different week", systemImage: "1.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                    Label("How close you've been to your limit every day", systemImage: "2.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                    Label("All of the binding sessions and this dates from the past week", systemImage: "3.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                }
                                .font(.appSmallCaption())
                                .mediumPaddingBottom()
                                
                                Spacer()
                            }
                            //Tab 2
                            VStack{
                                Text("Month View")
                                    .font(.appBodyBold())
                                Text("On this page see:")
                                    .font(.appBody())
                                    .smallPaddingBottom()
                                
                                // manual list
                                VStack(alignment: .leading) {
                                    Label("A table with the past month of binding time and wellness scores, tap the arrows to see past months", systemImage: "1.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                    Label("Highlighted entries indicate days where the set limit has been exceeded", systemImage: "2.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                }
                                .font(.appSmallCaption())
                                .mediumPaddingBottom()
                                
                                Spacer()
                                
                                
                            }
                            //Tab 3
                            VStack{
                                Text("Year View")
                                    .font(.appBodyBold())
                                Text("On this page see:")
                                VStack(alignment: .leading) {
                                    Label("12 Columns representing months and 31 boxes below them representing the days. Tap on the arrows to see previous years", systemImage: "1.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                    Label("Days where you wore a binder have been highlighted, days where your limit was exceeded have been filled", systemImage: "2.circle")
                                        .smallPaddingBottom()
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.leading)
                                    
                                }
                                .font(.appSmallCaption())
                                .mediumPaddingBottom()
                                
                                Spacer()
                                
                            }
                        }
                        //prevents the gross wide bar and makes it look like instagram slides
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: 250)
                    
                    }
                }

                
                
            }
            .padding(.top, 10)
            
            HStack(spacing: 10) {
                tabButton("Week", tab: .weekview)
                tabButton("Month", tab: .monthview)
                tabButton("Year", tab: .yearview)
            }
            .mediumPaddingBottom()
            
            
            
//            Picker("History View", selection: $selectedTab) {
//                Text("Week")
//                    .tag(Tab.weekview)
//                
//                Text("Month")
//                    .tag(Tab.monthview)
//                
//                Text("Year")
//                    .tag(Tab.yearview)
//            }
//            .pickerStyle(.segmented)
//            .font(.appBodyBold())
//            .padding()
//            
            switch selectedTab {
            case .weekview:
                WeekView()
                
            case .monthview:
                MonthView()
                
            case .yearview:
                YearView()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyTotal.self, JournalEntry.self, configurations: config)
    
    HistoryView()
        .environment(BindTimer(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(BindManager())
}
