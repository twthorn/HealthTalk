//
//  ViewController.m
//  HealthTalk
//
//  Created by Thomas Thornton on 1/14/15.
//  Copyright (c) 2015 ThomasApps. All rights reserved.

#import "TalkViewController.h"

@import HealthKit;

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>


@interface TalkViewController () {
    
    // Open ears
    NSString *lmPath;
    NSString *dicPath;
    
    // Category Arrays
    NSArray *categoryIdentifiers;
    NSArray *categoryWordQs;
    NSArray *categoryDefaultUnits;
    NSArray *categoryDisplayNames;
    NSArray *categoryDisplayUnits;
    
    // Category result
    NSUInteger categoryIndex;
    BOOL categoryDetected;
    
    // Value Arrays
    NSArray *valueWordQsOnes;
    NSArray *valueStringsOnes;
    
    NSArray *valueWordQsTeens;
    NSArray *valueStringsTeens;
    
    NSArray *valueWordQsTens;
    NSArray *valueStringsTens;
    
    NSArray *valueWordQsAll;
    NSArray *valueStringsAll;
    
    // Value results
    NSMutableArray *valueStringArray;
    double valueDouble;
}

@end

@implementation TalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    categoryIdentifiers = [NSArray arrayWithObjects:
                           @"HKQuantityTypeIdentifierBodyMass",
                           @"HKQuantityTypeIdentifierHeight",
                           @"HKQuantityTypeIdentifierDietaryCarbohydrates",
                           @"HKQuantityTypeIdentifierDietaryProtein",
                           @"HKQuantityTypeIdentifierDietarySugar",
                           @"HKQuantityTypeIdentifierDietaryFatTotal",
                           @"HKQuantityTypeIdentifierDietaryEnergyConsumed",
                           @"HKQuantityTypeIdentifierBloodAlcoholContent",
                           @"HKQuantityTypeIdentifierHeartRate",
                           @"HKQuantityTypeIdentifierRespiratoryRate",
                           @"HKQuantityTypeIdentifierBodyTemperature", nil];
    
    categoryWordQs = [NSArray arrayWithObjects:
                      @[@"WEIGHT", @"WEIGH", @"WEIGHED", @"POUNDS"],
                      @[@"HEIGHT", @"INCHES", @"FOOT", @"FEET", @"TALL"],
                      @[@"CARBOHYDRATES", @"CARBS"],
                      @[@"PROTEIN"],
                      @[@"SUGAR"],
                      @[@"FAT"],
                      @[@"CALORIES"],
                      @[@"B.A.C.", @"BLOOD", @"ALCOHOL", @"CONTENT"],
                      @[@"PULSE", @"HEART", @"BEATS"],
                      @[@"RESPIRATORY", @"BREATHS"],
                      @[@"TEMPERATURE", @"BODY", @"FAHRENHEIT", @"DEGREES"], nil];
    
    categoryDefaultUnits = [NSArray arrayWithObjects:
                            @"lb",
                            @"in",
                            @"g",
                            @"g",
                            @"g",
                            @"g",
                            @"cal",
                            @"",
                            @"count/min",
                            @"count/min",
                            @"degF",
                            nil];
    
    categoryDisplayNames = [NSArray arrayWithObjects:
                            @"Weight",
                            @"Height",
                            @"Carbohydrates",
                            @"Protein",
                            @"Sugar",
                            @"Fat",
                            @"Calories",
                            @"Blood Alcohol Content",
                            @"Heart Rate",
                            @"Respiratory Rate",
                            @"Body Temperature", nil];
    
    categoryDisplayUnits = [NSArray arrayWithObjects:
                            @"lbs",
                            @"inches",
                            @"g",
                            @"g",
                            @"g",
                            @"g",
                            @"cal",
                            @"%",
                            @"bpm",
                            @"breaths/min",
                            @"°F", nil];
    
    valueWordQsOnes = [NSArray arrayWithObjects:@"POINT", @"ZERO", @"OH", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", nil];
    
    valueStringsOnes = [NSArray arrayWithObjects:@".", @"0", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    
    valueWordQsTeens = [NSArray arrayWithObjects:@"TEN", @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN", nil];
    
    valueStringsTeens = [NSArray arrayWithObjects:@"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", nil];
    
    valueWordQsTens = [NSArray arrayWithObjects:@"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", @"HUNDRED", @"THOUSAND", nil];
    
    valueStringsTens = [NSArray arrayWithObjects:@"20", @"30", @"40", @"50", @"60", @"70", @"80", @"90", @"100", @"1000", nil];
    
    valueStringArray = [[NSMutableArray alloc]init]; // populated with the current spoken values
    
    valueWordQsAll = [NSArray arrayWithArray:valueWordQsOnes];
    valueWordQsAll = [valueWordQsAll arrayByAddingObjectsFromArray:valueWordQsTeens];
    valueWordQsAll = [valueWordQsAll arrayByAddingObjectsFromArray:valueWordQsTens];
    
    NSLog(@"Value word q's all: %@", valueWordQsAll);
    
    valueStringsAll = [NSArray arrayWithArray:valueStringsOnes];
    valueStringsAll = [valueStringsAll arrayByAddingObjectsFromArray:valueStringsTeens];
    valueStringsAll = [valueStringsAll arrayByAddingObjectsFromArray:valueStringsTens];
    
    
    valueStringArray = [[NSMutableArray alloc]init]; // populated with the current spoken values
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSString *myCorpus = [[NSBundle mainBundle] pathForResource:@"corpus" ofType:@"txt"];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromTextFile:myCorpus withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if (err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:name];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:name];
        
    } else {
        
        NSLog(@"Failed, %@", [err localizedDescription]);
        
    }
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSLog(@"already launched");
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self helpButtonTapped:self];
    }
    
}

- (IBAction)helpButtonTapped:(id)sender {
    
    NSMutableString *instructionString = [NSMutableString stringWithString:@""];
    
    [instructionString appendString:@"Now you can tell your iPhone about yourself and your health. HealthTalk uses HealthKit to save and store your information. \n\nWhen you press talk, be sure to say a category and quantity. For example, you can say, \"weight one seventy six point three.\" \n\nSupported Categories (Units):\n"];
    
    for (int i = 0; i < [categoryDisplayNames count]; i++) {
        
        [instructionString appendString:[categoryDisplayNames objectAtIndex:i]];
        [instructionString appendString:@" ("];
        [instructionString appendString:[categoryDisplayUnits objectAtIndex:i]];
        [instructionString appendString:@")\n"];
        
    }
    
    [instructionString appendString:@"\nIf HealthTalk is having problems, minimize background noise. Try annunciating with quick pauses in between words. For the quantity, try speaking in only digits (like a phone number). For the category, make sure it is listed above and use the default units."];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Welcome to HealthTalk"
                                                                             message:instructionString
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    alertController.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self okButtonTapped];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) okButtonTapped{};

- (IBAction)talkButtonTapped:(id)sender {
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    [[OEPocketsphinxController sharedInstance] setVadThreshold:3.0];
    
    [self.talkButton setEnabled:NO];
    [self.valueLabel setText:@""];
    [self.typeLabel setText:@""];
    [self.saveButton setEnabled:NO];
    
    
}

- (IBAction)saveButtonTapped:(id)sender {
    
    // some check to make sure this won't throw an error
    
    HKQuantityType *thisType = [HKQuantityType quantityTypeForIdentifier:[categoryIdentifiers objectAtIndex:categoryIndex]];
    
    HKQuantity *thisQuantity = [HKQuantity quantityWithUnit:[HKUnit unitFromString:[categoryDefaultUnits objectAtIndex:(NSUInteger)categoryIndex]] doubleValue:valueDouble];
    
    HKQuantitySample *thisSample = [HKQuantitySample quantitySampleWithType:thisType quantity:thisQuantity startDate:[NSDate date] endDate:[NSDate date]];
    
    // fix slow alert view generation
    // reset buttons after save
    
    [self.healthStore saveObject:thisSample withCompletion:^(BOOL success, NSError *error) {
        
        if (!success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *failureAlert = [[UIAlertView alloc]initWithTitle:@"Failed Save" message:@"Your data could not be saved to the Health app. Make sure that HealthTalk has permission to save Health data in Settings under Privacy" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [failureAlert show];
                
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.valueLabel setText:@""];
                [self.typeLabel setText:@""];
                [self.saveButton setEnabled:NO];
                
                UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"Successful Save!" message:@"Data has been saved to the Health app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [successAlert show];
                
            });
            
        }
    }];
    
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) valueStringArrayToDouble:(NSMutableArray *)stringArray {
    
    NSMutableString *cumulativeValueString = [NSMutableString stringWithString:@""];
    double cumulativeValue;
    cumulativeValue = 0;
    
    bool ifWasTens = false;
    
    for (NSString *word in valueStringArray) {
        
        NSUInteger indexMatch = [valueWordQsAll indexOfObject:word];
        
        if (indexMatch != NSNotFound) {
            
            NSLog(@"This Value: %@", word);
            
            NSString *thisValueString = [valueStringsAll objectAtIndex:indexMatch];
            
            if (ifWasTens) {
                
                NSLog(@"Adding %@ to %@", thisValueString, cumulativeValueString);
                
                // "20", "5"
                // "100", "5"
                // "100", "20" -> 120, "5" -> 125
                
                cumulativeValue = cumulativeValue + [thisValueString doubleValue];
                
                // Update value string with string from value
                cumulativeValueString = [NSMutableString stringWithFormat:@"%f", cumulativeValue];
                
                NSArray *splitStringArray = [cumulativeValueString componentsSeparatedByString:@"."];
                cumulativeValueString = [NSMutableString stringWithString:[splitStringArray objectAtIndex:0]];
                
                
            } else if ([valueStringsTens containsObject:thisValueString] && [cumulativeValueString length] == 4 && [thisValueString length] == 3 && ifWasTens == false) {
                
                NSLog(@"Multiplying & Adding %@", thisValueString);
                
                // Enables thousands followed by a ones followed by hundreds to work
                
                NSString *lastNum = [cumulativeValueString substringFromIndex:[cumulativeValueString length] - 1];
                
                NSLog(@"last num: %@", lastNum);
                
                double lastValue = [lastNum doubleValue];
                
                NSLog(@"last val: %f", lastValue);
                
                cumulativeValue = cumulativeValue - lastValue + (lastValue * [thisValueString doubleValue]);
                
                NSLog(@"Resulting value is: %f", cumulativeValue);
                
                // Update value string with string from value
                cumulativeValueString = [NSMutableString stringWithFormat:@"%f", cumulativeValue];
                
                NSArray *splitStringArray = [cumulativeValueString componentsSeparatedByString:@"."];
                cumulativeValueString = [NSMutableString stringWithString:[splitStringArray objectAtIndex:0]];
              
                
            } else if ([valueStringsTens containsObject:thisValueString] && [cumulativeValueString length] != 0 && [thisValueString length] > 2) {
                
                NSLog(@"Multiplying %@", thisValueString);
                
                cumulativeValue = cumulativeValue * [thisValueString doubleValue];
                
                // Update value string with string from value
                cumulativeValueString = [NSMutableString stringWithFormat:@"%f", cumulativeValue];
                
                NSArray *splitStringArray = [cumulativeValueString componentsSeparatedByString:@"."];
                cumulativeValueString = [NSMutableString stringWithString:[splitStringArray objectAtIndex:0]];
                
                
            } else {
                
                // "." anything
                // digit sequences
                
                NSLog(@"Appending %@ to %@", thisValueString, cumulativeValueString);
                
                [cumulativeValueString appendString:thisValueString];
                
                // Update the actual value with the string's converted value
                cumulativeValue = [cumulativeValueString doubleValue];
                
            }
            
            
            // Check if the last value was a tens group one
            if ([valueStringsTens containsObject:thisValueString]) {
                
                NSLog(@"Is Tens %@", thisValueString);
                
                ifWasTens = true;
                
            } else {
                
                ifWasTens = false;
                
            }
            
            
        }
        
        // update our cumulative strings / values, bc one has been changed
        
    }
    
    // Append space before unit
    [cumulativeValueString appendString:@" "];
    
    // Append unit if the category was detected
    if (categoryDetected) {
        [cumulativeValueString appendString:[categoryDisplayUnits objectAtIndex:categoryIndex]];
    }
    
    [self.valueLabel setText:cumulativeValueString];
    
    valueDouble = [cumulativeValueString doubleValue];
    
}

- (void) processHypothesis:(NSString *)hypothesis {
    
    // Reset the global variables used
    categoryIndex = 0;
    [valueStringArray removeAllObjects];
    
    categoryDetected = false;
    
    NSArray *words = [hypothesis componentsSeparatedByString:@" "];
    for (NSString *word in words) {
        
        // Category detection
        if (!categoryDetected) {
            
            for (NSArray *wordQs in categoryWordQs) {
                
                //Check if each wordQs array has the current word
                categoryDetected = [wordQs containsObject:word];
                
                if (categoryDetected) {
                    
                    // Jump to outer, avoiding incrementation and index reset, essentially saving categoryIndex
                    goto outer;
                    
                }
                
                categoryIndex ++;
                
            }
            
            categoryIndex = 0;
            
        }
        
        // Value word detection
        if ([valueWordQsAll containsObject:word]) {
            
            [valueStringArray addObject:word];
            
        }
        
    outer:;
        
    }
    
    NSLog(@"val: %@ ", valueStringArray);
    
    if ([valueStringArray count] == 0) {
        
        [self.valueLabel setText:@"?"];
        
    } else {
        
        [self valueStringArrayToDouble:valueStringArray];
        
    }
    
    if (categoryDetected) {
        
        [self.typeLabel setText:[categoryDisplayNames objectAtIndex:(NSUInteger)categoryIndex]];
        
        if (![self.valueLabel.text isEqualToString:@"?"]) {
            [self.saveButton setEnabled:YES];
        }
        
    } else {
        
        [self.typeLabel setText:@"?"];
        
    }
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    [[OEPocketsphinxController sharedInstance]stopListening];
    [self.talkButton setEnabled:YES];
    
    [self processHypothesis:hypothesis];
    
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
    
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end