//
//  OSLite8Controller.h
//  OSLite8
//
//  Created by BlueCocoa on 14/10/26.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface OSLite8Controller : PSListController

- (void)Clean_tmp:(PSSpecifier*)specifier;
- (void)Clean_Cache:(PSSpecifier*)specifier;
- (void)Clean_Artwork:(PSSpecifier*)specifier;
- (void)Clean_All:(PSSpecifier*)specifier;
- (void)Dont_Clean:(PSSpecifier *)specifier;
- (void)Clean_Inboxes:(PSSpecifier *)specifier;
- (void)Clean_SafeHarbor:(PSSpecifier *)specifier;
- (void)Clean_Safari_Downloads:(PSSpecifier *)specifier;
- (void)Clean_All_Extra:(PSSpecifier *)specifier;
- (void)ResetApplications:(PSSpecifier *)specifier;

@end

@interface DONOTCleanController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *array,*check,*bundleID;
@property (nonatomic, strong) NSMutableDictionary *CL;
@property (nonatomic, strong) UITableView *table;

-(void)viewDidLoad;

@end

@interface ResetController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *array,*check,*bundleID;
@property (nonatomic, strong) NSMutableDictionary *CL;
@property (nonatomic, strong) UITableView *table;

-(void)viewDidLoad;

@end