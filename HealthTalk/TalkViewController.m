//
//  ViewController.m
//  HealthTalk
//
//  Created by Thomas Thornton on 1/14/15.
//  Copyright (c) 2015 ThomasApps. All rights reserved.
//

#import "TalkViewController.h"

@import HealthKit;

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>


@interface TalkViewController () {
    
//    NSString *lmValuesPath;
//    NSString *lmTypesPath;
//    
//    NSString *typesDicPath;
//    NSString *valuesDicPath;
//    
//    BOOL usingLMValues;
//    
//    NSString *typeHypothesis;
//    NSString *valueHypothesis;
    
    NSString *lmPath;
    NSString *dicPath;
    
    NSDictionary *typesDic;
    
    NSString *quantityTypeString;
    double quantityDouble;
    
    NSMutableArray *valueStringArray;
    
}

@end

@implementation TalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    valueStringArray = [[NSMutableArray alloc]init];
    
    
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
    
    
//    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
//    NSArray *phoneticTypes = [NSArray arrayWithObjects:@"WEIGHT", @"HEIGHT", nil];
//    NSArray *phoneticValues = [NSArray arrayWithObjects:@"ZERO", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN", @"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", @"HUNDRED", @"POINT", @"AND", nil];
    
//    NSArray *rawTypes = [NSArray arrayWithObjects:@"HKQuantityTypeIdentifierBodyMass", @"HKQuantityTypeIdentifierHeight", nil];
//    NSArray *rawValues = [NSArray arrayWithObjects:@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @30, @40, @50, @60, @70, @80, @90, @100, @0.0, @0, nil];
    
//    NSDictionary *typesDict = [NSDictionary dictionaryWithObjects:rawTypes forKeys:phoneticTypes];
//    NSDictionary *valuesDict = [NSDictionary dictionaryWithObjects:rawValues forKeys:phoneticValues];
    
//    NSString *typesName = @"Types";
//    NSString *valuesName = @"Values";
//    
//    NSError *typesErr = [lmGenerator generateLanguageModelFromArray:phoneticTypes withFilesNamed:typesName forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
//    NSError *valuesErr = [lmGenerator generateLanguageModelFromArray:phoneticValues withFilesNamed:valuesName forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    // Eventually remove these lines
    //NSString *lmPath = nil;
    //NSString *dicPath = nil;
    
//    if(typesErr == nil & valuesErr == nil) {
//        
//        lmTypesPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"Types"];
//        lmValuesPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"Values"];
//        
//        typesDicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"Types"];
//        valuesDicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"Values"];
//        
//    } else {
//        
//        NSLog(@"Error: %@ \n Error: %@",[typesErr localizedDescription], [valuesErr localizedDescription]);
//    
//    }
    
}

- (IBAction)talkButtonTapped:(id)sender {
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    [[OEPocketsphinxController sharedInstance] setVadThreshold:3.0];
    
    [self.talkButton setEnabled:NO];
    
//    NSLog(@"%@", self.talkButton.titleLabel.text);
//    
//    if ([self.talkButton.titleLabel.text isEqual:@"Talk"]) {
//        
//        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
//        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
//        
//        [self.talkButton setTitle:@"Stop" forState:UIControlStateNormal];
//        
//    } else {
//        
//        [[OEPocketsphinxController sharedInstance] pocketsphinxDidDetectFinishedSpeech];
//        
//        [self.talkButton setTitle:@"Talk" forState:UIControlStateNormal];
//        
//    }

}
- (IBAction)saveButtonTapped:(id)sender {
    
    HKQuantityType *thisType = [HKQuantityType quantityTypeForIdentifier:quantityTypeString];
    HKQuantity *thisQuantity = [HKQuantity quantityWithUnit:[HKUnit poundUnit] doubleValue:quantityDouble];
    
    HKQuantitySample *thisSample = [HKQuantitySample quantitySampleWithType:thisType quantity:thisQuantity startDate:[NSDate date] endDate:[NSDate date]];
    
    [self.healthStore saveObject:thisSample withCompletion:^(BOOL success, NSError *error) {
        
        if (!success) {
            NSLog(@"Failed to save this sample!");
            abort();
        } else {
            NSLog(@"Successfully saved this sample!");
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(double) valueStringArrayToDouble:(NSMutableArray *)stringArray {
    
    NSArray *onesStrings = [NSArray arrayWithObjects:@"POINT", @"ZERO", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", nil];
    NSArray *onesValues = [NSArray arrayWithObjects:@".", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    
    NSDictionary *onesDic = [NSDictionary dictionaryWithObjects:onesValues forKeys:onesStrings];
    
    NSMutableString *valueNumberString = [NSMutableString stringWithString:@""];
    
    for (NSString *word in valueStringArray) {
        
        
        if ([onesDic objectForKey:word]) {
            
            NSLog(@"a match! for %@", word);
            [valueNumberString appendString:[onesDic objectForKey:word]];
            
        }
        
    }
    
    [self.valueLabel setText:valueNumberString];
    
    double valueDouble = [valueNumberString doubleValue];
    NSLog(@"exDouble is %f", valueDouble);
    
    return valueDouble;
    
}

- (void) processHypothesis:(NSString *)hypothesis {
    
    NSArray *categoryKeys = [NSArray arrayWithObjects:@"HKQuantityTypeIdentifierBodyMass", @"HKQuantityTypeIdentifierHeight", @"HKQuantityTypeIdentifierDietaryCarbohydrates",
        @"HKQuantityTypeIdentifierDietaryProtein", @"HKQuantityTypeIdentifierDietarySugar", @"HKQuantityTypeIdentifierDietaryFatTotal", @"HKQuantityTypeIdentifierDietaryEnergyConsumed", nil];
    NSArray *categoryValues = [NSArray arrayWithObjects:@[@"WEIGHT",@"WEIGH",@"WEIGHED",@"POUNDS"], @[@"HEIGHT",@"INCHES",@"FOOT",@"FEET"], @[@"CARBS", @"CARBOHYDRATES"], @[@"PROTEIN"], @[@"SUGAR"], @[@"FAT"], @[@"CALORIES"], nil];
    
    // NO MORE CORPUS FILE , INSTEAD CREATE CATEGORY ARRAYS IN VIEW DID LOAD AND MAKE THEM FROM THEM COMBINED PLUS THE OTHER FILLER WORDS
    
    NSDictionary *categoryDic = [NSDictionary dictionaryWithObjects:categoryValues forKeys:categoryKeys];
    
    NSArray *phoneticValues = [NSArray arrayWithObjects:@"ZERO", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN", @"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", @"HUNDRED", @"POINT", @"AND", nil];
    
    quantityTypeString = nil;
    [valueStringArray removeAllObjects];
    
    NSArray *words = [hypothesis componentsSeparatedByString:@" "];
    for (NSString *word in words) {
        
        if (!quantityTypeString) {
            
            for (id key in categoryDic) {
                
                NSArray *thisCategoryArray = [categoryDic objectForKey:key];
                
                //NSLog(@"thisCategoryArray %@", thisCategoryArray);
                
                BOOL isMatch = [thisCategoryArray containsObject:word];
                
                if (isMatch) {
                    
                    //NSLog(@"Matched typeString %@", typeString);
                    
                    quantityTypeString = key;
                    [self.typeLabel setText:quantityTypeString];
                    
                    //break;
                    goto outer;
                    
                }
            }
        }
        
        if ([phoneticValues containsObject:word]) {
            
            NSLog(@"Matched value %@", word);
            
            [valueStringArray addObject:word];
            
        }
        
    outer:;
        
    }
    
    NSLog(@"val: %@, type %@", valueStringArray, quantityTypeString);
    
    quantityDouble = [self valueStringArrayToDouble:valueStringArray];
    
    [self.saveButton setEnabled:YES];
    
}





//
//    [self valueStringArrayToNumber:valueStringArray];


//            if ([[categoryDic objectForKey:key]containsString:word]) {
//
//                NSLog(@"%@", word);
//
//            }

// loop through each word of the hypothesis
// loop through category dictionary
// if word is in array (value) of the current key
// store category (key) and break
// loop through number array
// if word is in number array
// add word to numberString

// pass numberString to a function that figures out the likely val

//    if (!usingLMValues) {
//        typeHypothesis = hypothesis;
//        usingLMValues = TRUE;
//    } else {
//        valueHypothesis = hypothesis;
//    }




//    if (!usingLMValues) {
//
//        [[OEPocketsphinxController sharedInstance]changeLanguageModelToFile:lmValuesPath withDictionary:valuesDicPath];
//
//    } else {
//
//        [[OEPocketsphinxController sharedInstance]stopListening];
//
//    }



//    NSLog(@"%@", typeHypothesis);
//    NSLog(@"%@", valueHypothesis);
//
//    if (typeHypothesis != nil & valueHypothesis != nil) {
//        NSLog(@"Non null %@, %@", typeHypothesis, valueHypothesis);
//
//        self.typeLabel.text = typeHypothesis;
//        self.valueLabel.text = valueHypothesis;
//    }
//
//    [self.talkButton setEnabled:YES];




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
