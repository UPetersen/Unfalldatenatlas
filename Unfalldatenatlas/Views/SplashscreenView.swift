////
////  SplashscreenView.swift
////  Unfalldatenatlas
////
////  Created by Uwe Petersen on 01.11.24.
////
//
//import SwiftUI
//import CoreData
////import Combine
//
//struct SplashscreenView: View {
//    
//    @State var showSplashscreen: Bool = false
//    @State private var progress: Double = 0.0
//    @State private var timer: Timer?
//    let workoutDateRange = Date()...Date().addingTimeInterval(90)
//    
//    // Publisher that fires when persistent store is loaded, this is also when lightweight migration is finished (if migration was done).
//    private var didFinishLoadingStoresPublisher = NotificationCenter.default
//        .publisher(for: NSNotification.Name("didFinishLoadingStores"))
//        .map { notification in
//            return notification
//        }
//       .receive(on: RunLoop.main)
//
//    
//    var body: some View {
//        
//        if showSplashscreen {
//            VStack {
//                Image("LaunchScreenImage")
//                    .resizable()
//                    .scaledToFit()
//    //                .aspectRatio(contentMode: .fit)   // Das Seitenverhältnis beibehalten
//                    .frame(width: 200, height: 200)
//
//                //                ProgressView(timerInterval: workoutDateRange) {
////                    Text("Strukturierung läuft...")
////                }
////                .padding()
////                ProgressView(timerInterval: workoutDateRange) {
////                    Text("Strukturierung läuft...")
////                }
////                .progressViewStyle(.circular)
////                .padding()
//                
////                ProgressView(value: progress, total: 1.0)
////                    .progressViewStyle(LinearProgressViewStyle())
////                    .padding()
//
//                ProgressView()
////                    .progressViewStyle(CircularProgressViewStyle())
////                    .scaleEffect(2.0) // Vergrößert den Spinner
//                    .padding()
//                
//                Text("""
//                Liebe Nutzer, bevor die neuen Daten für 2023 geladen werden, muss die Datenbank einmalig neu strukturiert werden. Damit wird sie ingesamt kleiner und die Zugriffe gehen etwas schneller. 
//                
//                Dieser Vorgang dauert circa 1:30 Minuten (auf einem iPhone 14 Pro Max).
//                """)
//                .multilineTextAlignment(.center)
//                .padding()
//                
//            }
//            .onReceive(didFinishLoadingStoresPublisher) { notification in
//                print("Notification didFinishLoadingStores received.")
//                self.showSplashscreen = false
//            }
//            .onAppear() {
//
//                if PersistenceController.requiresMigration() {
//                    self.showSplashscreen = true
//                }
//
////                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
////                    withAnimation {
////                        self.showSplashscreen = false
////                    }
////                }
//
//                print("--- Migration erforderlich: \(PersistenceController.requiresMigration())")
//                startProgress()
//            }
//            .onDisappear() {
//                timer?.invalidate()
//            }
//        } else {
//            ContentView()
////            createContentView()
//        }
//    }
//    
//    
//    private func startProgress() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
//            DispatchQueue.main.async {
//                if progress < 1.0 {
//                    progress += 1.0 / 60.0
//                } else {
//                    timer?.invalidate()
//                }
//            }
//        }
//    }
////    func createContentView() -> some View {
////        ContentView()
////    }
//}
//
//#Preview {
//    SplashscreenView()
//}
//
