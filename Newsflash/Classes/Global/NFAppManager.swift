
import UIKit

class NFAppManager: NSObject {

    static let sharedManager : NFAppManager = {
        let instance = NFAppManager()
        return instance
    }()

    var subscribed: [NFFeedModel] = []
    var allChannel: [NFFeedModel] = []
    var deviceToken: String?
    var uuid: String = "uuid"
    var isUpdatedDeviceToken = false
    var isLoadedSubscribed = false
    
    
    let UserDefaultKey_Username = "Username"
    let UserDefaultKey_AllowLocation = "AllowUserLocation"
    
    func setUsername(_ username: String) -> Void {
        UserDefaults.standard.set(username, forKey: UserDefaultKey_Username)
        UserDefaults.standard.synchronize()
    }
    
    func getUsername() -> String? {
        let username = UserDefaults.standard.string(forKey: UserDefaultKey_Username)
        return username
    }
    
    func setAllowUserLocation(_ allow: Bool) -> Void {
        UserDefaults.standard.set(allow, forKey: UserDefaultKey_AllowLocation)
        UserDefaults.standard.synchronize()
    }
    
    func getAllowUserLocation() -> Bool {
        let allow = UserDefaults.standard.bool(forKey: UserDefaultKey_AllowLocation)
        return allow
    }
}

let Notification_UpdateChannel = "com.newsflash.update.channel"
let Notification_UpdateWeather = "com.newsflash.update.weather"
