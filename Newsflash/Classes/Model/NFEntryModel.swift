

import UIKit
import SwiftyJSON
import RealmSwift

class NFEntryModel: NFObject {

    var identifier: Int!
    var link: String!
    var title: String!
    var entryDescription: String!
    var time: NSDate!
    var feedId: Int?
    var age: Double = 0
    var visited: Bool = false
    
    init(data: JSON) {
        super.init()
        identifier          = data["id"].intValue
        link                = data["link"].stringValue
        title               = data["title"].stringValue
        entryDescription    = data["description"].stringValue
        feedId              = data["feed_id"].int
        let timeInterval: TimeInterval = data["published"].doubleValue
        time                = NSDate(timeIntervalSince1970: timeInterval / 1000.0)
        age                 = data["age"].doubleValue
        visited             = checkedVisited()
    }

    func setVisitied() -> Void {
        if visited == false {
            visited = true
            let realm = try! Realm()
            let result = realm.objects(NFVisitedId.self).filter("id == %d", identifier)
            if result.count == 0 {
                try! realm.write({ 
                    realm.add(NFVisitedId(value: ["id": identifier]))
                })
            }
        }
    }
    
    internal func checkedVisited() -> Bool {
        let realm = try! Realm()
        let result = realm.objects(NFVisitedId.self).filter("id == %d", identifier)
        if result.count == 0 {
            return false
        } else {
            return true
        }
    }
}
