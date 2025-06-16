import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false

    var body: some View {
        TabView {
            NavigationStack {
                LogView()
                    .navigationTitle("Nutrition Log")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingCamera = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                            }
                        }
                    }
            }
            .tabItem { Label("Log", systemImage: "list.bullet.clipboard") }

            NavigationStack {
                StatsView()
                    .navigationTitle("Statistics")
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
    }
}
