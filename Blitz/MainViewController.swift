//
//  MainViewController.swift
//  Blitz
//
//  Created by Tianyang Yu on 10/8/15.
//  Copyright © 2015 cs490. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

class MainViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var isRequestSegmentedControl: UISegmentedControl!
    
    // MARK: - Variables
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    var posts: [[String: AnyObject]] = []
    var isRequest: Bool! = true
    var category: String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init LocationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()

        if self.revealViewController() != nil {
            filterButton.target = self.revealViewController()
            filterButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        reloadTableView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        reloadTableView()
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostCell
        
        // Set title
        cell.titleLabel!.text = posts[indexPath.row]["title"] as? String
        
        // Set postTime
        let date_iso8601 = NSDate.date(fromString: posts[indexPath.row]["postTime"]! as! String, format: DateFormat.ISO8601)
        let date_String = date_iso8601?.toString(format: DateFormat.Custom("yyyy-MM-dd HH:mm"))
        cell.timeLabel!.text = date_String
        
        // Set Category Image
        switch posts[indexPath.row]["category"] as! String {
            case "Carpool":
                cell.categoryImage.image = UIImage(named: "carpool")
                break
            case "FoodDiscover":
                cell.categoryImage.image = UIImage(named: "foodDiscover")
                break
            case "House Rental":
                cell.categoryImage.image = UIImage(named: "houseRental")
                break
            case "Other":
                cell.categoryImage.image = UIImage(named: "other")
                break
            default:
                break;
        }
        return cell
    }
    
    
    // MARK: - CORE LOCATION MANAGER -> GET CURRENT LOCATION OF THE USER
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("@\(getFileName(__FILE__)) - \(__FUNCTION__): %@", error)
        
        // Pop up alert
        let alertController = UIAlertController(title: "Blitz", message: "Failed to Get Your Location", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {}
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        locationManager.stopUpdatingLocation()
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray:[CLPlacemark] = placemarks!
            var placemark: CLPlacemark!
            placemark = placeArray[0]
            
            self.location = placemark.location
        })
        
    }
    
    
    //Mark: -Do action when this cell is tapped
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("yourIdentifier", sender: self)
        let showPost = self.storyboard?.instantiateViewControllerWithIdentifier("ShowPostVC") as! ShowPostVC
        let postID = posts[indexPath.row]["_id"] as? String
        showPost.postID = postID!
        
        self.navigationController?.pushViewController(showPost, animated: true)
    }


    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Action Outlet
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch isRequestSegmentedControl.selectedSegmentIndex
        {
        case 0:
            self.isRequest = true
            reloadTableView()
        case 1:
            self.isRequest = false
            reloadTableView()
        default:
            break;
        }
    }
    
    func reloadTableView() {
        //
        var queryJSON: [String: AnyObject] = [
            "operation": "Query",
            "isRequest": self.isRequest,
            "TransactionCompleted": false
        ]
        if category != "" {
            queryJSON["category"] = self.category
        }
        
        posts = getResultFromServerAsJSONArray(queryJSON)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func sortPostsBasedDistance() {
        
        let sourceLocation = self.location
        
//        for post in posts {
        for i in 0...posts.count-1{
            let position = posts[i]["position"] as! [String: AnyObject]
            
            let destLocation = CLLocation(latitude: position["latitude"] as! Double, longitude: position["longitude"] as! Double)
            
            let distance: CLLocationDistance =
            destLocation.distanceFromLocation(sourceLocation)
            
                
            // update the distance to posts
            self.posts[i]["distance"] = distance
        }
        
        posts.sortInPlace { (element1, element2) -> Bool in
            return element1["distance"] as! Double > element2["distance"] as! Double
        }
        
        posts = posts.reverse()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func sortPostsBasedTime() {
        posts.sortInPlace { (element1, element2) -> Bool in
            return element1["postTime"] as! String > element2["postTime"] as! String
        }
        
        posts = posts.reverse()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


