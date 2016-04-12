//
//  ViewController.swift
//  Downloading Images Directory Core Data
//
//  Created by Ben Wong on 2016-04-11.
//  Copyright © 2016 Ben Wong. All rights reserved.
//

import UIKit

func getDocumentsURL() -> NSURL {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
    return fileURL.path!
    
}


func saveImage (image: UIImage, path: String ) -> Bool{
    
    let pngImageData = UIImagePNGRepresentation(image)
    //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
    let result = pngImageData!.writeToFile(path, atomically: true)
    
    return result
    
}


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    let reuseIdentifier = "cell"
    
    var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6cd8800d04b7e3edca0524f5b429042e&lat=51.03&lon=-114.14&extras=url_s&per_page=20&format=json&nojsoncallback=1")! ;
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url){(data, response, error) -> Void in
            if let data = data {
                //                print(urlContent)
                
                do {
                    let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if jsonResult.count > 0 {
                        if let items = jsonResult["photos"] as? NSDictionary {
                            
                            if let photoItems = items["photo"] as? NSArray {
                                
                                for item in photoItems {
                                    
                                    if let imageURL = item["url_s"] as? String {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            
                                            print(imageURL)
                                            self.items.append(imageURL)
                                            self.collectionView.reloadData()
                                            
                                            //take each imageURL and download them
                                            
                                            let url = NSURL(string: imageURL)
                                            
                                            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (imageData, response, error) -> Void in
                                                if error != nil {
                                                    print(error)
                                                } else {
                                                    
                                                    var documentsDirectory: String?
                                                    
                                                    var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                                    
                                                    if paths.count > 0 {
                                                    
                                                        documentsDirectory = paths[0] as? String
                                                        
                                                        let savePath = documentsDirectory! + "/\(imageURL).jpg"
                                                        print(savePath)
                                                        
                                                        NSFileManager.defaultManager().createFileAtPath(savePath, contents: imageData, attributes: nil)
                                                    }
                                                }
                                            }
                                            task.resume()
                                        })
                                    }
                                }
                            }
                        }
                    }
                    
                    //
                    //                    print(jsonResult)
                    //
                } catch {
                    print("JSON Serialization failed")
                }
            }
            
        }
        
        task.resume()
        
        
                // We need just to get the documents folder url
                let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
                // now lets get the directory contents (including folders)
                do {
                    let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
                    print(directoryContents)
        
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
        
    }
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        
        cell.backgroundColor = UIColor.yellowColor() // make cell more visible in our example project
        
        if items.count > 0 {
            if let url  = NSURL(string: self.items[indexPath.item] ),
                data = NSData(contentsOfURL: url)
            {
                cell.myImageView.image = UIImage(data: data)
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.mainScreen().scale
            }
        }
        
        
        
        //
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(self.items[indexPath.item])!")
    }
    
    
    
}

