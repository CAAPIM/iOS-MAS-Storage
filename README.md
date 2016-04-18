# MASStorage

[![Build Status](https://travis-ci.org/mobile-web-messaging/MQTTKit.svg)](https://thesource.l7tech.com/thesource/Matterhorn/client-sdk/ios/trunk/Connecta)

This is the Storage framework of the MAS SDK. It is the Local Storage solution that extends classes from the MASFoundation as well as any object that comes from the NSObject class. It gives the developer the ability to create secure solutions for offline mode use cases.

This framework is part of the  **iOS CA Mobile App Services SDK.** Other frameworks in the SDK include:

- [MASFoundation](https://github-isl-01.ca.com/MAS/iOS-MAS-Foundation)
- [MASConnecta](https://github-isl-01.ca.com/MAS/iOS-MAS-Connecta)
- [MASIdentityManagement](https://github-isl-01.ca.com/MAS/iOS-MAS-IdentityManagement)

## Install By Manually Importing the Framework

1. Open your project in Xcode.
2. On your ```Project target```, go to the ```General``` tab and import the framework in the ```Embedded Binaries``` section.

## Usage

Import the `MASStorage.h` header file to any class that you want to use or to the `.pch` file if your project has one.

```
#import <MASStorage/MASStorage.h>
```

### Enable LocalStorage for the app

To enable local storage in your application, the MAS SDK needs to enable it. This following process creates the LocalStorage DB with a predefined schema.

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	//
    //Enable Local Storage in the App
    //
	[MAS enableLocalStorage];

	//
	//Start the SDK
	//
    [MAS start:nil];
    
    return YES;
}
```

### Save an Object to the Local Storage

Any object ```conforming``` to the ```NSObject``` from the Apple's Foundation framework can be saved into the local storage.

```
- (void)saveObjectMethod
{
	NSArray *myArray = @[@"pencil",@"pen"];

    [MASLocalStorage saveToLocalStorageObject:myArray 
    				  				   withKey:@"items" 
    				  				    andTag:@"officeItems" 
    				  				completion:^(BOOL success, NSError *error) {
       
       //Your code here!
    }];
}
```


### Get an Object from the Local Storage

```
- (void)getObjectMethod
{
   [MASLocalStorage getObjectFromLocalStorageUsingKey:@"items"
                                           completion:^(NSObject *object, NSString *tag, NSError *error) {
       
       NSArray *array = (NSArray *)object;
       NSLog(@"My office items are: %@",array);
       NSLog(@"Office items Tag: %@",tag);
   }];
}
```

### Delete an Object from the Local Storage

```
- (void)deleteObjectMethod
{
	[MASLocalStorage deleteObjectFromLocalStorageUsingKey:@"items"
	                                       completion:^(BOOL success, NSError *error) {
	
		//Your code here!
	}];
}
```

### Use Notifications
```
- (void)viewDidLoad
{
    [super viewDidLoad];

	    //Add Observer for Notifications from the MAS SDK
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSaveToLocalStorageNotification:)
                                                 name:MASStorageOperationDidSaveToLocalStorageNotification
                                               object:nil];

}
                                               
```

