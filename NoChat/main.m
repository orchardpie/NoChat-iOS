//
//  main.m
//  NoChat
//
//  Created by Orchard on 3/19/14.
//  Copyright (c) 2014 Orchard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NCAppDelegate.h"
#import "NoChat.h"

int main(int argc, char * argv[])
{
    noChat = [[NoChat alloc] init];

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NCAppDelegate class]));
    }
}
