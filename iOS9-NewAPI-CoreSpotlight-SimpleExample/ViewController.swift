//
//  ViewController.swift
//  iOS9-NewAPI-CoreSpotlight-SimpleExample
//
//  Created by Wlad Dicario on 13/09/2015.
//  Copyright © 2015 Sweefties. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

/*
    Item Type Object
*/
struct Item {
    var title: String
    var category: String
    var date: NSDate
    var thumbnail: String
}

/*
    ViewController Class
*/
class ViewController: UIViewController {

    // MARK: - Interface
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let cellID: String = "defaultCell"
    var searchableItems: [CSSearchableItem] = []
    let domID: String = "apple-news"
    
    var objects = [
        Item(title: "iPhone 6S",
            category: "iOS",
            date: NSDate(),
            thumbnail: "http://specials-images.forbesimg.com/imageserve/55f0e8a1e4b0ffa7afe47e3d/0x600.jpg?fit=scale&background=000000"),
        Item(title: "iPhone 6S Plus",
            category: "iOS",
            date: NSDate(timeIntervalSinceNow: 3600 * 0.5),
            thumbnail: "http://cdn2.gsmarena.com/vv/pics/apple/apple-iphone-6s-plus-00.jpg"),
        Item(title: "Apple Watch",
            category: "WatchOS",
            date: NSDate(timeIntervalSinceNow: 3600 * 1.5),
            thumbnail: "http://blogs-images.forbes.com/kristintablang/files/2015/09/Apple-Watch-Hermes-Double-Tour.png"),
        Item(title: "Apple Tv",
            category: "tvOS",
            date: NSDate(timeIntervalSinceNow: 3600 * 2.0),
            thumbnail: "http://blogs-images.forbes.com/ianmorris/files/2015/09/apple-tv.jpg"),
        Item(title: "iPad Pro",
            category: "iOS",
            date: NSDate(timeIntervalSinceNow: 3600 * 2.5),
            thumbnail: "http://cdn2.gsmarena.com/vv/pics/apple/apple-ipad-pro-01.jpg"),
        Item(title: "Apple Music",
            category: "iOS, OSX",
            date: NSDate(timeIntervalSinceNow: 3600 * 3.5),
            thumbnail: "http://iphonesoft.fr/images/_062015/apple-music.jpg"),
        Item(title: "Beats 1",
            category: "iOS, OSX",
            date: NSDate(timeIntervalSinceNow: 3600 * 4.0),
            thumbnail: "http://factmag-images.s3.amazonaws.com/wp-content/uploads/2015/06/beats-1-250615-616x440.jpg")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchableObjects()
        
        self.title = "CoreSpotlight"
        tableView.rowHeight = 100.0
        tableView.estimatedRowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - SearchAPI -> ViewController Extension
typealias SearchAPI = ViewController
extension SearchAPI {
    
    /// CoreSpotlight Services : searchable objects
    func setSearchableObjects() {
        
        // append searchable Items to Indexed
        for item in objects {
            // define Item Attribute Set
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributeSet.title = item.title
            
            // date formatter
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
            
            attributeSet.contentDescription = item.category + " - " + dateFormatter.stringFromDate(item.date)
            attributeSet.contentCreationDate = dateFormatter.dateFromString("\(item.date)")
            
            // in this example we put optionnals images on Spotlight results
            if let url = NSURL(string: item.thumbnail) {
                if let data = NSData(contentsOfURL: url){
                    attributeSet.thumbnailData = data
                }
            }
            // define search keywords
            var keywords = item.title.componentsSeparatedByString(" ")
            keywords.append(item.category)
            attributeSet.keywords = keywords
            
            // create searchable item
            let searchItem = CSSearchableItem(uniqueIdentifier: item.title, domainIdentifier: domID, attributeSet: attributeSet)
            searchableItems.append(searchItem)
            
        }
        // On-device Index
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }else{
                print("items indexed witch success!")
            }
        }
        self.tableView.reloadData()
    }
    
}


//MARK: - TableViewDataSource -> ViewController Extension
typealias TableViewDataSource = ViewController
extension TableViewDataSource : UITableViewDataSource {
    
    /// sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count ?? 0
    }
    
    /// cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        // configure cell
        let result = objects[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.category
        if cell.imageView?.image == nil, let imgURL = result.thumbnail as String? {
            cell.imageView?.image = UIImage()
            getImageForCell(imgURL, cellForRowAtIndexPath: indexPath)
        }
        return cell
    }
    
    /// get image for cell
    func getImageForCell(urlString: String, cellForRowAtIndexPath indexPath: NSIndexPath) {
        var image: UIImage?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: NSURL(string: urlString)!) {
                image = UIImage(data: data)
                
                dispatch_async(dispatch_get_main_queue()) {
                    let cell = self.tableView.dequeueReusableCellWithIdentifier(self.cellID, forIndexPath: indexPath)
                    cell.imageView?.image = image?.circleMask
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
    }
    
}


//MARK: - TableViewDelegate -> ViewController Extension
typealias TableViewDelegate = ViewController
extension TableViewDelegate : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
}


//MARK: - UIImage Extension
extension UIImage {
    
    /// Layer circle Mask
    var circleMask: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 5
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}