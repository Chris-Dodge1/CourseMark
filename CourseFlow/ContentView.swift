import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CoursesView()
                .tabItem {
                    Label("Courses", systemImage: "book")
                }

            AssignmentsView()
                .tabItem {
                    Label("Assignments", systemImage: "checklist")
                }

            StudyPlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
}
