
import UIKit
import SVPullToRefresh
import SwiftLocation
import CoreLocation

enum ForwardViewType {
    case channelVC
    case webVC
    case none
}

struct ReadingEntry {
    var startTime: Date = Date()
    var entry: NFEntryModel!
    var endTime: Date!
}

class NFMainFeedVC: NFViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tblEntries: UITableView!
    
    private var isLoading: Bool = false
    private var isLoadedAll: Bool = false
    private var loadingMessage: String = "Loading..."
    private var weatherSummary: String? = nil
    
    fileprivate var entries: [NFEntryModel] = []
    fileprivate var isLoadingWeather: Bool?
    
    fileprivate var forwardVCType: ForwardViewType = .none
    fileprivate var selectedEntry: ReadingEntry?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateEntries(_:)),
            name: NSNotification.Name(rawValue: Notification_UpdateChannel),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateWeather(_:)),
            name: NSNotification.Name(rawValue: Notification_UpdateWeather),
            object: nil
        )
        
        self.tblEntries.addPullToRefresh { 
            self.refreshEntries()
        }
        self.tblEntries.estimatedRowHeight = 130
        self.tblEntries.rowHeight = UITableViewAutomaticDimension
        
        pullToRefresh()
        updateWeather(self)
        
        (UIApplication.shared.delegate as! AppDelegate).registerForPushNotification()
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.screenLogGoogleAnalystics(key: kGAIScreenName, value: "Main Feed")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if forwardVCType == .webVC {
            self.selectedEntry!.endTime = Date()
            let params = getReadEntryEventBuilder(withEntry: self.selectedEntry!)
            eventLogGoogleAnalystics(eventData: params)
        }
    }
    
    func updateWeather(_ sender: Any) -> Void {
        if appManager().getAllowUserLocation() {
            //            weatherSummary = "loading weather information..."
            isLoadingWeather = true
            getUserLocation()
        } else {
            weatherSummary = nil
            isLoadingWeather = nil
        }
    }
    
    // MARK: - Get weather
    fileprivate func getUserLocation() {
        Location.allowsBackgroundEvents = false
        let request = Location.getLocation(withAccuracy: .city, onSuccess: { (location: CLLocation) in
            let coordinate = location.coordinate
            print("Currnet location : \(coordinate.latitude),\(coordinate.longitude)")
            self.getWeatherInformation(coordinate: coordinate)
        }, onError: { (location: CLLocation?, error: LocationError) in
            if location != nil {
                let coordinate = location!.coordinate
                self.getWeatherInformation(coordinate: coordinate)
                print("Currnet location : \(coordinate.latitude),\(coordinate.longitude)")
            }
            print(error.localizedDescription)
        })
        request.start()
    }
    
    fileprivate func getWeatherInformation(coordinate: CLLocationCoordinate2D) -> Void {
        
//        self.tblEntries.reloadData()
        requestManager().getWeatherInformation(langtitude: coordinate.latitude, longitude: coordinate.longitude) { message in
            if message == nil {
                self.weatherSummary = ""
            } else {
                self.weatherSummary = message!
            }
            self.isLoadingWeather = false
            self.tblEntries.reloadData()
        }
    }
    
    // MARK: - Load entries
    func updateEntries(_ sender: AnyObject) -> Void {
        
        pullToRefresh()
    }
    
    private func pullToRefresh() {
        self.tblEntries.triggerPullToRefresh()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func refreshEntries() -> Void {
//        loadingMessage = "Updating entries..."
        entries.removeAll()
        isLoadedAll = false
        loadEntry()
        self.tblEntries.reloadData()
        
    }
    
    func loadEntry(skip: Int = 0) -> Void {
        if isLoading == false {
            isLoading = true
            print("*****     Start loading from \(skip)     *********")
            let uuid = appManager().uuid
            requestManager().getEntry(uuid: uuid, skip: skip, limit: 20, complete: { (result: [NFEntryModel]?, error: Error?) in
                self.isLoading = false
                if error == nil {
                    if result!.count < 20 {
                        self.isLoadedAll = true
                    }
                    self.entries.append(contentsOf: result!)
                }
                self.tblEntries.pullToRefreshView.stopAnimating()
                self.tblEntries.reloadData()
                print("=====     Loaded from : \(skip)     ==========")
            })
        }
    }
    
    // MARK: - UITableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let entryCount = entries.count
        if isLoading || isLoadedAll == false {
            return entryCount + 2
        } else if isLoadedAll == true && entryCount == 0 {
            return 2
        } else {
            return entryCount + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= entries.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NFLoadingCell.cellIdentifier()) as! NFLoadingCell
            if isLoading == false && isLoadedAll == false {
                cell.lblTitle.text = loadingMessage
                
                loadEntry(skip: entries.count)
            } else if isLoadedAll == true && entries.count == 0 {
                cell.lblTitle.text = "Tap to find more channels"
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cellIdentifier = NFUserInfoCell.cellIdentifier()
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NFUserInfoCell
                if isLoadingWeather == nil {
                    cell.lblWeather.text = nil
                } else {
                    cell.lblWeather.text = weatherSummary
                    if isLoadingWeather! == true {
                        cell.lblWeather.textColor = UIColor.lightGray
                    } else {
                        cell.lblWeather.textColor = UIColor.black
                    }
                }
                cell.txtUsername.text = getUsername()
                cell.txtUsername.delegate = self
                return cell
            } else {
                let cellIdentifier = NFEntryCell.cellIdentifier()
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NFEntryCell
                cell.entryModel = entries[indexPath.row - 1]
                return cell
            }
        }
    }
    
    // MARK: delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= (entries.count + 1) {
            if isLoadedAll == true && entries.count == 0 {
                self.performSegue(withIdentifier: "gotoAddChannelVC", sender: self)
            }
        } else if 0 < indexPath.row && indexPath.row <= entries.count {
            let entry = entries[indexPath.row - 1]
            print (entry.link)
            if let url = URL(string: entry.link) {
                if let webVC = NFWebVC(url: url) {
                    self.navigationController?.pushViewController(webVC, animated: true)
                    self.forwardVCType = .webVC
                    self.selectedEntry = ReadingEntry()
                    self.selectedEntry!.entry = entry
                    
                }
                entry.setVisitied()
                let cell = tableView.cellForRow(at: indexPath) as! NFEntryCell
                cell.setVisitedColor()
                
            } else {
                self.showSimpleAlert("No link", message: "You can't open browser because this entry has no link.", closeButton: "Close", completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITextfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.characters.count > 0 {
            textField.resignFirstResponder()
            return true
        } else {
            return false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text!.characters.count > 0 {
            setUsername(textField.text!)
        }
        textField.text = getUsername()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 12 // Bool
    }
    
    fileprivate func getUsername() -> String {
        if let username = appManager().getUsername() {
            return username + "."
        } else {
            return ""
        }
    }
    
    fileprivate func setUsername(_ username: String) {
        let index = username.index(username.endIndex, offsetBy: -1)
        var finalUsername: String!
        if username.substring(from: index) == "." {
            finalUsername = username.substring(to: index)
        } else {
            finalUsername = username
        }
        appManager().setUsername(finalUsername)
    }
    
    fileprivate func getReadEntryEventBuilder(withEntry entry: ReadingEntry) -> [NSObject : AnyObject] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let duration = entry.endTime.timeIntervalSince1970 - entry.startTime.timeIntervalSince1970;
        let durationString = dateFormatter.string(from: entry.startTime) + " => " + getTimeDurationString(totalSeconds: duration)
        
        var channelName = "Unknow channel"
        for channel in appManager().allChannel {
            if channel.identifier == entry.entry.feedId {
                channelName = channel.name
                break
            }
        }
        
        let builder = GAIDictionaryBuilder.createEvent(withCategory: channelName, action: entry.entry.link, label: durationString, value: nil)
        return builder!.build() as [NSObject : AnyObject]

    }

}

