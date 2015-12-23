<p align="center">
<img src="img/banner.jpg"  alt="Drawing" border=0 />
</p>

<br>
#BluePic

BluePic is a sample application for iOS that shows you how to connect your mobile application with IBM Bluemix services. It is a photo sharing app that allows you to take photos, upload them and share them with the BluePic community. The BluePic community will be made up of all the users that run an instance of **your** created app.

<br>
## Table of Contents
* [About IBM Bluemix](#about-ibm-bluemix)
* [Requirements](#requirements)
* [Getting Started](#getting-started)
	* [Create Bluemix Account](#1-create-bluemix-account)
	* [BluePic Account Requirements](#2-bluepic-account-requirements) 
	* [Create Bluemix Application and Services](#3-create-bluemix-application-and-services)
	* [Connect BluePic to your Bluemix Account](#4-connect-bluepic-to-your-bluemix-account) 
	* [Create an application instance on Facebook](#5-create-an-application-instance-on-facebook)
	* [Pre-populate Feed with Stock Photos (Optional)](#6-pre-populate-feed-with-stock-photos-optional)
* [Using BluePic](#using-bluepic)
	* [Facebook Login](#facebook-login)
	* [View Feed](#view-feed) 
	* [Post a Photo](#post-a-photo)
	* [View Profile](#view-profile) 
* [Project Structure](#project-structure)
* [Architecture/Bluemix Services Implementation](#architecturebluemix-services-implementation)
	* [Mobile Client Access Facebook Authentication](#1-mobile-client-access-facebook-authentication)
	* [Cloudant Sync (CDTDatastore)](#2-cloudant-sync-cdtdatastore)
	* [Object Storage](#3-object-storage) 
* [Architecture Forethought](#architecture-forethought)
* [Troubleshooting](#troubleshooting)
	* [Deploy to Bluemix Failure](#deploy-to-bluemix-failure) 
* [License](#license)

<br>
## About IBM Bluemix

[Bluemix™](https://developer.ibm.com/sso/bmregistration?lang=en_US&ca=dw-_-bluemix-_-cl-bluemixfoundry-_-article) is the latest cloud offering from IBM®. It enables organizations and developers to quickly and easily create, deploy, and manage applications on the cloud. Bluemix is an implementation of IBM's Open Cloud Architecture based on [Cloud Foundry](https://www.cloudfoundry.org/), an open source Platform as a Service (PaaS). Bluemix delivers enterprise-level services that can easily integrate with your cloud applications without you needing to know how to install or configure them.

In Bluemix you should be aware that often the term “Application” is used to refer to a server component and its Bluemix services needed. It is this server component that gets deployed to Bluemix. It is not the mobile application that gets deployed, this will become clear as you go through the [Getting Started](https://github.com/IBM-MIL/BluePic/tree/develop#getting-started) guide. 

<br>
## Requirements
Currently, BluePic supports Xcode 7.1.1, iOS 9+, and Swift 2. Designed for iPhone, compatible with iPad.

<br>
## Getting Started

### 1. Create Bluemix Account
Create an IBM Bluemix account [here](https://console.ng.bluemix.net/registration/?cm_mc_uid=32373843009114392241684&cm_mc_sid_50200000=1450718074) and log in. If you already have an account, log in and continue to step 2.

### 2. BluePic Account Requirements
A free trial of Bluemix comes with 2 GB of memory and allows the use of up to 10 services. If this is your first time using Bluemix, continue to step 3. Otherwise, you might need to delete some reources. BluePic requires 512 Mb of memory and 4 services. If your account does not have enough resources availabe, delete unused instances to free up resources. You can check your usage by looking at the Dashboard tab of Bluemix:
<p align="center">
<img src="img/account_usage.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 1: Bluemix dashboard, account usage for memory and services highlighted.</p>

### 3. Create Bluemix Application and Services
Click the "Deploy to Bluemix" button below. It will create the BluePic Bluemix application in your account and initialize the required services.

<p align="center"><a href="https://bluemix.net/deploy?repository=https://github.com/rolandoasmat/MyBluemixApp.git"><img src="https://bluemix.net/deploy/button.png" alt="Deploy to Bluemix"></a></p>

If desired, update the app name, region, organization or space of the application (default parameters work). Click Deploy:
<p align="center">
<img src="img/deploy_button_params.PNG"  alt="Drawing" width=400 border=0 /></p>
<p align="center">Figure 2: Parameters to deploy a Bluemix application.</p>

Upon success you should see:
<p align="center">
<img src="img/deploy_button_success.PNG"  alt="Drawing" width=400 border=0 /></p>
<p align="center">Figure 3: Deploy success page.</p>

**Note:** If deploying to Bluemix fails, it will have created a faulty application on your account as well as a DevOps services (formerly known as JazzHub) project, these must be deleted manually before trying again. Steps on how to do this [here](#deploy-to-bluemix-failed).

Next, go to your dashboard by clicking the "Dashboard" tab on the top of the page: 
<p align="center">
<img src="img/deploy_success_dashboard.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 4: Getting back to Dashboard after successful deployment.</p>

On your dashboard the application should then become accessible, click on the Application box to open that Application Overview:
<p align="center">
<img src="img/dashboard_application.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 5: Bluemix dashboard.</p>

Application Overview:
<p align="center">
<img src="img/application_overview.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 6: Application Overview.</p>

### 4. Connect BluePic to your Bluemix Account
The app has to be configured with certain credentials from each of the three Bluemix services. The file `keys.plist` located in the `Configuration` directory of the BluePic Xcode project must be updated accordingly.

<p align="center">
<img src="img/keys.PNG"  alt="Drawing" width=500 border=0 /></p>
<p align="center">Figure 7. keys.plist located in the BluePic-iOS/BluePic/Configuration directory.</p>

#### Cloudant NoSQL DB 

* cdt_username: This username will be used to identiry your created databases. From the Application Overview (see Figure 5 above) open the Cloudant NoSQL Instantiating Credentials by clcking on the "Show Credentials" tab of the service box:

<p align="center">
<img src="img/cloudant_credentials.PNG"  alt="Drawing" width=350 border=0 /></p>
<p align="center">Figure 8. Credentials of a Cloudant NoSQL DB service.</p>

Copy the “username” credential and paste it in the "cdt_username" field of keys.plist file.

* cdt_db\_name: This will be the name of the main Cloudant database the iOS application will use to store information. We first must go to the Cloudant Dashboard, click on the CloudantNoSQL DB icon from the Application Overview (see Figure 5 above). You will land in this page:

<p align="center">
<img src="img/cloudant_landing.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 9. Cloudant service landing page.</p>

Click "VIEW YOUR DATA ON THE CLOUDANT DASHBOARD" to open the Cloudant Dashboard:
<p align="center">
<img src="img/cloudant_dashboard.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 10. Cloudant Dashboard.</p>

Click on "Create Database", enter a name, and click "Create":
<p align="center">
<img src="img/cloudant_create_db.PNG"  alt="Drawing" width=400 border=0 /></p>
<p align="center">Figure 11. Creating a new Database.</p>

**Note:** The name must start with a letter and can only contain lowercase letters (a-z), digits (0-9) and the following characters _, $, (, ), +, -, and /.

Put the name of the newly created database into the "cdt_db\_name" field of key.plist file.  

* cdt\_key and cdt\_pass: You must generate an API Key and Password for the mobile application to access the remote database. On the database page, click on the Permissions tab:

<p align="center">
<img src="img/cloudant_permissions.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 12. Permissions button on database main page.</p>

On the Permissions page click "Generate API key" button:
<p align="center">
<img src="img/cloudant_generate_api_key.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 13. Generate an API key for the database.</p>

It will create a Key and Password:
<p align="center">
<img src="img/cloudant_api_key.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 14. Generated Key and Password.</p>

Store these values into "cdt\_key" and "cdt\_pass" fields of keys.plist file respectively. Also, ensure that the created API Key has Writer and Replicator permissions by checking these boxes:
<p align="center">
<img src="img/cloudant_key_permissions.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 15. Ensure the generated API Key has the correct permissions.</p>

* cdt\_tests\_db\_name: The application has test cases that run on a separate database, we're storing the name of this test database here. Go through the exact same steps as done for "cdt\_db\_name" except with a different database name. Put this name into "cdt\_tests\_db\_name" field of keys.plist file. Once created, click on the "Permissions" tab of the new database. The previously generated API Key should be listed, again ensure it has Writer and Replicator permissions:

<p align="center">
<img src="img/cloudant_test_db_permissions.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 16. Permissions page of the database to run test cases.</p>

#### Mobile Client Access

* backend_route: Listed on the top of the Application Overview page, next to the "Routes:" label:

<p align="center">
<img src="img/application_routes.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 17. Routes label on Application Overview page.</p>

Copy and paste this value into the "backend_route" field of keys.plist file.
 
* GUID: From the Application Overview (see Figure 5 above) open the Mobile Client Access Instantiating Credentials by clcking on the "Show Credentials" tab of the service box:

Copy the "clientId" credential and paste into "GUID" field of keys.plist file.

<p align="center">
<img src="img/mobile_client_access_id.PNG"  alt="Drawing" width=300 border=0 /></p>
<p align="center">Figure 18. Credentials of a Mobile Client Access service.</p>

#### Object Storage 

Download and install the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli/releases), make sure to install the Mac OS X 64 bit Installer, the latest release:
<p align="center">
<img src="img/cf_cli.PNG"  alt="Drawing" width=300 border=0 /></p>
<p align="center">Figure 19. Cloud Foundry CLI installer.</p>

Run the following commands on the terminal:

`cf api https://api.ng.bluemix.net`

`cf login -u <email_address> -o <email_address> -s dev`

Pick a name for the service key and use it in the following commands:

`cf create-service-key 'Object Storage-rz' <unique_name_for_this_key>`

In the following command, use the same name as the one created above:

`cf service-key 'Object Storage-rz' <unique_name_for_this_key>`

It will return several values:
<p align="center">
<img src="img/cf_cli_service_key.PNG"  alt="Drawing" width=600 border=0 /></p>
<p align="center">Figure 20. Cloud Froundry CLI command.</p>

* obj_stg\_password: Copy the "password" from CF CLI command into this field.
* obj_stg\_user\_id: Copy the "userId" from CF CLI command into this field.
* obj_stg\_project\_id: Copy the "projectId" from from CF CLI command into this field.
* obj_stg\_public\_url: Copy the "projectId" from CF CLI command and append it to "https://dal.objectstorage.open.softlayer.com/v1/AUTH_" like so:

`https://dal.objectstorage.open.softlayer.com/v1/AUTH_<project_id>`

Paste the resulting string into this field.
* obj_stg\_auth\_url: Paste "***REMOVED***" into this field.

### 5. Create an application instance on Facebook
In order to have the app authenticate with Facebook, you must create an application instance on Facebook's website and connect it to your Bluemix app's Mobile Client Access.

1. To create an application instance on Facebook's website, first go to [Facebook's Quick Start for iOS](https://developers.facebook.com/quickstarts/?platform=ios) page. Type 	`BluePic` as the name of your new Facebook app and click the `Create New Facebook App ID` button.

1. On the screen that follows, in the `Configure your info.plist` section under `step 2`, copy that information into your `info.plist` file. You can find the `info.plist` file in Configuration folder of the xcode project. If you have trouble finding the `CFBundleURLType` key, note that xcode changes the `CFBundleURLType` key to `URL types` when the key is entered. Your `info.plist` file should now look like this:
<p align="center">
<img src="img/fb_info.PNG"  alt="Drawing" height=150 border=0 /></p>
<p align="center">Figure 21. Info.plist file.</p>

1. Next scroll to the bottom of the quick start page where it says `Supply us with your Bundle Identifier` and enter the app's bundle identifier. To find the bundle identifer in the Xcode project you can do the following: 
	* Make sure the project navigator folder icon is selected in the top left of xcode. Select the BluePic project at the top of the file structure and then select the BluePic target. Under the identity section, you should see a text field for the bundle identifier that is empty. You can make the bundle identifier anything you want, `com.BluePic` for example.
1. Once you you entered the bundle ID on the Facebook quick start page, click `next`. Thats it for the Facebook quick start setup!
1. Next go back to your Bluemix dashboard, under services click `BluePic-AdvancedMobileAccess`. On the page that shows click the `Set Up Authentication` button and then click `Facebook`. Enter your Facebook app ID you gathered from step 2 and press next. 

Thats it for all the Facebook login setup. The rest of the Facebook authentication steps are already setup in the BluePic Xcode project!

### 6. Pre-populate Feed with Stock Photos (Optional)
Once BluePic is configured, you should be able to upload photos and see them appear on the feed and profile. However, initially your feed will be empty. If you would like to pre-populate your feed with 3 images, simply do the following:

1. With the BluePic Xcode project open, show the Test Navigator by clicking the 4th icon from the right of the Navigator (toolbar frame on the left side)
<p align="center">
<img src="img/populate_feed.PNG"  alt="Drawing" height=400 border=0 /></p>
<p align="center">Figure 22. PopulateFeedWithPhotos test case.</p>

1. Run the test called PopulateFeedWithPhotos which should be grayed out (disabled by default when tests are run) by right clicking it and clicking **Test "PopulateFeedWithPhotos"**.

1. The test should complete successfully. Launch BluePic again, and you should see 3 images added by user "Mobile Innovation Lab" on the feed.

<br>
## Using BluePic

### Facebook Login
BluePic was designed so that anyone can quickly launch the app and view photos posted without needing to log in. However, to view the profile or post photos, the user can easily login with his/her Facebook account. This is only used for a unique user id, the user's full name, as well as to display the user's profile photo.

<p align="center">
<img src="img/login.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 23. Welcome page.</p>

### View Feed
The feed (first tab) shows all the latest photos posted to the BluePic community (regardless if logged in or not).

<p align="center">
<img src="img/feed.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 24. Main feed view.</p>

### Post a Photo
Posting to the BluePic community is easy. Tap the middle tab in the tab bar and choose to either Choose a photo from the Camera Roll or Take a photo using the device's camera. You can then give the photo a caption before posting.

<p align="center">
<img src="img/post.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 25. Posting a photo.</p>

### View Profile
By tapping the third tab, you can view your profile. This shows your Facebook profile photo, lists how many photos you've posted, and shows all the photos you've posted to BluePic.

<p align="center">
<img src="img/profile.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 26. Profile feed.</p>

<br>
## Project Structure
* `/BluePic-iOS` directory for the iOS client.
* `/BluePic-iOS/BluePic/Configuration` directory for configuring Bluemix services keys.
* `/NodeStarterCode` directory for the server artifact that is deployed to Bluemix.
* `/img` directory for images for this README.

<br>
## Architecture/Bluemix Services Implementation
The following architecture is utilized for BluePic. For authentication, Mobile Client Access with Facebook Authentication is implemented. For profile and photo metadata, the Cloudant SDK is integrated. Finally, for photo storage and hosting, Object Storage is utilized.

<p align="center">
<img src="img/architecture.PNG"  alt="Drawing" height=350 border=0 /></p>
<p align="center">Figure 27. BluePic Architecture Diagram.</p>

### 1. Mobile Client Access Facebook Authentication
[Bluemix Mobile Client Access Facebook Authentication](https://www.ng.bluemix.net/docs/services/mobileaccess/gettingstarted/ios/index.html) is used for logging into BluePic. 

The `FacebookDataManager` under the `BluePic-iOS/BluePic/DataManagers` directory handles most of the code responsible for Facebook authentication. To start using Bluemix Facebook Authentication, it must first be configured on app launch, and we do this in the `didFinishLaunchingWithOptions()` method of `AppDelegate.swift` by calling the method below.

```swift
func initializeBackendForFacebookAuth() {
    //Initialize backend
    let key = Utils.getKeyFromPlist("keys", key: "backend_route")
    let guid = Utils.getKeyFromPlist("keys", key: "GUID")
    IMFClient.sharedInstance().initializeWithBackendRoute(key, backendGUID: guid);
    
    //Initialize FB
    IMFFacebookAuthenticationHandler.sharedInstance().registerWithDefaultDelegate()
    
    }
```

Also in the App Delegate, two other methods must be overridden to activate Facebook Authentication, as shown below:

```swift
func applicationDidBecomeActive(application: UIApplication) {
    FBAppEvents.activateApp()
    }
      
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,annotation: AnyObject) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication)
    }
```

Now that the Facebook and Bluemix frameworks are configured, you can actually try authenticating to receive a unique identifier for a user. The `FacebookDataManager` deals with authenticating and keeping track of user's credentials in a SharedInstance (singleton). The method below starts the process of showing a native Facebook login to the user when he/she presses the **SIGN IN WITH FACEBOOK** button on the `LoginViewController`.

```swift
/**
     Method to auth user using Facebook SDK
     
     - parameter callback: Success or Failure
     */
    func authenticateUser(callback : ((networkRequest : NetworkRequest) -> ())){
        if (self.checkIMFClient() && self.checkAuthenticationConfig()) {
            self.getAuthToken(callback) //this will in turn present FB login
        }
        else{
            callback(networkRequest: NetworkRequest.Failure)
        }
        
    }
```
The `self.checkAuthenticationConfig()` method call in the code above will try to present the native iOS 9 Safari Facebook Login Modal. The code above either continues with requesting a Facebook token if the login credentials were correct from the user, or throws an error if not correct or the user cancels.

After the user finishes inputting their credentials, the unique user id is received and saved in the `getAuthToken()` method of the `FacebookDataManager`. There, an IMFAuthorizationManager requests authorization by calling the `obtainAuthorizationHeaderWithCompletionHandler()` method, resulting in a success or failure. 

The successful closure of `getAuthToken()` is shown below, where the user display name and unique id are saved to the `sharedInstance` property of the `FacebookDataManager`, as well as saved to NSUserDefaults to keep track of log-in status in future app launches.

```swift
if let userID = identity["id"] as? NSString {
                        if let userName = identity["displayName"] as? NSString {
                        
                            //save username and id to shared instance of this class
                            self.fbUniqueUserID = userID as String
                            self.fbUserDisplayName = userName as String
                        
                            //set user logged in
                            self.isLoggedIn = true
                            
                            //save user id and name for future app launches
                            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "user_id")
                            NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "user_name")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            print("Got facebook auth token for user \(userName) with id \(userID)")
                            
                            callback(networkRequest: NetworkRequest.Success)
                        }
                    }
```

<br>
### 2. Cloudant Sync (CDTDatastore)
Cloudant Sync [(CDTDatastore)](https://github.com/cloudant/CDTDatastore) enables you to create a single local database for every user. The app simply replicates and syncs a copy of the remote database in Cloudant with its local copy on their phone or tablet. If there’s no network connection, the app runs off the local database on the device. In BluePic we have two types of documents: profile and picture. Note that we only store the metadata for pictures, the actual image is stored in the Object Storage Bluemix service. The `CloudantSyncDataManager` class was created to handle communication between iOS and Cloudant Sync.

Creating a local datastore:

```swift
    /**
     * Creates a local datastore with the specific name stored in dbName instance variable.
     */
    func createLocalDatastore() throws {
        let fileManager = NSFileManager.defaultManager()
        let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
        let path = storeURL.path
        self.manager = try CDTDatastoreManager(directory: path)
        self.datastore = try manager.datastoreNamed(dbName)
    }
```
Function to create a Profile document:

```swift
    /**
     * Creates a profile document.
     *
     * @param id Unique ID the created document to have.
     * @param name Profile name for the created document.
     */
    func createProfileDoc(id:String, name:String) throws -> Void {
        // Create a document
        let rev = CDTDocumentRevision(docId: id)
        rev.body = ["profile_name":name, "Type":"profile"]
        // Save the document to the datastore
        try datastore.createDocumentFromRevision(rev)
        print("Created profile doc with id: \(id)")
    }
```

Synching with a remote database is done by performing two main operations: push and pull. Below is an example of how we perform push.

```swift
    /**
      * This method will create a new Replicator object and push any new docs/updates on the local datastore to the remote database.
      * This is a asynchronous call and will run on a separate replication thread.
      */
    func pushToRemoteDatabase() throws {
        //Initialize replicator
        try createPushReplicator()
        //Start the replicator
        try self.pushReplicator.start()
    }
    
    /**
     * Creates a new Push Replicator and stores it in pushReplicator instance variable.
     */
    func createPushReplicator() throws {
        //Initialize replicators
        let replicatorFactory = CDTReplicatorFactory(datastoreManager: manager)
        let remoteDatabaseURL = generateURL()
        // Push Replicate from the local to remote database
        let pushReplication = CDTPushReplication(source: datastore, target: remoteDatabaseURL)
        self.pushReplicator =  try replicatorFactory.oneWay(pushReplication)
        self.pushReplicator.delegate = pushDelegate;
    }
    
    /**
     * Creates the URL of the remote database from instance variables.
     */
    private func generateURL() -> NSURL {
        let stringURL = "https://\(apiKey):\(apiPassword)@\(username).cloudant.com/\(dbName)"
        return NSURL(string: stringURL)!
    }
```
You can view the Cloudant database (including profile and picture documents) by navigating to your Cloudant NoSQL DB service instance on the Bluemix Dashboard. To do this, navigate to your Bluemix Dashboard by clicking **Dashboard** on the top of your Bluemix home page (**#1** in the image below). Then, click the **Cloudant NoSQL DB** service to view the record of images uploaded to each container (**#2** in the image below)

<p align="center">
<img src="img/cloudant_sync.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 28. Cloudant NoSQL service.</p>

<br>
### 3. Object Storage
[Object Storage](https://console.ng.bluemix.net/catalog/services/object-storage/) is used in BluePic for hosting images.

`ObjectStorageDataManager` and `ObjectStorageClient` were created based on [this link](http://developer.openstack.org/api-ref-objectstorage-v1.html) for communicating between iOS and Object Storage.

Before uploading photos, it is necessary to authenticate with Object Storage by calling `ObjectStorageDataManager.SharedInstance.objectStorageClient.authenticate()` which returns either a success or failure, shown below in the `FacebookDataManager`.

```swift
ObjectStorageDataManager.SharedInstance.objectStorageClient.authenticate({() in
                    print("success authenticating with object storage!")
                    self.showLoginIfUserNotAuthenticated()
                }, onFailure: {(error) in
                    print("error authenticating with object storage: \(error)")
                    DataManagerCalbackCoordinator.SharedInstance.sendNotification(DataManagerNotification.ObjectStorageAuthError)
            })
```

Next, you must create a container on Object Storage for uploading photos to. The method below in the `LoginViewModel` creates a container for later uploading photos to.

```swift
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
```

Finally, you can upload an image to Object Storage by utilizing code similar to the method below in the `CameraDataManager`

```swift
    /**
     Method called to upload the image to object storage
     */
    func uploadImageToObjectStorage() {
        print("uploading photo to object storage...")
        //push to object storage
        ObjectStorageDataManager.SharedInstance.objectStorageClient.uploadImage(FacebookDataManager.SharedInstance.fbUniqueUserID!, imageName: self.lastPhotoTakenName, image: self.lastPhotoTaken,
            onSuccess: { (imageURL: String) in
                print("upload to object storage succeeded.")
                print("imageURL: \(imageURL)")
            }, onFailure: { (error) in
                print("upload to object storage failed!")
                print("error: \(error)")
                DataManagerCalbackCoordinator.SharedInstance.sendNotification(DataManagerNotification.ObjectStorageUploadError)
        })
    }
```

You can view the Object Storage database (including all photos uploaded) by navigating to your Object Storage service instance on the Bluemix Dashboard. To do this, navigate to your Bluemix Dashboard by clicking **Dashboard** on the top of your Bluemix home page (**#1** in the image below). Then, click the **Object Storage** service to view the record of images uploaded to each container (**#2** in the image below)

<p align="center">
<img src="img/object_storage.PNG"  alt="Drawing" height=550 border=0 /></p>
<p align="center">Figure 29. Object Storage service.</p>

<br>
## Architecture Forethought

For BluePic, we used a simple architecture where there is no middle tier component between the mobile app and the storage components (e.g. Cloudant) on the server. To roll out BluePic to a production environment, a few architectural changes should be made.

Cloudant Sync requires a complete replica of the database on each mobile client. This may not be feasible for apps with large databases. Under such scenarios, instead of leveraging Cloudant Sync, the REST API provided by Cloudant could be used to perform CRUD and query operations against the remote Cloudant instance.  Though replicating subsets of records can be done today with Cloudant Sync, doing so with large databases where only a small subset of records should be replicated can introduce performance problems.

Using Cloudant Sync without an additional middle tier component between the mobile app and the database requires the mobile code to know the username and password for accessing the Cloudant database. This will lead to security breaches if someone gets their hands on those credentials. Hence, security could be a reason for having all database operations go first through a middleware component (e.g. Liberty, Node.js) to verify that only authenticated and authorized users of the app can perform such operations. In this architecture, the credentials to access the database are only known by the middleware component.
<br>
## Troubleshooting

### Deploy to Bluemix Failure
If the Deploy to Bluemix button failed, you would see a page similar to this:
<p align="center">
<img src="img/deploy_failed.PNG"  alt="Drawing" width=400 border=0 /></p>
<p align="center">Figure 30. A failed deployment to Bluemix.</p>

These are some of the most common reasons for a failed deployment:

* Your account does not have enough resources. BluePic requires requires 512 Mb of memory and 4 services to deploy successfully. 
* You have already deployed BluePic to your account and have tried to deploy it again.
* Bluemix servers are down.

Even though the deployment failed, Bluemix still have created an application, initializes some services and creates a DevOps project. You must delete these **manually** before attempting to deploy again. Begin by first going back to the dashboard, click the "Dashboard" tab on top of the page:
<p align="center">
<img src="img/deploy_failed_dashboard.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 31. Click on the "Dashboard" tab to go back to the main page.</p>

Once in the dashboard, find the failed application under the "Applications" section and click on the gray gear located on the top right corner of the application block to open the menu:
<p align="center">
<img src="img/application_gear.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 32. Opening the menu of a Bluemix application.</p>

With the menu now open, click the "Delete App" option:
<p align="center">
<img src="img/delete_app.PNG"  alt="Drawing" width=300 border=0 /></p>
<p align="center">Figure 33. Menu open, delete option highlighted of a Bluemix application.</p>

You will get at "Are you sure..." message, make sure all the services under the Services tab are checked and click DELETE, this will delete the application and all of the created services:
<p align="center">
<img src="img/delete_app_confirmation.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 34. Deleting a Bluemix application and its binded services.</p>

Now, you must delete the Bluemix DevOps project that was created. First, go to the IBM Bluemix DevOps Services main site [here](https://hub.jazz.net/). The main page looks like this:
<p align="center">
<img src="img/jazzhub.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 35. IBM Bluemix DecOps Services main page.</p>

Locate the created project on the main page and click the gray gear icon on the top right corner of the project block. 
<p align="center">
<img src="img/devops_project.PNG"  alt="Drawing" width=400 border=0 /></p>
<p align="center">Figure 36. Opening the menu of a DevOps Services Project.</p>

With the project page open, click on the Delete tab on the left side of the page: 
<p align="center">
<img src="img/devops_project_delete.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 37. Deleting a DevOps Services project.</p>

On the next page, type out DELETE in the empty field and click CONFIRM:
<p align="center">
<img src="img/devops_delete_confirm.PNG"  alt="Drawing" width=700 border=0 /></p>
<p align="center">Figure 38. Confirm the deletion of tselected project.</p>

<br>
## License
This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](LICENSE).
