/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/




class TabBarViewModel: NSObject {

    /// Boolean if showLoginScreen() has been called yet this app launch (should only try to show login once)
    var hasTriedToPresentLoginThisAppLaunch = false
    var passDataNotificationToTabBarVCCallback : ((dataManagerNotification : DataManagerNotification)->())!
    
    var feedViewModel : FeedViewModel!
    
    var hitViewDidAppearThisManyTimes = 0
    
    var didPresentDefaultLoginVC = false
    var hasSuccessFullyPulled = false
    
    
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
        
        if(dataManagerNotification == DataManagerNotification.CloudantPullDataSuccess){
            hasSuccessFullyPulled = true
        }
        
       passDataNotificationToTabBarVCCallback(dataManagerNotification: dataManagerNotification)
    }
    
    
    func tellFeedToStartLoadingAnimation(){
        if(didPresentDefaultLoginVC == true && hasSuccessFullyPulled == false){
            DataManagerCalbackCoordinator.SharedInstance.sendNotification(DataManagerNotification.StartLoadingAnimationForAppLaunch)
            didPresentDefaultLoginVC = false
        }
        
    }
    

    /**
     Retry pushing cloudant data upon error
     */
    func retryPushingCloudantData(){
        do {
            try CloudantSyncDataManager.SharedInstance!.pushToRemoteDatabase()
        } catch {
            print("retryPushingCloudantData ERROR: \(error)")
            DataManagerCalbackCoordinator.SharedInstance.sendNotification(DataManagerNotification.CloudantPushDataFailure)
        }
    }
    
    
    /**
     Retry pulling cloudant data upon error
     */
    func retryPullingCloudantData() {
        //CloudantSyncDataManager.SharedInstance.pullReplicator.stop()
        do {
            try CloudantSyncDataManager.SharedInstance!.pullFromRemoteDatabase()
        } catch {
            print("Retry pulling error: \(error)")
            DataManagerCalbackCoordinator.SharedInstance.sendNotification(DataManagerNotification.CloudantPullDataFailure)
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
