/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
@testable import BluePic

/**
 * Test class for the CloudantSyncDataManager class.
 */
class CloudantSyncClientTests: XCTestCase {
    
    let dbName = Utils.getKeyFromPlist("keys", key: "cdt_tests_db_name")
    
    override func setUp() {
        super.setUp()
        // Make sure test cases point to tests_db datastore
        CloudantSyncDataManager.SharedInstance!.dbName = dbName
        // Create local datastore
        do {
            try CloudantSyncDataManager.SharedInstance!.createLocalDatastore()
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    override func tearDown() {
        super.tearDown()
        // Delete created datastore
        do {
            try CloudantSyncDataManager.SharedInstance!.manager.deleteDatastoreNamed(dbName)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests the creation of a user to the local datastore.
     */
    func testCreateProfileLocally() {
        do {
            // Create User
            let id = "4876"
            let name = "Ellen Harrison"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id, name: name)
            // Make sure doc exists now
            XCTAssertTrue(CloudantSyncDataManager.SharedInstance!.doesExist(id))
            // Assert on name as well
            let doc = CloudantSyncDataManager.SharedInstance!.getDoc(id)
            XCTAssertEqual(name, doc!.body["profile_name"] as? String)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests the deletion of a user from the local datastore.
     */
    func testDeleteProfileLocally() {
        do {
            // Create User to delete
            let id = "1039"
            let name = "Brad Tyler"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id, name: name)
            // Delete User
            try CloudantSyncDataManager.SharedInstance!.deleteDoc(id)
            // Make sure doc does not exist
            XCTAssertFalse(CloudantSyncDataManager.SharedInstance!.doesExist(id))
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests creation of picture doc where owner id DOES exist.
     */
    func testCreateValidPicture() {
        do {
            // Create User
            let id = "7532"
            let name = "Kenny Reid"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id, name: name)
            // Picture variables
            let displayName = "Yosemite"
            let fileName = "yosemite.jpg"
            let url = "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg"
            let width = "400"
            let height = "100"
            let timeStamp = (NSDate.timeIntervalSinceReferenceDate()).description
            // Create EXPECTED Picture Array
            let expectedPictureObject = createPictureObject(fileName, url: url, displayName: displayName, timeStamp: timeStamp, ownerName: name, width: width, height: height)
            var expectedArray = [Picture]()
            expectedArray.append(expectedPictureObject)
            // Create ACTUAL Picture Array
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(displayName, fileName: fileName, url: url, ownerID: id, width: width, height: height)
            let actualArray = CloudantSyncDataManager.SharedInstance!.getPictureObjects(id)
            // Compare all the fields of both picture arrays
            comparePictureObjects(expectedArray, actual: actualArray)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests creation of picture doc where owner id does NOT exist.
     */
    func testCreateInvalidPicture() {
        do {
            // Create Picture
            let displayName = "Yosemite"
            let fileName = "yosemite.jpg"
            let url = "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg"
            let width = "400"
            let height = "100"
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(displayName, fileName: fileName, url: url, ownerID: "", width: width, height: height)
        } catch {
            print("Test passed, creation of this doc SHOULD fail")
        }
    }
    
    /**
     * Tests the assignment of multiple pictures to a SPECIFIC user and the order of which they are returned in when queried.
     */
    func testUserPictures() {
        do {
            // Create User
            let id = "7532"
            let name = "Kenny Reid"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id, name: name)
            
            // Create 3 pictures and set their owner id
            let displayNames = ["Keys", "Big Bend", "Yosemite"]
            let fileNames = ["keys.jpg", "bigbend.jpg", "yosemite.jpg"]
            let urls = ["https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG", "http://media-cdn.tripadvisor.com/media/photo-s/02/92/12/75/sierra-del-carmen-sunset.jpg", "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg","https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG"]
            let widths = ["500", "200", "400"]
            let heights = ["150", "300", "100"]
            let timeStamp = (NSDate.timeIntervalSinceReferenceDate()).description
            // Create expected array of picture objects.
            var expectedArray = [Picture]()
            let expectedPictureObject1 = createPictureObject(fileNames[0], url: urls[0], displayName: displayNames[0], timeStamp: timeStamp, ownerName: name, width: widths[0], height: heights[0])
            expectedArray.append(expectedPictureObject1)
            let expectedPictureObject2 = createPictureObject(fileNames[1], url: urls[1], displayName: displayNames[1], timeStamp: timeStamp, ownerName: name, width: widths[1], height: heights[1])
            expectedArray.append(expectedPictureObject2)
            let expectedPictureObject3 = createPictureObject(fileNames[2], url: urls[2], displayName: displayNames[2], timeStamp: timeStamp, ownerName: name, width: widths[2], height: heights[2])
            expectedArray.append(expectedPictureObject3)
            
            // Create actual array of picture objects.
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[2], fileName: fileNames[2], url: urls[2], ownerID: id, width: widths[2], height: heights[2])
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[1], fileName: fileNames[1], url: urls[1], ownerID: id, width: widths[1], height: heights[1])
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[0], fileName: fileNames[0], url: urls[0], ownerID: id, width: widths[0], height: heights[0])
            // Run Query to get pictures corresponding to specified user id
            let actualArray = CloudantSyncDataManager.SharedInstance!.getPictureObjects(id)
            // Compare the arrays
            comparePictureObjects(expectedArray, actual: actualArray)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests order of when querying local database for ALL pictures.
     */
    func testGetAllPictures() {
        do {
            // Create Users
            let id1 = "1837"
            let name1 = "Earl Fleming"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id1, name: name1)
            let id2 = "2948"
            let name2 = "Johnnie Willis"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id2, name: name2)
            let id3 = "1087"
            let name3 = "Marsha Cobb"
            try CloudantSyncDataManager.SharedInstance!.createProfileDoc(id3, name: name3)
            
            // Create 3 pictures and set their owner id
            let displayNames = ["Keys", "Big Bend", "Yosemite"]
            let fileNames = ["keys.jpg", "bigbend.jpg", "yosemite.jpg"]
            let urls = ["https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG", "http://media-cdn.tripadvisor.com/media/photo-s/02/92/12/75/sierra-del-carmen-sunset.jpg", "http://www.tenayalodge.com/img/Carousel-DiscoverYosemite_img3.jpg","https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG"]
            let widths = ["500", "200", "400"]
            let heights = ["150", "300", "100"]
            let timeStamp = (NSDate.timeIntervalSinceReferenceDate()).description
            // Create expected array of picture objects.
            var expectedArray = [Picture]()
            let expectedPictureObject1 = createPictureObject(fileNames[0], url: urls[0], displayName: displayNames[0], timeStamp: timeStamp, ownerName: name1, width: widths[0], height: heights[0])
            expectedArray.append(expectedPictureObject1)
            let expectedPictureObject2 = createPictureObject(fileNames[1], url: urls[1], displayName: displayNames[1], timeStamp: timeStamp, ownerName: name2, width: widths[1], height: heights[1])
            expectedArray.append(expectedPictureObject2)
            let expectedPictureObject3 = createPictureObject(fileNames[2], url: urls[2], displayName: displayNames[2], timeStamp: timeStamp, ownerName: name3, width: widths[2], height: heights[2])
            expectedArray.append(expectedPictureObject3)
            
            // Create actual array of picture objects.
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[2], fileName: fileNames[2], url: urls[2], ownerID: id1, width: widths[2], height: heights[2])
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[1], fileName: fileNames[1], url: urls[1], ownerID: id2, width: widths[1], height: heights[1])
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayNames[0], fileName: fileNames[0], url: urls[0], ownerID: id3, width: widths[0], height: heights[0])
            // Run Query to get pictures corresponding to specified user id
            let actualArray = CloudantSyncDataManager.SharedInstance!.getPictureObjects(nil)
            // Compare the arrays
            comparePictureObjects(expectedArray, actual: actualArray)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Tests the push of 2 documents, deleting them locally, then pulling them and finally making sure they exist again locally.
     */
    func testPushNPull() {
        do {
            // Create User and Picture documents to PUSH and then PULL
            let name = "Kenny Reid"
            let id =  try CloudantSyncDataManager.SharedInstance!.createProfileDocForTestCases(name)
            let displayName = "Keys"
            let fileName = "keys"
            let url = "https://www.flmnh.ufl.edu/fish/SouthFlorida/images/bocachita.JPG"
            let width = "500"
            let height = "150"
            try CloudantSyncDataManager.SharedInstance!.createPictureDoc(
                displayName, fileName: fileName, url: url, ownerID: id, width: width, height: height)
            let document = CloudantSyncDataManager.SharedInstance!.getDoc(id)
            print(document)
            // Push local datastore to remote database
            let xctExpectation = self.expectationWithDescription("Asynchronous request about to occur...")
            CloudantSyncDataManager.SharedInstance!.pushDelegate = TestPushDelegate(xctExpectation: xctExpectation)
            try CloudantSyncDataManager.SharedInstance!.pushToRemoteDatabase()
            self.waitForExpectationsWithTimeout(100.0,handler: nil)
            
            // Delete local copy of documents
            try CloudantSyncDataManager.SharedInstance!.deletePicturesOfUser(id)
            try CloudantSyncDataManager.SharedInstance!.deleteDoc(id)
            
            // Assert on deletion of documents
            XCTAssertFalse(CloudantSyncDataManager.SharedInstance!.doesExist(id))
            
            // Recreate local datasotre
            do {
                try CloudantSyncDataManager.SharedInstance!.manager.deleteDatastoreNamed(dbName)
                try CloudantSyncDataManager.SharedInstance!.createLocalDatastore()
            } catch {
                print(error)
                XCTFail()
            }
            
            // Pull them again
            let xctExpectation2 = self.expectationWithDescription("Asynchronous request about to occur...")
            CloudantSyncDataManager.SharedInstance!.pullDelegate = TestPullDelegate(xctExpectation: xctExpectation2)
            try CloudantSyncDataManager.SharedInstance!.pullFromRemoteDatabase()
            self.waitForExpectationsWithTimeout(100.0,handler: nil)
            
            // Make sure they exist, use utility method to make sure picture doc is correct as well.
            XCTAssertTrue(CloudantSyncDataManager.SharedInstance!.doesExist(id))
            
            // Delete them locally again
            try CloudantSyncDataManager.SharedInstance!.deletePicturesOfUser(id)
            try CloudantSyncDataManager.SharedInstance!.deleteDoc(id)
            
            // Push deleted doc change
            let xctExpectation3 = self.expectationWithDescription("Asynchronous request about to occur...")
            CloudantSyncDataManager.SharedInstance!.pushDelegate = TestPushDelegate(xctExpectation: xctExpectation3)
            try CloudantSyncDataManager.SharedInstance!.pushToRemoteDatabase()
            self.waitForExpectationsWithTimeout(100.0,handler: nil)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    /**
     * Utility method to compare two Picture objects.
     */
    func comparePictureObjects(expected:[Picture], actual:[Picture]) {
        if (expected.count == actual.count) {
            for index in 0...actual.count-1 {
                XCTAssertEqual(expected[index].displayName, actual[index].displayName)
                XCTAssertEqual(expected[index].fileName, actual[index].fileName)
                XCTAssertEqual(expected[index].url, actual[index].url)
                XCTAssertEqual(expected[index].width, actual[index].width)
                XCTAssertEqual(expected[index].height, actual[index].height)
            }
        } else {
            print("Expected and actual array are of different size!")
            XCTFail()
        }
    }
    
    /**
     * Utility method to create Picture object from parameters
     */
    func createPictureObject(filename:String, url:String, displayName:String, timeStamp:String, ownerName:String, width:String, height:String) -> Picture {
        let newPicture = Picture()
        newPicture.fileName = filename
        newPicture.url = url
        newPicture.displayName = displayName
        newPicture.timeStamp = Double(timeStamp)
        newPicture.ownerName = ownerName
        newPicture.width = CGFloat((width as NSString).floatValue)
        newPicture.height = CGFloat((height as NSString).floatValue)
        return newPicture
    }
}

/**
 * Delegates for test Replicators.
 */

class TestPullDelegate:PullDelegate {
    
    var xctExpectation:XCTestExpectation
    
    init(xctExpectation:XCTestExpectation) {
        self.xctExpectation = xctExpectation
    }
    
    /**
     * Called when the replicator changes state.
     */
    override func replicatorDidChangeState(replicator:CDTReplicator) {
        print("TEST PULL Replicator changed state.")
    }
    
    /**
     * Called whenever the replicator changes progress
     */
    override func replicatorDidChangeProgress(replicator:CDTReplicator) {
        print("TEST PULL Replicator changed progess.")
    }
    
    /**
     * Called when a state transition to COMPLETE or STOPPED is
     * completed.
     */
    override func replicatorDidComplete(replicator:CDTReplicator) {
        print("TEST PULL Replicator completed.")
        self.xctExpectation.fulfill()
    }
    
    /**
     * Called when a state transition to ERROR is completed.
     */
    override func replicatorDidError(replicator:CDTReplicator, info:NSError) {
        print("TEST PULL ERROR: \(info)")
        self.xctExpectation.fulfill()
        XCTFail()
    }
}

class TestPushDelegate:PushDelegate {
    
    var xctExpectation:XCTestExpectation
    
    init(xctExpectation:XCTestExpectation) {
        self.xctExpectation = xctExpectation
    }
    
    /**
     * Called when the replicator changes state.
     */
    override func replicatorDidChangeState(replicator:CDTReplicator) {
        print("TEST PUSH Replicator changed state.")
    }
    
    /**
     * Called whenever the replicator changes progress
     */
    override func replicatorDidChangeProgress(replicator:CDTReplicator) {
        print("TEST PUSH changed progess.")
    }
    
    /**
     * Called when a state transition to COMPLETE or STOPPED is
     * completed.
     */
    override func replicatorDidComplete(replicator:CDTReplicator) {
        print("TEST PUSH Replicator completed.")
        self.xctExpectation.fulfill()
    }
    
    /**
     * Called when a state transition to ERROR is completed.
     */
    override func replicatorDidError(replicator:CDTReplicator, info:NSError) {
        print("TEST PUSH Replicator ERROR: \(info)")
        self.xctExpectation.fulfill()
        XCTFail()
    }
}


