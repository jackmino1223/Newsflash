
import UIKit
import SwiftyJSON

class NFFeedModel: NFObject {

    var identifier: Int!
    var name: String!
    var url: String!
    var title: String!
    var featured: Bool = false
    
    init(data: JSON) {
        super.init()
        identifier  = data["id"].intValue
        name        = data["name"].stringValue
        url         = data["url"].stringValue
        title       = data["description"].stringValue
        if let _featured = data["featured"].bool {
            featured = _featured
        }
    }
}
