

import UIKit

class NFUserInfoCell: NFTableViewCell {

    class func cellIdentifier() -> String {
        return "NFUserInfoCell"
    }
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblWeather: UILabel!

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
