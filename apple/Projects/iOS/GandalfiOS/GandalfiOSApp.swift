import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct GandalfiOSApp: App {
    // Firebase init
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
