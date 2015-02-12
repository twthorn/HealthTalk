//
//  ViewController.h
//  HealthTalk
//
//  Created by Thomas Thornton on 1/14/15.
//  Copyright (c) 2015 ThomasApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenEars/OEEventsObserver.h>

@import HealthKit;

@interface TalkViewController : UIViewController <OEEventsObserverDelegate>

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) IBOutlet UIButton *talkButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end