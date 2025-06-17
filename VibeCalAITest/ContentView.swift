import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var showingAdd = false
    
    var body: some View {
        //        TabView {
            
        NavigationStack {
            LogView(showingAdd: $showingAdd)
                .navigationTitle("Nutrition Log")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingCamera = true
                        } label: {
                            Image(systemName: "camera.fill")
                        }
                    }
                }
        }
        //            .tabItem { Label("Log", systemImage: "list.bullet.clipboard") }
        
        //        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
        .sheet(isPresented: $showingAdd) {
            AddManualEntryView()
        }
    }
}
