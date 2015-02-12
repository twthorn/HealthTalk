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
    
//    NSDictionary *typesDic;
    
//    NSString *quantityTypeString;
    
//    NSDictionary *categoryDic;
    
    //olf stuff above
    
    
    
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
    NSDictionary *valueStringsOnesDic;
    
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
    
    NSArray *valueStringTwos = [NSArray arrayWithObjects:@"TEN", @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN", nil];
    
    NSArray *valueStringTens = [NSArray arrayWithObjects:@"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", nil];
    
    /* combo types
     
     cases:
     - each number word adds one character to the string
     
     ... _thou_ _hund_ _tens_ _ones_ . _tenths_ _hundredths_ _thousandths_ ...
    - every number direct string equivalent ("." "0" "10" "16" "20" "2")
    = next number is
     - appended if place value is greater or equal
    for each number
     have two things
     - this number word
        - value equivalent
        - place
     - current number string
        - length
        - 
     
     start:
     - ones
     
     thousands hundred
     
     ones
     - !
     - ones...
        - tens
            - !
            -
     
     */
    
    // array with every number value (one, eleven, forty, hundred)
    // dictionary with their first digit value (1, 11, 4, 1)
    // dictionary with the digits places left (0, 0, 1, 2)
    // count the numbers that fill before a point
    // if the count doesn't equal then add a zero for the remainder
        // doesn't work need to differentiate between "one thousand and four" and "one thousand four hundred"
    
    // each number has a value
        // thousand = 3, four = 1, hundred = 2, forty = 2
    // once a number is deteceted (one hundred) subtract the next numbers value from it (and one) so (2 - 1) the remainder, if positive, is the number of zeroes added before the next number (2 -1 = 1) so add 1 zero, then add the one (101)
    // number detected (one) next number (thousand) means (1 - 3 = -2) no zeroes added just put the 1, check next numbers
            // forty means (3 - 2) = 1, so 104
                // two means (2 - 1) = 1 so 1040 BUT IT SHOULD BE 1042
    
    // to fix the system, add another case: if the remainder is greater than the value of the next number, then add a zero, but if it is equal then add that number
    // so first number "one" remember it, next number "thousand" subtract (1 - 3 = -2) , is -2 greater than 3, no, so append "1" to value string
        // next number "forty" so (3 - 2 = 1) append "0"
            // next "four" so (2 - 1 = 1) append
        // next number "four" so (3 - 1 = 2) is 2 > 1, yes, append
    // next number
    
    
    
    // thousand = 3, hundred = 2, forty = 1, eleven = 0, one = 0
    // "one", append 1
        // "thousand" -> 0 - 3 = -3, neg no zeroes added
            // nothing -> 3 - 0 = 3, append 3 "0"'s
            // five -> 3 - 0 = 3, append
        // "forty" -> 0 - 1 = -1, neg no zeroes added, append 4
            // nothing -> 1 - 0 = 1, positive, append 1 zero
    
    
    
    // thousand = 3, hundred = 2, forty = 1, eleven = 2, one = 1, nothing = 0
    // "one", append 1
        // "thousand" -> var = 3
            // nothing -> append var = 3 "0"'s
                // output: 1000
            // five -> var - 1 = 2, append 2 "0"'s, append this number = 5
                // output: 1005
        // "hundred" -> var = 2
            // forty -> var - 1 = 1, append 4
                // nothing -> append 1 "0"
        // "forty" -> var = 2, append 4
            // "five" -> var - 1 = 1
            // nothing -> append var = 2 zeroes
    
    // var subtraction is relative to the length of the string
    // one, "1", thousand, 4 -1 = 3, 1000
    // one, "1", thousand 4 -1 = 3, "four", 3 - 1 = 2, 2 0's then 4, 1004
    // one "1", forty, 2-1, 1, 1 0's 140
    // one "1", hundred 3-1 = 2
    // forty "4", five 1 - 1 = 0, 45
    // one "1", forty "4"
    
    valueStringsOnesDic = [NSDictionary dictionaryWithObjects:valueStringsOnes forKeys:valueWordQsOnes];
    
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

- (IBAction)helpButtonTapped:(id)sender {
    
    NSMutableString *instructionString = [NSMutableString stringWithString:@""];
    
    [instructionString appendString:@"Now you can tell your iPhone about yourself and your health. View the data and visualizations by pressing Home and tapping the Apple Health app. \n\nWhen you press Talk, speak a category and a quantity. For example, you can say \"Weight one forty five point six\" \n\nThese are the possible categories (and units):\n"];
    
    for (int i = 0; i < [categoryDisplayNames count]; i++) {
        
        [instructionString appendString:[categoryDisplayNames objectAtIndex:i]];
        [instructionString appendString:@" ("];
        [instructionString appendString:[categoryDisplayUnits objectAtIndex:i]];
        [instructionString appendString:@")\n"];
        
    }
    
    [instructionString appendString:@"\nFor quantity, only speak the digits:\nzero\none\ntwo\nthree\nfour\nfive\nsix\nseven\neight\nnine \n\n You can add a decimal point for accuracy too"];
    
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
                
                UIAlertView *failureAlert = [[UIAlertView alloc]initWithTitle:@"Failed Save" message:@"Your data could not be saved to the Apple Health app. Make sure that HealthTalk has permission to save Health data in Settings -> Privacy -> Health." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
                [failureAlert show];
                
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.valueLabel setText:@""];
                [self.typeLabel setText:@""];
                [self.saveButton setEnabled:NO];
                
                UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"Successful Save!" message:@"You can view, edit, or delete your saved Health data in the Apple Health app. Apple Health also creates graphs of your data over time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [successAlert show];
                
            });
            
        }
    }];

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) valueStringArrayToDouble:(NSMutableArray *)stringArray {
    
    NSMutableString *valueNumberString = [NSMutableString stringWithString:@""];
    
    for (NSString *word in valueStringArray) {
        
        NSString *isMatch = [valueStringsOnesDic objectForKey:word];
        
        if (isMatch) {
            
            NSLog(@"Matched value: %@", word);
            
            [valueNumberString appendString:isMatch];
            
        }
        
    }
    
    // Append space before unit
    [valueNumberString appendString:@" "];
    
    // Append unit if the category was detected
    if (categoryDetected) {
        [valueNumberString appendString:[categoryDisplayUnits objectAtIndex:categoryIndex]];
    }
    
    [self.valueLabel setText:valueNumberString];
    
    valueDouble = [valueNumberString doubleValue];
    
}

- (void) processHypothesis:(NSString *)hypothesis {
    
    // NO MORE CORPUS FILE , INSTEAD CREATE CATEGORY ARRAYS IN VIEW DID LOAD AND MAKE THEM FROM THEM COMBINED PLUS THE OTHER FILLER WORDS
    
//    NSArray *phoneticValues = [NSArray arrayWithObjects:@"ZERO", @"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN", @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN", @"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", @"HUNDRED", @"POINT", @"AND", nil];
    
    //
    
    //quantityTypeString = nil;
    
    
    
    
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
        
        // Value detection
        if ([valueWordQsOnes containsObject:word]) {
            
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
    
    
    
//    if (([valueStringArray count] != 0) & categoryDetected) {
//        
//        // Sets value label in function
//        [self valueStringArrayToDouble:valueStringArray];
//        [self.typeLabel setText:[categoryDisplayNames objectAtIndex:(NSUInteger)categoryIndex]];
//        [self.saveButton setEnabled:YES];
//        
//    } else if ([valueStringArray count] == 0) {
//        
//        [self.valueLabel setText:@"?"];
//        [self.typeLabel setText:[categoryDisplayNames objectAtIndex:(NSUInteger)categoryIndex]];
//        // alert view
//        
//    } else if (!categoryDetected) {
//        
//        [self.typeLabel setText:@"?"];
//        [self valueStringArrayToDouble:valueStringArray];
//        
//    }
    
}





//
//    [self valueStringArrayToNumber:valueStringArray];


//            if ([[categoryDic objectForKey:key]containsString:word]) {
//
//                NSLog(@"%@", word);
//
//            }

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
