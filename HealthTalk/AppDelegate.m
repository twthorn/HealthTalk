//
//  AppDelegate.m
//  HealthTalk
//
//  Created by Thomas Thornton on 1/14/15.
//  Copyright (c) 2015 ThomasApps. All rights reserved.
//

#import "AppDelegate.h"
#import "TalkViewController.h"

@import HealthKit;

@interface AppDelegate ()

@property (nonatomic, readwrite) HKHealthStore *healthStore;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc]init];
        NSSet *writeDataTypes = [self dataTypesToWrite];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:nil completion:^(BOOL success, NSError *error) {
            
            if (!success) {
                NSLog(@"User denied access to write health data");
                return;
            }
            
            NSLog(@"Setting up HealthStore VC");
            
            [self setUpHealthStoreForViewController];
            
        }];
    }
    
    return YES;
}

- (NSSet *)dataTypesToWrite {
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    // perhaps cyclcing distance
    
    HKQuantityType *carbohydratesType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *proteinType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein];
    HKQuantityType *sugarType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar];
    HKQuantityType *fatType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
    HKQuantityType *dietCaloriesType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantityType *bacType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *respiratoryRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    HKQuantityType *bodyTempType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    
    
    return [NSSet setWithObjects:weightType, heightType, carbohydratesType, proteinType, sugarType, fatType, dietCaloriesType, bacType, heartRateType, respiratoryRate, bodyTempType, nil];
}

- (void)setUpHealthStoreForViewController {
    
    TalkViewController *viewController = (TalkViewController *)[self.window rootViewController];
    viewController.healthStore = self.healthStore;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
