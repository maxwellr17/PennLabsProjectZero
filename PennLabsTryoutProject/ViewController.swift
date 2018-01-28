//
//  ViewController.swift
//  PennLabsTryoutProject
//
//  Created by Maxwell Roling on 1/27/18.
//  Copyright © 2018 Maxwell Roling. All rights reserved.
//


//PLEASE NOTE: I TRIED TO CHALLENGE MYSELF BY NOT USING A STORYBOARD, SO THE UI IS NOT AS GOOD AS IT COULD HAVE BEEN

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    var parsedData:[Venue] = []
    var tableView = UITableView()
    var webview :UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "http://api.pennlabs.org/dining/venues"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        //make request
        let session = URLSession.shared.dataTask(with: url!){ data, response, error in
            if (error != nil) {
                print("error occured in retrieving JSON data")
                let errorAlert = UIAlertController(title: "Error", message: "An error occured loading the data. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            //parse data
            let p = Parser()
            self.parsedData = p.parseData(data: data!)
            
            //reload table in main thread once everything is parsed
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        session.resume()
        
        //set up table view
        let screenDim = self.view.bounds
        tableView.frame = CGRect(x: 0, y: 0, width: screenDim.width, height: screenDim.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = 120
        self.view.addSubview(tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parsedData.count
    }
    
    //set up cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.parsedData[indexPath.row].name! + "\n"
            + self.parsedData[indexPath.row].hours!
        
        if let image : UIImage = UIImage(named:self.parsedData[indexPath.row].name!) {
            
            let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 150, height: 120))
            cell.imageView?.image = resizedImage
        }
        else {
            cell.imageView?.image = self.resizeImage(image: UIImage(named: "quad")!, targetSize: CGSize(width: 150, height: 120))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //setup and load webpage with details
        let url = self.parsedData[indexPath.row].url!
        let URL_obj = URL(string: url)
        webview = UIWebView(frame: self.view.frame)
        webview?.delegate = self
        webview?.loadRequest(URLRequest(url: URL_obj!))
        self.view.addSubview(webview!)
        
        
        //setup swipe recognizer so user can go back to main screen after clicking on a venue by swiping to the left
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack(recognizer:)))
        swipe.direction = .right
        webview?.addGestureRecognizer(swipe)
        
    }
    
    @objc func goBack(recognizer: UISwipeGestureRecognizer) {
        webview?.removeFromSuperview()
    }
    
    //Handle error if webview doesn't load properly
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let errorAlert = UIAlertController(title: "Error", message: "An error occured loading the website.", preferredStyle: UIAlertControllerStyle.alert)
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    // resize image method from
    //https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

