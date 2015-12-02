//
//  CloudantSyncClientTests.swift
//  BluePic
//
//  Created by Rolando Asmat on 11/25/15.
//  Copyright © 2015 MIL. All rights reserved.
//

@testable import BluePic
import XCTest

class CloudantSyncClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateProfileLocally() {
        CloudantSyncClient.SharedInstance.createProfileDoc("1234", name: "Rolando Asmat")
        let exists = CloudantSyncClient.SharedInstance.doesExist("1234")
        XCTAssertEqual(exists, true)
        let doc = CloudantSyncClient.SharedInstance.getDoc("1234")
        let name:String = doc.body["profile_name"]! as! String
        XCTAssertEqual(name, "Rolando Asmat")
        CloudantSyncClient.SharedInstance.deleteDoc("1234")
    }
    
    func testDeleteProfileLocally() {
        // Create User to delete
        CloudantSyncClient.SharedInstance.createProfileDoc("1234", name: "Rolando Asmat")
        
        // Delete User
        CloudantSyncClient.SharedInstance.deleteDoc("1234")
        let exists = CloudantSyncClient.SharedInstance.doesExist("1234")
        XCTAssertEqual(exists, false)
    }
    
    // Tests creation of pictures, assigning them to a user and finally deleting them.
    func testUserPictures() {
        // Create User
        let id = "3028"
        let name = "Rolando Asmat"
        CloudantSyncClient.SharedInstance.createProfileDoc(id, name: name)
        
        // Create 3 pictures and set their owner id
        let displayNames = ["Keys", "Big Bend", "Yosemite"]
        let fileNames = ["keys.jpg", "bigbend.jpg", "yosemite.jpg"]
        // Picture 1
        let picture1URL = "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[2], fileName: fileNames[2], url: picture1URL, ownerID: id)
        // Picture 2
        let picture2URL = "http://media-cdn.tripadvisor.com/media/photo-s/02/92/12/75/sierra-del-carmen-sunset.jpg"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[1], fileName: fileNames[1], url: picture2URL, ownerID: id)
        // Picture 3
        let picture3URL = "https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[0], fileName: fileNames[0], url: picture3URL, ownerID: id)
        
        // Run Query to get pictures corresponding to specified user id
        let result = CloudantSyncClient.SharedInstance.getPicturesOfOwnerId(id)
        
        // Go through set of returned docs and print fields.
        result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
            print("Index: "+idx.description)
            print(rev.body["URL"]!)
            print(rev.body["display_name"]!)
            print(rev.body["ts"]!)
            // Assert order of display names
            XCTAssertEqual(rev.body["display_name"]! as! String, displayNames[Int(idx)])
        })
        
        // Delete created user and their pictures
        CloudantSyncClient.SharedInstance.deleteDoc(id)
        CloudantSyncClient.SharedInstance.deletePicturesOfUser(id)
    }
    
    // Tests retrieval of ALL pictures of BluePic
    func testGetAllPictures() {
        // Create Users
        let id1 = "1837"
        let name1 = "Earl Fleming"
        CloudantSyncClient.SharedInstance.createProfileDoc(id1, name: name1)
        
        let id2 = "2948"
        let name2 = "Johnnie Willis"
        CloudantSyncClient.SharedInstance.createProfileDoc(id2, name: name2)
        
        let id3 = "1087"
        let name3 = "Marsha Cobb"
        CloudantSyncClient.SharedInstance.createProfileDoc(id3, name: name3)
        
        // Create 3 pictures and set their owner id
        let displayNames = ["Keys", "Big Bend", "Yosemite"]
        let fileNames = ["keys.jpg", "bigbend.jpg", "yosemite.jpg"]
        // Picture 1
        let picture1URL = "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[2], fileName: fileNames[2], url: picture1URL, ownerID: id1)
        // Picture 2
        let picture2URL = "http://media-cdn.tripadvisor.com/media/photo-s/02/92/12/75/sierra-del-carmen-sunset.jpg"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[1], fileName: fileNames[1], url: picture2URL, ownerID: id2)
        // Picture 3
        let picture3URL = "https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG"
        CloudantSyncClient.SharedInstance.createPictureDoc(displayNames[0], fileName: fileNames[0], url: picture3URL, ownerID: id3)
        
        // Run Query to get ALL pictures in BluePic
        let result = CloudantSyncClient.SharedInstance.getAllPictureDocs()
        
        // Go through set of returned docs and print fields.
        result.enumerateObjectsUsingBlock({ (rev, idx, stop) -> Void in
            print("Index: "+idx.description)
            print(rev.body["URL"]!)
            print(rev.body["display_name"]!)
            print(rev.body["ts"]!)
            print(rev.body["ownerName"]!)
        })
        
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
