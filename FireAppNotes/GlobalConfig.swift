import Foundation
import AppTrackingTransparency
import AdSupport

class GlobalConfig {
    
    static let afApiKey = "ZL77a6qYdBF22Qc6qxMxQG"
    
    static let applicationIdentifier = "6749571289"
    
    static var appOriginSource = "fireappnotee_iosapp"
    
    static let deviceId = retrieveDeviceUUID()
    
    static let adsURL = "https://afireappnotes.com/banner/"
    
    static let oneSignalPushServiceId = "0fb1e908-c37b-4b82-82f4-ef2c94e7d250"
    
    static private func retrieveDeviceUUID() -> String? {
        
        var idfa: String = "";
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    
                    print("Authorized")
                    
                    idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    
                case .denied: print("denied")
                case .notDetermined: print("not determined")
                case .restricted: print("restricted")
                @unknown default: print("unknown")
                }
            }
        } else {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return nil
            }
            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return idfa
    }
    
}

extension Notification.Name {
    static let pushArrived = Notification.Name("PushArrived")
}
