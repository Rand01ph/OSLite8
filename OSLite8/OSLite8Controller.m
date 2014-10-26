//
//  OSLite8Controller.m
//  OSLite8
//
//  Created by BlueCocoa on 14/10/26.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "OSLite8Controller.h"
#import "ProgressHUD.h"
#import <Preferences/PSSpecifier.h>
#import <objc/runtime.h>
#import <spawn.h>
#import <errno.h>
#import <unistd.h>
#import <sys/types.h>
#import <sys/wait.h>

#define kPrefs_Applications_Path @"/var/mobile/Containers/Data/Application/"
#define kPrefs_Applications_Real_Path @"/var/mobile/Containers/Bundle/Application/"
#define kPrefs_path @"/var/mobile/Library/Preferences/com.0xBBC.oslite8.plist"
#define kPrefs_path2 @"/var/mobile/Library/Preferences/com.0xBBC.oslite8.reset.plist"
#define kPrefs_Paths @"/var/mobile/Library/Preferences"

extern char **environ;

#pragma mark - appdata

NSDictionary * appdata(void);

NSDictionary * appdata(void){
    NSMutableDictionary * data = [NSMutableDictionary new];
    
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject * workplace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSMutableDictionary * workspaceData = [NSMutableDictionary new];
    for (NSObject * app in [workplace performSelector:@selector(allApplications)]) {
        [workspaceData setValue:[app performSelector:@selector(localizedName)] forKey:[app performSelector:@selector(applicationIdentifier)]];
    }
    
    for (NSString * appDataPath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kPrefs_Applications_Path error:nil]) {
        NSString * dataPath = [kPrefs_Applications_Path stringByAppendingFormat:@"%@/",appDataPath];
        NSString * bundleid = [dataPath stringByAppendingString:@".com.apple.mobile_container_manager.metadata.plist"];
        bundleid = [[[NSDictionary alloc] initWithContentsOfFile:bundleid] valueForKey:@"MCMMetadataIdentifier"];
        NSString * name = [workspaceData valueForKey:bundleid];
        if (name == nil || name.length == 0) name = bundleid;
        [data setValue:@{@"Name":name,@"Data":[NSString stringWithFormat:@"%@%@",kPrefs_Applications_Path,appDataPath]} forKey:bundleid];
    }
    
    return data;
}

#pragma mark - rm -rf (POSIX)

void rm(NSString *);

void rm(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="rm";
    char opt[]="-rf";
    char *args[4];
    args[0]=cmd;
    args[1]=opt;
    args[2]=(char *)[path UTF8String];
    args[3]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/rm",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - rmfile (POSIX)

void rmfile(NSString *);

void rmfile(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="rm";
    char *args[3];
    args[0]=cmd;
    args[1]=(char *)[path UTF8String];
    args[2]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/rm",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - mkdir (POSIX)

void mkdir(NSString *);

void mkdir(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="mkdir";
    char *args[3];
    args[0]=cmd;
    args[1]=(char *)[path UTF8String];
    args[2]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/mkdir",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - touch (POSIX)

void touch(NSString *);

void touch(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="touch";
    char *args[3];
    args[0]=cmd;
    args[1]=(char *)[path UTF8String];
    args[2]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/touch",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - ln -s (POSIX)

void ln(NSString *, NSString *);

void ln(NSString *source, NSString *target){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="ln";
    char opt[]="-s";
    char *args[5];
    args[0]=cmd;
    args[1]=opt;
    args[2]=(char *)[source UTF8String];
    args[3]=(char *)[target UTF8String];
    args[4]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/ln",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - chown -R mobile:mobile (POSIX)

void chown_OSLite8(NSString *);

void chown_OSLite8(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="chown";
    char *args[5];
    args[0]=cmd;
    args[1]="-R";
    args[2]="mobile:mobile";
    args[3]=(char *)[path UTF8String];
    args[4]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/usr/sbin/chown",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

#pragma mark - chmod 666 (POSIX)

void chmod_OSLite8(NSString *);

void chmod_OSLite8(NSString *path){
    posix_spawnattr_t attr;
    posix_spawn_file_actions_t fact;
    pid_t pid;
    char cmd[]="chmod";
    char *args[4];
    args[0]=cmd;
    args[1]="666";
    args[2]=(char *)[path UTF8String];
    args[3]=NULL;
    posix_spawnattr_init(&attr);
    posix_spawn_file_actions_init(&fact);
    posix_spawn(&pid,"/bin/chmod",&fact,&attr,args,environ);
    int stat=0;
    waitpid(pid,&stat,0);
}

@implementation OSLite8Controller

#pragma mark - OSLite Clean_tmp

/**
 *  OSLite - Clean_tmp:
 *
 *  @param specifier PSButtonCell
 *
 *  Clean Applictaions' tmp folders
 */

- (void)Clean_tmp:(PSSpecifier*)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        unsigned long long byte = 0;
        NSDictionary * CL = [[NSDictionary alloc] initWithContentsOfFile:kPrefs_path];
        NSDictionary * app = appdata();
        for (NSString * bundleID in app.allKeys) {
            if ([[CL valueForKey:bundleID] isEqualToString:@"YES"]) continue;
            NSString *eachApplicationTmpPath = [[[app valueForKey:bundleID] valueForKey:@"Data"] stringByAppendingString:@"/tmp"];
            setuid(0);
            byte += [self fileSizeForDir:eachApplicationTmpPath];
            rm(eachApplicationTmpPath);
            mkdir(eachApplicationTmpPath);
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

#pragma mark - OSLite Clean_Cache

/**
 *  OSLite - Clean_Cache:
 *
 *  @param specifier PSButtonCell
 *
 *  Clean Applications' Caches folders
 */

- (void)Clean_Cache:(PSSpecifier*)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        unsigned long long byte = 0;
        NSDictionary * CL = [[NSDictionary alloc] initWithContentsOfFile:kPrefs_path];
        NSDictionary * app = appdata();
        for (NSString * bundleID in app.allKeys) {
            if ([[CL valueForKey:bundleID] isEqualToString:@"YES"]) continue;
            NSString *eachApplicationCachesPath = [[[app valueForKey:bundleID] valueForKey:@"Data"] stringByAppendingString:@"/Library/Caches"];
            setuid(0);
            byte += [self fileSizeForDir:eachApplicationCachesPath];
            rm(eachApplicationCachesPath);
            mkdir(eachApplicationCachesPath);
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

#pragma mark - OSLite Clean_Artwork

/**
 *  OSLite - Clean_Artwork:
 *
 *  @param specifier PSButtonCell
 *
 *  Clean Applications' Artwork file
 */

- (void)Clean_Artwork:(PSSpecifier*)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        unsigned long long byte = 0;
        NSDictionary * CL = [[NSDictionary alloc] initWithContentsOfFile:kPrefs_path];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *applicationsFolderContents = [manager contentsOfDirectoryAtPath:kPrefs_Applications_Real_Path error:&error];
        if (error == nil) {
            for (NSString * eachApp in applicationsFolderContents) {
                NSArray * appFolderContents = [manager contentsOfDirectoryAtPath:[kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/",eachApp] error:nil];
                for (NSString * appBundle in appFolderContents) {
                    if ([appBundle hasSuffix:@".app"]) {
                        NSString * infoPath = [kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/%@/Info.plist",eachApp,appBundle];
                        NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:infoPath];
                        if (![[CL valueForKey:[dict valueForKey:@"CFBundleIdentifier"]] isEqualToString:@"YES"]) {
                            NSString * artwork = [kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/iTunesArtwork",eachApp];
                            byte += [[[manager attributesOfItemAtPath:artwork error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
                            rmfile(artwork);
                        }
                        break;
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

#pragma mark - OSLite Clean_All

/**
 *  OSLite - Clean_All:
 *
 *  @param specifier PSButtonCell
 *
 *  Clean Applications' tmp/Caches folders and Artwork file
 */

- (void)Clean_All:(PSSpecifier*)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *applicationsFolderContents = [manager contentsOfDirectoryAtPath:kPrefs_Applications_Real_Path error:&error];
        if (error == nil) {
            unsigned long long byte = 0;
            NSDictionary *CL = [[NSDictionary alloc] initWithContentsOfFile:kPrefs_path];
            NSDictionary * app = appdata();
            for (NSString * bundleID in app.allKeys) {
                if ([[CL valueForKey:bundleID] isEqualToString:@"YES"]) continue;
                
                NSString *eachApplicationTmpPath = [[[app valueForKey:bundleID] valueForKey:@"Data"] stringByAppendingString:@"/tmp"];
                setuid(0);
                byte += [self fileSizeForDir:eachApplicationTmpPath];
                rm(eachApplicationTmpPath);
                mkdir(eachApplicationTmpPath);
                
                NSString *eachApplicationCachesPath = [[[app valueForKey:bundleID] valueForKey:@"Data"] stringByAppendingString:@"/Library/Caches"];
                setuid(0);
                byte += [self fileSizeForDir:eachApplicationCachesPath];
                rm(eachApplicationCachesPath);
                mkdir(eachApplicationCachesPath);
                
                for (NSString * eachApp in applicationsFolderContents) {
                    NSArray * appFolderContents = [manager contentsOfDirectoryAtPath:[kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/",eachApp] error:nil];
                    for (NSString * appBundle in appFolderContents) {
                        if ([appBundle hasSuffix:@".app"]) {
                            NSString * infoPath = [kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/%@/Info.plist",eachApp,appBundle];
                            NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:infoPath];
                            if (![[CL valueForKey:[dict valueForKey:@"CFBundleIdentifier"]] isEqualToString:@"YES"]) {
                                NSString * artwork = [kPrefs_Applications_Real_Path stringByAppendingFormat:@"%@/iTunesArtwork",eachApp];
                                byte += [[[manager attributesOfItemAtPath:artwork error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
                                rmfile(artwork);
                            }
                            break;
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [ProgressHUD showSuccess:[self changeToProper:byte]];
            });
        }
    });
}

#pragma mark - Extra

- (void)Clean_Inboxes:(PSSpecifier*)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        unsigned long long byte = 0;
        byte += [self fileSizeForDir:@"/var/mobile/Library/Inboxes/"];
        rm(@"/var/mobile/Library/Inboxes");
        mkdir(@"/var/mobile/Library/Inboxes");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

- (void)Clean_SafeHarbor:(PSSpecifier *)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        unsigned long long byte = 0;
        byte += [self fileSizeForDir:@"/var/mobile/Library/SafeHarbor/"];
        rm(@"/var/mobile/Library/SafeHarbor");
        mkdir(@"/var/mobile/Library/SafeHarbor");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

- (void)Clean_Safari_Downloads:(PSSpecifier *)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        unsigned long long byte = 0;
        byte += [self fileSizeForDir:@"/var/mobile/Media/Downloads/"];
        rm(@"/var/mobile/Media/Downloads");
        mkdir(@"/var/mobile/Media/Downloads");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

- (void)Clean_All_Extra:(PSSpecifier *)specifier{
    [ProgressHUD show:@"Please wait..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        unsigned long long byte = 0;
        byte += [self fileSizeForDir:@"/var/mobile/Media/Downloads/"];
        byte += [self fileSizeForDir:@"/var/mobile/Library/SafeHarbor/"];
        byte += [self fileSizeForDir:@"/var/mobile/Library/Inboxes/"];
        rm(@"/var/mobile/Media/Downloads");
        mkdir(@"/var/mobile/Media/Downloads");
        rm(@"/var/mobile/Library/SafeHarbor");
        mkdir(@"/var/mobile/Library/SafeHarbor");
        rm(@"/var/mobile/Library/Inboxes");
        mkdir(@"/var/mobile/Library/Inboxes");
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [ProgressHUD showSuccess:[self changeToProper:byte]];
        });
    });
}

#pragma mark - Don't clean

- (void)Dont_Clean:(PSSpecifier *)specifier{
    DONOTCleanController *dont = [[DONOTCleanController alloc] init];
    [self pushController:dont animate:YES];
}

#pragma mark - Reset

- (void)ResetApplications:(PSSpecifier *)specifier{
    ResetController *reset = [[ResetController alloc] init];
    [self pushController:reset animate:YES];
}

#pragma mark - Converter

- (NSString *)changeToProper:(unsigned long long)byte{
    if (byte < 100) {
        return [NSString stringWithFormat:@"0KB"];
    }else if (byte < 1000) {
        return [NSString stringWithFormat:@"%lldB",byte];
    }else if (byte < 1023 * 1000){
        return [NSString stringWithFormat:@"%.2lfKB",byte/1024.0];
    }else if (byte < 1024 * 1024 * 1000){
        return [NSString stringWithFormat:@"%.2lfMB",(byte/1024.0)/1024];
    }else{
        return [NSString stringWithFormat:@"%.2lfGB",((byte/1024.0)/1024)/1024];
    }
}

-(unsigned long long)fileSizeForDir:(NSString*)path{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    unsigned long long  size =0;
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size+= fileAttributeDic.fileSize;
        }
        else
        {
            size += [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

#pragma mark - PSListController Delegate

- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = [NSMutableString stringWithFormat:@"%@.plist", *plistPath];
	else
		*plistPath = [NSMutableString stringWithFormat:@"%@/%@.plist", kPrefs_path, *plistPath];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}


- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"OSLite8" target:self];
		#if ! __has_feature(objc_arc)
		[_specifiers retain];
		#endif
	}
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[super dealloc];
}
#endif

@end

#pragma mark - Implementation Don't clean

@implementation DONOTCleanController

@synthesize array,table,check,CL,bundleID;

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.array == nil) {
        self.array = [[NSMutableArray alloc] init];
    }else{
        [self.array removeAllObjects];
    }
    if (self.check == nil) {
        self.check = [[NSMutableArray alloc] init];
    }else{
        [self.check removeAllObjects];
    }
    if (self.CL == nil) {
        self.CL = [[NSMutableDictionary alloc] init];
    }else{
        [self.CL removeAllObjects];
    }
    if (self.bundleID == nil) {
        self.bundleID = [[NSMutableArray alloc] init];
    }else{
        [self.bundleID removeAllObjects];
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:kPrefs_path]) {
        self.CL = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefs_path];
    }
    [self getAppData];
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.table setDataSource:self];
    [self.table setDelegate:self];
    [self.table setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.table];
    [self setTitle:NSLocalizedString(@"Not Clean", nil)];
}

#pragma mark - Get App Data

- (void)getAppData{
    [self performSelectorInBackground:@selector(searchApp) withObject:nil];
}

- (void)searchApp{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *applicationsFolderContents = [manager contentsOfDirectoryAtPath:kPrefs_Applications_Path error:&error];
    if (error == nil) {
        NSMutableArray *applicationCFBundleDisplayName = [[NSMutableArray alloc] init];
        NSMutableArray *applicationBundleID = [[NSMutableArray alloc] init];
        
        NSDictionary * appData = appdata();
        
        for (NSString *eachApplicationFolderPath in applicationsFolderContents) {
            NSDictionary * install_info = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@/.com.apple.mobile_container_manager.metadata.plist",kPrefs_Applications_Path,eachApplicationFolderPath]];
            
            [applicationCFBundleDisplayName addObject:[[appData valueForKey:[install_info valueForKey:@"MCMMetadataIdentifier"]] valueForKey:@"Name"]];
            
            [applicationBundleID addObject:[install_info valueForKey:@"MCMMetadataIdentifier"]];
            
            if ([[self.CL objectForKey:[install_info valueForKey:@"MCMMetadataIdentifier"]] isEqualToString:@"YES"]) {
                [self.check addObject:@"YES"];
            }else{
                [self.check addObject:@"NO"];
            }
        }
        self.bundleID = [NSMutableArray arrayWithArray:applicationBundleID];
        self.array = [NSMutableArray arrayWithArray:applicationCFBundleDisplayName];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.table reloadData];
        });
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.check removeObjectAtIndex:indexPath.row];
        [self.check insertObject:@"NO" atIndex:indexPath.row];
        [self.CL setObject:@"NO" forKey:[self.bundleID objectAtIndex:indexPath.row]];
        [self.CL writeToFile:kPrefs_path atomically:YES];
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.check removeObjectAtIndex:indexPath.row];
        [self.check insertObject:@"YES" atIndex:indexPath.row];
        [self.CL setObject:@"YES" forKey:[self.bundleID objectAtIndex:indexPath.row]];
        [self.CL writeToFile:kPrefs_path atomically:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([[self.check objectAtIndex:indexPath.row] isEqualToString:@"YES"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.textLabel setText:[self.array objectAtIndex:indexPath.row]];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString(@"Not Clean", nil);
}

@end

#pragma mark - Implementation Reset

@implementation ResetController

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.array == nil) {
        self.array = [[NSMutableArray alloc] init];
    }else{
        [self.array removeAllObjects];
    }
    if (self.check == nil) {
        self.check = [[NSMutableArray alloc] init];
    }else{
        [self.check removeAllObjects];
    }
    if (self.CL == nil) {
        self.CL = [[NSMutableDictionary alloc] init];
    }else{
        [self.CL removeAllObjects];
    }
    if (self.bundleID == nil) {
        self.bundleID = [[NSMutableArray alloc] init];
    }else{
        [self.bundleID removeAllObjects];
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:kPrefs_path2]) {
        self.CL = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefs_path2];
    }
    [self getAppData];
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.table setDataSource:self];
    [self.table setDelegate:self];
    [self.table setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.table];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(reset)]];
    [self setTitle:NSLocalizedString(@"Reset", nil)];
}

#pragma mark - Reset

- (void)reset{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
        NSDictionary * app = appdata();
        for (int i = 0; i < self.bundleID.count; i++) {
            if ([[self.check objectAtIndex:i] isEqualToString:@"YES"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [ProgressHUD show:[NSString stringWithFormat:@"Reseting %@",[self.array objectAtIndex:i]]];
                });
                NSString * dataFolder = [[app valueForKey:[self.bundleID objectAtIndex:i]] valueForKey:@"Data"];
                rm([dataFolder stringByAppendingString:@"/Documents"]);
                mkdir([dataFolder stringByAppendingString:@"/Documents"]);
                
                rm([dataFolder stringByAppendingString:@"/tmp"]);
                mkdir([dataFolder stringByAppendingString:@"/tmp"]);
                
                rm([dataFolder stringByAppendingString:@"/Library"]);
                mkdir([dataFolder stringByAppendingString:@"/Library"]);
                
                mkdir([dataFolder stringByAppendingString:@"/Library/Cookies"]);
                mkdir([dataFolder stringByAppendingString:@"/Library/Caches"]);
                mkdir([dataFolder stringByAppendingString:@"/Library/Preferences"]);
                touch([dataFolder stringByAppendingFormat:@"/Library/Preferences/%@.plist",[self.bundleID objectAtIndex:i]]);
                ln(@"/private/var/mobile/Library/Preferences/com.apple.PeoplePicker.plist",[dataFolder stringByAppendingString:@"/Library/Preferences/com.apple.PeoplePicker.plist"]);
                
                chown_OSLite8([dataFolder stringByAppendingString:@"/Documents"]);
                chown_OSLite8([dataFolder stringByAppendingString:@"/tmp"]);
                chown_OSLite8([dataFolder stringByAppendingString:@"/Library"]);
                
                chmod_OSLite8([dataFolder stringByAppendingFormat:@"/Library/Preferences/%@.plist",[self.bundleID objectAtIndex:i]]);
                
                ln(@"/private/var/mobile/Library/Preferences/.GlobalPreferences.plist",[dataFolder stringByAppendingString:@"/Library/Preferences/.GlobalPreferences.plist"]);
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ProgressHUD showSuccess:nil];
        });
    });
}

#pragma mark - Get App Data

- (void)getAppData{
    [self performSelectorInBackground:@selector(searchApp) withObject:nil];
}

- (void)searchApp{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *applicationsFolderContents = [manager contentsOfDirectoryAtPath:kPrefs_Applications_Path error:&error];
    if (error == nil) {
        NSMutableArray *applicationCFBundleDisplayName = [[NSMutableArray alloc] init];
        NSMutableArray *applicationBundleID = [[NSMutableArray alloc] init];
        
        NSDictionary * appData = appdata();
        
        for (NSString *eachApplicationFolderPath in applicationsFolderContents) {
            NSDictionary * install_info = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@/.com.apple.mobile_container_manager.metadata.plist",kPrefs_Applications_Path,eachApplicationFolderPath]];
            
            [applicationCFBundleDisplayName addObject:[[appData valueForKey:[install_info valueForKey:@"MCMMetadataIdentifier"]] valueForKey:@"Name"]];
            
            [applicationBundleID addObject:[install_info valueForKey:@"MCMMetadataIdentifier"]];
            
            if ([[self.CL objectForKey:[install_info valueForKey:@"MCMMetadataIdentifier"]] isEqualToString:@"YES"]) {
                [self.check addObject:@"YES"];
            }else{
                [self.check addObject:@"NO"];
            }
        }
        self.bundleID = [NSMutableArray arrayWithArray:applicationBundleID];
        self.array = [NSMutableArray arrayWithArray:applicationCFBundleDisplayName];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.table reloadData];
        });
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.check removeObjectAtIndex:indexPath.row];
        [self.check insertObject:@"NO" atIndex:indexPath.row];
        [self.CL setObject:@"NO" forKey:[self.bundleID objectAtIndex:indexPath.row]];
        [self.CL writeToFile:kPrefs_path2 atomically:YES];
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.check removeObjectAtIndex:indexPath.row];
        [self.check insertObject:@"YES" atIndex:indexPath.row];
        [self.CL setObject:@"YES" forKey:[self.bundleID objectAtIndex:indexPath.row]];
        [self.CL writeToFile:kPrefs_path2 atomically:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([[self.check objectAtIndex:indexPath.row] isEqualToString:@"YES"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.textLabel setText:[self.array objectAtIndex:indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString(@"Reset", nil);
}


@end