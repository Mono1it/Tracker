import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "e39edb48-f91d-4b95-8542-75e980b03112") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, screen: String, item : String? = nil) {
        var params: [String: String] = [
            "event": event,
            "screen": screen
        ]
        if let item { params["item"] = item }
        print("Metrica send params: \(params)")
        AppMetrica.reportEvent(name: "event", parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
