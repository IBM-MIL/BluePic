//
//  ViewController.swift
//  BluePic
//
//  Created by Nathan Hekman on 11/16/15.
//  Copyright © 2015 MIL. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test to prove Alamofire is working
        Alamofire.request(.GET, "https://httpbin.org/get")

        //Test code to see if CDTDatastore works
        do {
            let fileManager = NSFileManager.defaultManager()
            
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask).last!
            
            let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
            let path = storeURL.path
            
            let manager = try CDTDatastoreManager(directory: path)
            let datastore = try manager.datastoreNamed("my_datastore")
            
            // Create a document
            let rev = CDTDocumentRevision(docId: "doc1")
        } catch {
            print("Encountered an error: \(error)")
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        FacebookDataManager.authenticateUser({(response: FacebookDataManager.NetworkRequest) in
            if (response == FacebookDataManager.NetworkRequest.Success) {
                print("success")
            }
            else {
                print("failure")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

