/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit

class LoginViewModel: NSObject {
    
    var fbAuthCallback: ((Bool!)->())!
    
    
    /**
     Method to initialize view model with the appropriate callback
     
     - parameter fbAuthCallback: callback to be executed on completion of trying to authenticate with Facebook
     
     - returns: an instance of this view model
     */
    init(fbAuthCallback: ((Bool!)->())) {
        super.init()
        
        self.fbAuthCallback = fbAuthCallback
        
        
    }
    
    
    /**
     Method to attempt authenticating with Facebook and call the callback if failure, otherwise will continue to object storage container creation
     */
    func authenticateWithFacebook() {
        FacebookDataManager.SharedInstance.authenticateUser({(response: FacebookDataManager.NetworkRequest) in
            if (response == FacebookDataManager.NetworkRequest.Success) {
                print("successfully logged into facebook with keys:")
                if let userID = FacebookDataManager.SharedInstance.fbUniqueUserID {
                    if let userDisplayName = FacebookDataManager.SharedInstance.fbUserDisplayName {
                        print("\(userID)")
                        print("\(userDisplayName)")
                        //save that user has not pressed login later
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasPressedLater")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        //add container once to object storage
                        self.createObjectStorageContainer(userID)
                        
                    }
                }
            }
            else {
                print("failure logging into facebook")
                self.fbAuthCallback(false)

            }
        })
 
    }
    
    
    /**
     Method to attempt creating an object storage container and call callback upon completion (success or failure)
     
     - parameter userID: user id to be used for container creation
     */
    func createObjectStorageContainer(userID: String!) {
        print("Creating object storage container...")
        ObjectStorageDataManager.SharedInstance.objectStorageClient.createContainer(userID, onSuccess: {(name) in
            print("Successfully created object storage container with name \(name)") //success closure
            self.fbAuthCallback(true)
            }, onFailure: {(error) in //failure closure
                print("Facebook auth successful, but error creating Object Storage container: \(error)")
                self.fbAuthCallback(false)
        })
        
    }
    

}
