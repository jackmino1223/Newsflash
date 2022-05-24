
import UIKit

class NFChannelCell: NFTableViewCell {

    class func cellIdentifier() -> String {
        return "NFChannelCell"
    }
    
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckMark: UIButton!
    
    var channel: NFFeedModel! {
        didSet {
            showChannelInfo()
        }
    }
    var delegate: NFChannelCellDelegate?
    
    @IBAction func onPressCheck(sender: AnyObject) {
        self.btnCheckMark.isSelected = !self.btnCheckMark.isSelected
        delegate?.selectedChannelWithCell(self)
    }

    func showChannelInfo() -> Void {
        self.lblChannelName.text = channel.name
        self.lblDescription.text = channel.title
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol NFChannelCellDelegate {
    func selectedChannelWithCell(_ cell : NFChannelCell) -> Void
}
