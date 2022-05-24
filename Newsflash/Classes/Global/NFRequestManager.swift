
import UIKit
import Alamofire
import SwiftyJSON

class NFRequestManager: NSObject {

    static let sharedManager : NFRequestManager = {
        let instance = NFRequestManager()
        return instance
    }()
    
    typealias FeedsResponse = ([NFFeedModel]?, Error?) -> Void
    typealias EntriesResponse = ([NFEntryModel]?, Error?) -> Void
    
    let baseURL: String = "http://104.238.94.135:8080"
    let endpointPrefs: String   = "/prefs"
    let endpointChannel: String = "/feed"
    let endpointEntry: String   = "/entry/all"
    let DarkSkyAPIKey: String = "076713bf3abb0e63fd1e4fe5a818fcb1"
    
    func getCustomerChannels(uuid: String, complete: @escaping FeedsResponse) -> Void {
        let url = fullURLForEndpoint(endpointPrefs)
        let params: [String : AnyObject] = [
            "deviceId" : uuid as AnyObject,
            ]
        getChannels(url: url, params: params, complete: complete)
        
    }
    
    func getChannels(skip: Int?, limit: Int?, complete: @escaping FeedsResponse) -> Void {
        let url = fullURLForEndpoint(endpointChannel)
        getChannels(url: url, params: nil, complete: complete)
    }
    
    func getChannels(url: String, params: [String: AnyObject]?, complete: @escaping FeedsResponse) -> Void {
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let data):
                var result: [NFFeedModel] = []
                if let jsonArray = JSON(data).array {
                    jsonArray.forEach({ (elem: JSON) in
                        result.append(NFFeedModel(data: elem))
                    })
                }
                complete(result, nil)
                break
            case .failure(let error):
                complete(nil, error)
                break
            }
        }
    }
    
    func updateMyChannel(_ uuid: String, deviceToken: String?, channelIds: [Int], complete:((Error?) -> Void)?) -> Void {
        var url = baseURL + endpointPrefs + "?deviceId=\(uuid)"
        if deviceToken != nil {
            url += "&token=\(deviceToken!)"
        }
        let params = ["feedIds" : channelIds]
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                if complete != nil {
                    complete!(nil)
                }
                break
            case .failure(let error):
                if complete != nil {
                    complete!(error)
                }
                break
            }
        }

    }
    
    func getEntry(uuid: String, skip: Int, limit: Int, complete: @escaping EntriesResponse) -> Void {
        let url = fullURLForEndpoint(endpointEntry)
        let params = [
            "deviceId" : uuid,
            "offset" : skip,
            "rows" : limit
        ] as [String : Any]
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let data):
                var result: [NFEntryModel] = []
                if let jsonArray = JSON(data).array {
                    jsonArray.forEach({ (elem: JSON) in
                        result.append(NFEntryModel(data: elem))
                    })
                }
                complete(result, nil)
                break
            case .failure(let error):
                complete(nil, error)
                break
            }
        }

    }
    
    func updateDeviceToken() -> Void {
        
        let appManager = NFAppManager.sharedManager
        if appManager.deviceToken != nil && appManager.isUpdatedDeviceToken != true && appManager.isLoadedSubscribed == true {
            let uuid = appManager.uuid
            
            var subscribedIds: [Int] = []
            appManager.subscribed.forEach { (channel: NFFeedModel) in
                subscribedIds.append(channel.identifier)
            }
            
            updateMyChannel(uuid, deviceToken: appManager.deviceToken, channelIds: subscribedIds) { (error: Error?) in
                if error == nil {
                    appManager.isUpdatedDeviceToken = true
                }
            }
        }
    }

    
    func getWeatherInformation(langtitude: Double, longitude: Double, complete:@escaping ((String?) -> Void)) -> Void {
        let url = "https://api.darksky.net/forecast/\(DarkSkyAPIKey)/\(langtitude),\(longitude)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                let message = jsonData["hourly"]["summary"].stringValue
                complete(message)
                break
            case .failure(_):
                complete(nil)
                break
            }
        }
    }
    
    private func fullURLForEndpoint(_ endpoint: String) -> String {
        let fullURL = baseURL + endpoint
        return fullURL
    }
    
    
    
}
