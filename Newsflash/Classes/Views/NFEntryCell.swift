
import UIKit

class NFEntryCell: NFTableViewCell {

    class func cellIdentifier() -> String {
        return "NFEntryCell"
    }
    
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblEntryTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var entryModel: NFEntryModel! {
        didSet {
            showModel()
        }
    }
    
    func setVisitedColor() -> Void {
        UIView.animate(withDuration: 0.5) { 
            self.contentView.alpha = 0.35
        }
    }
    
    private func showModel() {
        
        let channelName = getChannelName(channelID: entryModel.feedId!)
        self.lblChannelName.text = channelName // + " : " + entryModel.title
        self.lblEntryTitle.text  = entryModel.title //entryModel.entryDescription

        self.lblTime.text = NSDate.timeAgoSimple(forSeconds: entryModel.age / 1000)
        if entryModel.visited {
            self.contentView.alpha = 0.35
        } else {
            self.contentView.alpha = 1.0
        }
    }
    
    private func getChannelName(channelID: Int) -> String {
        var channelName: String!
        NFAppManager.sharedManager.subscribed.forEach { (channel: NFFeedModel) in
            if channel.identifier == channelID {
                channelName = channel.name
                return
            }
        }
        return channelName
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
