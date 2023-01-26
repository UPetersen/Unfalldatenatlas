//
//  ContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 13.01.23.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocationUI


struct VeganFoodPlace: Identifiable {
  var id = UUID()
  let name: String
  let latitude: Double
  let longitude: Double

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    //        animation: .default)
    //    private var items: FetchedResults<Item>
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @State private var currentLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1091648)
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1091648), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    @FetchRequest(fetchRequest: ViewModel.specialFetchRequest()) private var theAccidents: FetchedResults<Accident>
    

    //    @FetchRequest(sortDescriptors: T##[NSSortDescriptor])
    //    @State private var newYourRegion = MKCoordinateRegion(
    //            center: CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1291648),
    //            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    //        )
    
    
    ///
    var body: some View {
        
        
        ZStack(alignment: .bottom) {
//            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.annotations) { accident in
//                MapAnnotation(coordinate: accident.coordinate) {
//                    Circle().stroke(Color.red, lineWidth: 3)
//                        .frame(width: 15, height: 15)
//                }
//            }
//            .ignoresSafeArea()

            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: theAccidents) { accident in
                MapAnnotation(coordinate: accident.coordinate) {
                    Circle().stroke(Color.red, lineWidth: 3)
                        .frame(width: 15, height: 15)
                }
            }
            .ignoresSafeArea()

            //            LocationButton(.currentLocation) {
            //              // Fetch location with Core Location.
            //                if let currentLocation = CLLocationManager().location?.coordinate {
            //                    print("Current Location is lat = \(currentLocation.latitude.description) und long = \(currentLocation.longitude.description)")
            //                    region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            //                }
            //            }
            
        }
        //        .task {
        //            viewModel.fetchAccidents()
        //            print("-------------Ende .task -------------------------------------------------")
        //        }
        
        //        .onReceive(viewModel.annotations.publisher, perform: {accident in print("something \(accident.objectID)")})
        
        .onAppear() {
//            viewModel.fetchAccidents()
            viewModel.importFromFiles()
            print("Ende .onAppear")
        }
        //        .onChange(of: viewModel.$annotations, perform: {_ in print("another thing")})
        //        .onChange(of: $region, perform: {_ in viewModel.fetchAccidents()})
        //         .onChange(of: $region) { print("Region changed") }
        
        //        NavigationView {
        //            List {
        //                ForEach(items) { item in
        //                    NavigationLink {
        //                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
        //                    } label: {
        //                        Text(item.timestamp!, formatter: itemFormatter)
        //                    }
        //                }
        //                .onDelete(perform: deleteItems)
        //            }
        //            .toolbar {
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    EditButton()
        //                }
        //                ToolbarItem {
        //                    Button(action: addItem) {
        //                        Label("Add Item", systemImage: "plus")
        //                    }
        //                }
        //            }
        //            Text("Select an item")
        //        }
    }
    
    
    
    
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    //
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
