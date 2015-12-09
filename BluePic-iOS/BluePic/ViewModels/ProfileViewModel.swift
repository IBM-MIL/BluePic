//
//  ProfileViewModel.swift
//  BluePic
//
//  Created by Alex Buck on 12/8/15.
//  Copyright © 2015 MIL. All rights reserved.
//

import UIKit

class ProfileViewModel: NSObject {

    var pictureDataArray = [Picture]()
    var refreshVCCallback : (()->())!
    let kNumberOfSectionsInCollectionView = 1
    
    init(refreshVCCallback : (()->())){
       super.init()
        
        self.refreshVCCallback  = refreshVCCallback
        
        
        DataManagerCalbackCoordinator.SharedInstance.addCallback(handleDataManagerNotifications)
        
        getPictureObjects()
        
    }
    

    
    func handleDataManagerNotifications(dataManagerNotification : DataManagerNotification){
        
    }
    
    
    
    
    func getPictureObjects(){
        pictureDataArray = CloudantSyncClient.SharedInstance.getAllPictureObjectsOfOwnerId(FacebookDataManager.SharedInstance.fbUniqueUserID!)
        
        
        dispatch_async(dispatch_get_main_queue()) {
            self.callRefreshCallBack()
        }
    }
    
    
    func repullForNewData(){
        CloudantSyncClient.SharedInstance.pullFromRemoteDatabase()
    }
    
    
    
    
    func numberOfSectionsInCollectionView() -> Int {
        return kNumberOfSectionsInCollectionView
    }
    
    
    func numberOfItemsInSection(section : Int) -> Int {
        return pictureDataArray.count
    }
    
    func sizeForItemAtIndexPath(indexPath : NSIndexPath, collectionView : UICollectionView) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 364)
    }
    
    
    
    func setUpCollectionViewCell(indexPath : NSIndexPath, collectionView : UICollectionView) -> UICollectionViewCell {
        
        let cell: ProfileCollectionViewCell
        
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionViewCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
        
        let picture = pictureDataArray[indexPath.row]
        
        cell.setupData(picture.url, displayName: picture.displayName, timeStamp: picture.timeStamp)
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
        
    }
    
    
    /**
     Method sets up the section header for the indexPath parameter
     
     - parameter indexPath:      NSIndexPath
     - parameter kind:           String
     - parameter collectionView: UICollectionView
     
     - returns: TripDetailSupplementaryView
     */
    func setUpSectionHeaderViewForIndexPath(indexPath : NSIndexPath, kind: String, collectionView : UICollectionView) -> ProfileHeaderCollectionReusableView {
        
        let header : ProfileHeaderCollectionReusableView
        
        header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeaderCollectionReusableView", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView
        
        header.setupData(FacebookDataManager.SharedInstance.fbUserDisplayName, numberOfShots: pictureDataArray.count)
        
        return header
    }
    
    
    

    
    func callRefreshCallBack(){
        if let callback = refreshVCCallback {
            callback()
        }
    }
    
    
    
}
