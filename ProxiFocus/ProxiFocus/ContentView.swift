import SwiftUI

// Define the struct for the endpoint
struct Endpoint: Identifiable, Codable {
    let id: UUID
    var url: String
    var enabled: Bool
    
    init(id: UUID = UUID(), url: String, enabled: Bool = true) {
        self.id = id
        self.url = url
        self.enabled = enabled
    }
}

class DataManager: ObservableObject {
    @Published var endpoints: [Endpoint] = [] {
        didSet {
            saveEndpoints()
        }
    }
    
    private let endpointsKey = "endpoints_key"
    
    init() {
        loadEndpoints()
    }
    
    // Save endpoints to UserDefaults
    func saveEndpoints() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(endpoints)
            UserDefaults.standard.set(data, forKey: endpointsKey)
        } catch {
            print("Error encoding endpoints: \(error)")
        }
    }
    
    // Load endpoints from UserDefaults
    func loadEndpoints() {
        if let data = UserDefaults.standard.data(forKey: endpointsKey) {
            do {
                let decoder = JSONDecoder()
                let decodedEndpoints = try decoder.decode([Endpoint].self, from: data)
                self.endpoints = decodedEndpoints
            } catch {
                print("Error decoding endpoints: \(error)")
            }
        }
    }
    
    // Add a new endpoint
    func addEndpoint(url: String) {
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty, let _ = URL(string: trimmedURL) else {
            // Optionally, add error handling here
            return
        }
        let newEndpoint = Endpoint(url: trimmedURL)
        endpoints.append(newEndpoint)
    }
    
    // Toggle the enabled/disabled state of an endpoint
    func toggleEndpoint(endpoint: Endpoint) {
        if let index = endpoints.firstIndex(where: { $0.id == endpoint.id }) {
            endpoints[index].enabled.toggle()
        }
    }
    
    // Remove an endpoint
    func removeEndpoint(endpoint: Endpoint) {
        if let index = endpoints.firstIndex(where: { $0.id == endpoint.id }) {
            endpoints.remove(at: index)
        }
    }
}

struct ContentView: View {
    // Use DataManager as an ObservableObject
    @StateObject private var dataManager = DataManager()
    
    // State variable for the new URL input
    @State private var newURL: String = ""
    
    var body: some View {
        VStack {
            // Text field to add a new endpoint
            HStack {
                TextField("Enter a URL", text: $newURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button(action: {
                    dataManager.addEndpoint(url: newURL)
                }) {
                    Text("Add")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            
            // Conditionally show the List or the "No endpoints" message
            if dataManager.endpoints.isEmpty {
                Spacer()
                Text("No endpoints")
                    .foregroundColor(.gray)
                    .italic()
                Spacer()
            } else {
                List {
                    ForEach(dataManager.endpoints) { endpoint in
                        HStack {
                            Text(endpoint.url)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundColor(endpoint.enabled ? .primary : .gray)
                            
                            Spacer()
                            
                            Button(action: {
                                dataManager.toggleEndpoint(endpoint: endpoint)
                            }) {
                                Text(endpoint.enabled ? "Disable" : "Enable")
                                    .foregroundColor(endpoint.enabled ? .red : .green)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button(action: {
                                dataManager.removeEndpoint(endpoint: endpoint)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                        .background(endpoint.enabled ? Color.clear : Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
