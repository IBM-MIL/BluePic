//
//  ObjectStorageClient.swift
//  BluePic
//
//  Created by Ricardo Olivieri on 11/17/15.
//  Copyright © 2015 MIL. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

/**
 * Convenience class for querying the Object Storage service on Bluemix.
 */
class ObjectStorageClient {
    
    /**
     * Instance variables for this class.
     */
    var userId:String  // The userid associated with the Object Storage account.
    var password:String // The password for the userid.
    var projectId:String
    var authURL:String // The authentication URL; this is the URL that returns the auth token
    var publicURL:String   // The endpoint that shall be used for all query and update operations.
    var token:String?
    
    /**
     * Constructor for the class.
     */
    init(userId: String, password: String, projectId: String, authURL: String, publicURL: String) {
        self.userId = userId
        self.password = password
        self.authURL = authURL
        self.publicURL = publicURL
        self.projectId = projectId
    }
    
    /**
     * Gets authentication token from Object Storage service and stores it as an instance variable.
     */
    func authenticate(onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        // Define NSURL and HTTP request type
        let nsURL = NSURL(string: authURL)!
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let jsonPayload = "{ \"auth\": { \"identity\": { \"methods\": [ \"password\" ], \"password\": { \"user\": { \"id\": \"\(userId)\", \"password\": \"\(password)\" } } }, \"scope\": { \"project\": { \"id\": \"\(projectId)\" } } } }"
        
        print("jsonPayload = \(jsonPayload)")
        mutableURLRequest.HTTPBody = jsonPayload.dataUsingEncoding(NSUTF8StringEncoding)
        //mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonPayload, options: NSJSONWritingOptions())
        
        // Fire off HTTP POST request
        Alamofire.request(mutableURLRequest).responseJSON {response in
            // Get http response status code
            var statusCode:Int = 0
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
            }
            print("statusCode = \(statusCode)")
            
            if (statusCode == 201) {
                if let httpResponse = response.response {
                    let headers = httpResponse.allHeaderFields
                    if let authToken = headers["X-Subject-Token"] as? String {
                        self.token = authToken
                        print("Auth token: \(authToken)")
                        onSuccess()
                        return
                    }
                }
            }
            
            // Getting authorization token failed...
            var errorMsg = "[No error info available]"
            if let error = response.result.error {
                errorMsg = error.localizedDescription
            }
            
            onFailure(error: "Could not get authentication token from Object Storage server: \(errorMsg)")
        }
    }
    
    /**
     * Creates a container on the Object Storage service.
     */
    func createContainer(name: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        print("Container creation URL: \(nsURL)")
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        self.executeCall(mutableURLRequest, successCodes: [201, 202],
            onSuccess: { (headers) in
                self.configureContainerForWebHosting(name, onSuccess: onSuccess, onFailure: onFailure)
            },
            onFailure: { (errorMsg) in
                onFailure(error: "Could not create container '\(name)': \(errorMsg)")
        })
    }
    
    func configureContainerForWebHosting(name: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue("true", forHTTPHeaderField: "X-Container-Meta-Web-Listings")
        self.executeCall(mutableURLRequest, successCodes: [204],
            onSuccess: { (headers) in
                self.configureContainerForPublicAccess(name, onSuccess: onSuccess, onFailure: onFailure)
            },
            onFailure: { (errorMsg) in
                onFailure(error: "Could not update configuration for container '\(name)': \(errorMsg)")
        })
    }
    
    func configureContainerForPublicAccess(name: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue(".r:*,.rlistings", forHTTPHeaderField: "X-Container-Read")
        self.executeCall(mutableURLRequest, successCodes: [204],
            onSuccess: { (headers) in
                onSuccess()
            },
            onFailure: { (errorMsg) in
                onFailure(error: "Could not update configuration for container '\(name)': \(errorMsg)")
        })
    }
    
    func executeCall(mutableURLRequest: NSMutableURLRequest, successCodes: [Int], onSuccess: (headers: [NSObject : AnyObject]?) -> Void, onFailure: (error: String) -> Void) {
        // Fire off HTTP request
        Alamofire.request(mutableURLRequest).responseJSON {response in
            // Get http response status code
            var statusCode:Int = 0
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
            }
            
            print("statusCode = \(statusCode)")
            
            let statusCodeIndex = successCodes.indexOf(statusCode)
            if (statusCodeIndex != nil) {
                var headers:[NSObject : AnyObject]? = nil
                if let httpResponse = response.response {
                    headers = httpResponse.allHeaderFields
                }
                onSuccess(headers: headers)
                return
            }
            
            // If we are here, then something went wrong
            var errorMsg = "[No error info available]"
            if let error = response.result.error {
                errorMsg = error.localizedDescription
            }
            onFailure(error: errorMsg)
        }
    }
    
    /*
    curl -i ***REMOVED***/olivieri/helloworld.txt -X PUT -H "Content-Length: 1" -H "Content-Type: text/html; charset=UTF-8" -H "X-Auth-Token: gAAAAABWTT6dUSYHOTnRjHverEK5yZfcfs3aNUBudgRQ8YtffaIMMrFE_PlzvKEAkKVhGLyI10CDQ-51Ogj-YuCKCwx3HTl_WIDwsRTozbiWXCrfdG8Drm9Tc7k9YGxHbwW9_Ax5M28okL63WfoL8p9Mq-arG34PScxanNweCL-fu4WVXR6DS9Q%3D"
    */
    
    /*
    func uploadImage(containerName: String, imageName: String, image: NSData) {
    
    let nsURL = NSURL(string: "\(publicURL)/\(containerName)/\(imageName)")!
    let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
    mutableURLRequest.HTTPMethod = "PUT"
    mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
    mutableURLRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
    
    
    
    //var image = UIImage(named : "logo.png")
    //var imageData = UIImagePNGRepresentation(image!)
    
    /*
    
    
    
    ar request = NSMutableURLRequest(URL: NSURL(string:"http:www.example.com/uploadpic")!)
          var session = NSURLSession.sharedSession()
      request.HTTPMethod = "POST"
    var boundary = NSString(format: "---------------------------14737809831466499882746641449")
          var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
                request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
                var body = NSMutableData.alloc()
    body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(NSString(format:"Content-Disposition: form-data; name=\"profile_photo\"; filename=\"img.jpg\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)     body.appendData(imageData)
    body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
    
    request.HTTPBody = body
    var returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
    println("returnString \(returnString)")*/
    
    }
    */
}