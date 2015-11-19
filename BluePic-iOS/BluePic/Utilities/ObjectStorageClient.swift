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
     * Gets authentication token from Object Storage service.
     */
    func getAuthToken(onSuccess: (token: String) -> Void, onFailure: (error: String) -> Void) {
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
                    if let token = headers["X-Subject-Token"] as? String {
                        print("Auth token: \(token)")
                        onSuccess(token: token)
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
    
    //curl -i $publicURL/steven -X PUT -H "Content-Length: 0" -H "X-Auth-Token: $token"
    /**
    * Creates a container on the Object Storage service.
    */
    func createContainer(name: String, token: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        print("Container creation URL: \(nsURL)")
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "PUT"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        
        // Fire off HTTP PUT request
        Alamofire.request(mutableURLRequest).responseJSON {response in
            // Get http response status code
            var statusCode:Int = 0
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
            }
            print("statusCode = \(statusCode)")
            if (statusCode == 201 || statusCode == 202) {
                self.configureContainerForWebHosting(name, token: token, onSuccess: onSuccess, onFailure: onFailure)
                return
            }
            
            var errorMsg = "[No error info available]"
            if let error = response.result.error {
                errorMsg = error.localizedDescription
            }
            onFailure(error: "Could not create container '\(name)': \(errorMsg)")
        }
    }
    
    func configureContainerForWebHosting(name: String, token: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue("true", forHTTPHeaderField: "X-Container-Meta-Web-Listings")
        
        // Fire off HTTP request
        Alamofire.request(mutableURLRequest).responseJSON {response in
            // Get http response status code
            var statusCode:Int = 0
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
            }
            print("statusCode = \(statusCode)")
            if (statusCode == 204) {
                self.configureContainerForPublicAccess(name, token: token, onSuccess: onSuccess, onFailure: onFailure)
                return
            }
            
            var errorMsg = "[No error info available]"
            if let error = response.result.error {
                errorMsg = error.localizedDescription
            }
            onFailure(error: "Could not change configuration for container '\(name)': \(errorMsg)")
        }
        
    }
    
    func configureContainerForPublicAccess(name: String, token: String, onSuccess: () -> Void, onFailure: (error: String) -> Void) {
        let nsURL = NSURL(string: "\(publicURL)/\(name)")!
        let mutableURLRequest = NSMutableURLRequest(URL: nsURL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue(token, forHTTPHeaderField: "X-Auth-Token")
        mutableURLRequest.setValue(".r:*,.rlistings", forHTTPHeaderField: "X-Container-Read")
        
        // Fire off HTTP request
        Alamofire.request(mutableURLRequest).responseJSON {response in
            // Get http response status code
            var statusCode:Int = 0
            if let httpResponse = response.response {
                statusCode = httpResponse.statusCode
            }
            print("statusCode = \(statusCode)")
            if (statusCode == 204) {
                onSuccess()
                return
            }
            
            var errorMsg = "[No error info available]"
            if let error = response.result.error {
                errorMsg = error.localizedDescription
            }
            onFailure(error: "Could not change configuration for container '\(name)': \(errorMsg)")
        }
    }
    
    func uploadFile() {
        
    }
}