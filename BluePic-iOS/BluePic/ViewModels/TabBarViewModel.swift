//
//  TabBarViewModel.swift
//  BluePic
//
//  Created by Alex Buck on 12/7/15.
//  Copyright © 2015 MIL. All rights reserved.
//


//enum AppStartUpResult {
//    case showObjectStorageErrorAlert
//    case hideBackgroundImageAndStartLoading
//    case stopLoadingImageView
//    case showCloudantPushingErrorAlert
//    case showCloudantPullingErrorAlert
//    case presentLoginVC
//}



class TabBarViewModel: NSObject {

    /// Boolean if showLoginScreen() has been called yet this app launch (should only try to show login once)
    var hasTriedToPresentLoginThisAppLaunch = false
    var passDataNotificationToTabBarVCCallback : ((dataManagerNotification : DataManagerNotification)->())!
    
    var feedViewModel : FeedViewModel!
    
    
    init(passDataNotificationToTabBarVCCallback : ((dataManagerNotification: DataManagerNotification)->())){
        super.init()
        
        self.passDataNotificationToTabBarVCCallback = passDataNotificationToTabBarVCCallback
        
        DataManagerCalbackCoordinator.SharedInstance.addCallback(handleDataManagerNotifications)
        
    }
    
    
    
    func tryToShowLogin(){
        
        if(!hasTriedToPresentLoginThisAppLaunch){
           
            hasTriedToPresentLoginThisAppLaunch = true
            
            FacebookDataManager.SharedInstance.tryToShowLoginScreen()
        }
    }
    
    
    
    func handleDataManagerNotifications(dataManagerNotification : DataManagerNotification){
        
       passDataNotificationToTabBarVCCallback(dataManagerNotification: dataManagerNotification)
  
    }
    
    

    /**
     Retry pushing cloudant data upon error
     */
    func retryPushingCloudantData(){
        do {
            try CloudantSyncClient.SharedInstance!.pushToRemoteDatabase()
        } catch {
            print("Retry pushing error: \(error)")
        }
    }
    
    
    /**
     Retry pulling cloudant data upon error
     */
    func retryPullingCloudantData() {
        //CloudantSyncClient.SharedInstance.pullReplicator.stop()
        do {
            try CloudantSyncClient.SharedInstance!.pullFromRemoteDatabase()
        } catch {
            print("Retry pulling error: \(error)")
        }
        dispatch_async(dispatch_get_main_queue()) {
            print("Retrying to pull Cloudant data")
            
            FacebookDataManager.SharedInstance.tryToShowLoginScreen()
            
        }
    }
    
    
    /**
     Retry authenticating with object storage upon error
     */
    func retryAuthenticatingObjectStorage() {
        dispatch_async(dispatch_get_main_queue()) {
            print("Retrying to authenticate with Object Storage")
            
            FacebookDataManager.SharedInstance.tryToShowLoginScreen()
            
        }
        
    }
  
}
