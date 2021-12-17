MASStorage is the data peristence framework of the iOS Mobile SDK, which is part of CA Mobile API Gateway. It stores, manages, and accesses data in a private local and cloud.

## Features

The MASStorage framework comes with the following features:

- Encrypted data storage on device
- Secure acceess to private cloud data storage
- Stores data based on various permissions for users and apps.

## Get Started

- Check out our [documentation][docs] for sample code, video tutorials, and more.
- [Download MASStorage][download] 


## Communication

- *Have general questions or need help?*, use [Stack Overflow][StackOverflow]. (Tag 'massdk')
- *Find a bug?*, open an issue with the steps to reproduce it.
- *Request a feature or have an idea?*, open an issue.

## How You Can Contribute

Contributions are welcome and much appreciated. To learn more, see the [Contribution Guidelines][contributing].

## Installation

MASStorage supports multiple methods for installing the library in a project.

### Cocoapods (Podfile) Install

To integrate MASStorage into your Xcode project using CocoaPods, specify it in your **Podfile:**

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '14.0'

pod 'MASStorage'
```
Then, run the following command using the command prompt from the folder of your project:

```
$ pod install
```

### Manual Install

For manual install, you add the Mobile SDK to your Xcode project. Note that you must add the MASFoundation library. For complete MAS functionality, install all of the MAS libraries as shown.

1. Open your project in Xcode.
2. Drag the SDK library files, and drop them into your project in the left navigator panel in Xcode. Select the option, `Copy items if needed`.
3. Select `File->Add files to 'project name'` and add the msso_config.json file from your project folder.
4. In Xcode "Build Setting” of your Project Target, add `-ObjC` for `Other Linker Flags`.
5. Import the following Mobile SDK library header file to the classes or to the .pch file if your project has one.

```
#import <MASFoundation/MASFoundation.h>
#import <MASStorage/MASStorage.h>
```

## Usage

### Storage (Local)

Store/Retrieve local data is done using different permission types. You control permissions using the following enumeration values for the MASLocalStorageSegment:

- **MASLocalStorageSegmentApplication**
  This segment is used to store data pertinent only to the Application. For example, you can store the application configuration. Data stored here is shared across users within the app. 

- **MASLocalStorageSegmentApplicationForUser** 
  This segment is used to store data pertinent to a specific user within the app. For example, in a game app, you can store the user game score or user game state.
  
##### Enable local storage for the app

To start using local storage in your app, the SDK needs to enable it. The following process creates the LocalStorage DB with a predefined schema.

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //
    // Enable Local Storage in the App
    //
    [MAS enableLocalStorage];

    //
    // Start the SDK
    //
    [MAS start:nil];

    return YES;
}
```

##### Save an object to local storage

Any object conforming to `NSData` or `NSString` can be saved into the local storage.

```
- (void)saveObjectMethod
{
    NSString *myObject = @"someString";
    NSString *key = @"someKey";
    NSString *type = @"objectType";

    //
    // Save object to Local Storage
    //
    [MASLocalStorage saveObject:myObject withKey:key type:type mode:MASLocalStorageSegmentApplication completion:^(BOOL success, NSError *error) {
        
        //Your code here
    }];
}
```

##### Save an object to local storage using encryption

Using encryption, saves any object conforming to `NSData` or `NSString`. It uses a password, that is set by parameter in the method, to encrypt the object before saving it in the local storage.

```
- (void)saveEncryptedObjectMethod
{
    NSString *myObject = @"someString";
    NSString *key = @"someKey";
    NSString *type = @"objectType";

    //
    // Save object to Local Storage
    //
    [MASLocalStorage saveObject:myObject withKey:key type:type mode:MASLocalStorageSegmentApplication password:@"S0m3Pwd!" completion:^(BOOL success, NSError *error) {

        
        //Your code here
    }];
}
```

##### Find an object from local storage

```
- (void)findObjectMethod
{
    //
    // Find Local Storage Data
    //
    [MASLocalStorage findObjectUsingKey:key mode:MASLocalStorageSegmentApplication completion:(void (^)(MASObject *object, NSError *error))completion; {
        
        //Your code here
    }];
}
```

##### Delete an object from local storage

```
- (void)deleteObjectMethod
{
    //
    // Delete object from local storage
    //
    [MASLocalStorage deleteObjectUsingKey:key mode:MASLocalStorageSegmentApplication completion:^(BOOL success, NSError *error) {
        
        //Your code here
    }];
}
```

##### Retrieve all objects from local storage

```
- (void)findObjectsMethod
{
    //
    // Find all Local Storage Data by Mode
    //
    [MASLocalStorage findObjectsUsingMode:MASLocalStorageSegmentApplication completion:^(NSArray *objects, NSError *error) {
        
        //Your code here
    }];
}
```

##### Use notifications

```
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Add Observer for Notifications from the Mobile SDK
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSaveToLocalStorageNotification:)
                                                 name:MASStorageOperationDidSaveToLocalStorageNotification
                                               object:nil];

}
                                               
```

### Storage (Cloud)

Store/Retrieve cloud data is done using different permission types. You control permissions using the following enumeration values for the MASLocalStorageSegment:

- **MASCloudStorageSegmentUser**
  This segment is used to store data pertinent only to a specific user. For example, if you want to extend the SCIM user profile. Data stored using this segment can be accessed by the same user via different apps. 
  
- **MASCloudStorageSegmentApplication**
  This segment is used to store data pertinent only to the Application. For example, you can store the application configuration. Data stored here is shared across users within the app. 

- **MASCloudStorageSegmentApplicationForUser** 
  This segment is used to store data pertinent to a specific user within the app. For example, in a game app, you can store the user game score or user game state.
  
##### Save an object to cloud storage

Any object conforming to `NSDate` or `NSString` can be saved into the cloud storage.

```
- (void)saveObjectMethod
{
    NSString *myObject = @"someString";
    NSString *key = @"someKey";
    NSString *type = @"objectType";

    //
    // Save object to Cloud Storage
    //
    [MASCloudStorage saveObject:myObject withKey:key type:type mode:MASCloudStorageSegmentApplication completion:^(BOOL success, NSError *error) {
        
        //Your code here
    }];
}
```

##### Find an object from cloud storage

```
- (void)findObjectMethod
{
    //
    // Find Cloud Storage Data
    //
    [MASCloudStorage findObjectUsingKey:key mode:MASCloudStorageSegmentApplication completion:(void (^)(MASObject *object, NSError *error))completion; {
        
        //Your code here
    }];
}
```

##### Delete an object from cloud storage

```
- (void)deleteObjectMethod
{
    //
    // Delete object from Cloud Storage
    //
    [MASCloudStorage deleteObjectUsingKey:key mode:MASCloudStorageSegmentApplication completion:^(BOOL success, NSError *error) {
        
        //Your code here
    }];
}
```

##### Retrieve all objects from cloud storage

```
- (void)findObjectsMethod
{
    //
    // Find all Cloud Storage Data by Mode
    //
    [MASCloudStorage findObjectsUsingMode:MASCloudStorageSegmentApplication completion:^(NSArray *objects, NSError *error) {
        
        //Your code here
    }];
}
```


## License

Copyright (c) 2019 Broadcom. All Rights Reserved.
The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.

This software may be modified and distributed under the terms
of the MIT license. See the [LICENSE][license-link] file for details.


 [techdocs.broadcom.com]: http://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/mobile-sdk-for-ca-mobile-api-gateway/2-2.html
 [get-started]: http://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/mobile-sdk-for-ca-mobile-api-gateway/2-2.html
 [docs]: http://techdocs.broadcom.com/content/broadcom/techdocs/us/en/ca-enterprise-software/layer7-api-management/mobile-sdk-for-ca-mobile-api-gateway/2-2.html
 [StackOverflow]: http://stackoverflow.com/questions/tagged/massdk
 [download]: https://github.com/CAAPIM/iOS-MAS-Storage/archive/master.zip
 [contributing]: https://github.com/CAAPIM/iOS-MAS-Storage/blob/develop/CONTRIBUTING.md
 [license-link]: /LICENSE
