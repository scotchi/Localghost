/*
 * Copyright 2010 Scott Wheeler <wheeler@kde.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "StatusItem.h"
#import "Host.h"
#import "PreferenceController.h"

#import <SecurityFoundation/SFAuthorization.h>

#define BUFFER_SIZE 512

@implementation StatusItem

static SFAuthorization *authorization = nil;

+ (BOOL) runPrivilegedHelper: (NSString *) command arguments: (NSArray *) args
{
    const char **arguments = calloc([args count] + 1, sizeof(char *));

    for(NSUInteger i = 0; i < [args count]; i++)
    {
        arguments[i] = [[args objectAtIndex: i] UTF8String];
    }

    if(!authorization)
    {
        authorization = [SFAuthorization authorization];
        [authorization retain];
    }

    FILE *status = NULL;
    OSStatus authStatus;
    BOOL success = YES;

    authStatus = AuthorizationExecuteWithPrivileges([authorization authorizationRef],
                                                    [command UTF8String],
                                                    kAuthorizationFlagDefaults,
                                                    (char * const *) arguments,
                                                    &status);

    if(authStatus == errAuthorizationSuccess)
    {
        char line[BUFFER_SIZE];

        while (status && fgets(line, BUFFER_SIZE, status))
        {
            NSString *output = [NSString stringWithUTF8String: line];
            NSString *find = [NSString string];
            NSScanner *scanner = [NSScanner scannerWithString: output];

            if([scanner scanString: @"Could not open" intoString: &find])
            {
                success = NO;
            }

            [find release];
            [output release];
            [scanner release];

            if(!success)
            {
                break;
            }
        }
    }
    else
    {
        success = NO;
    }

    free(arguments);
    fclose(status);
    return success;
}

- (StatusItem *) init
{
    [super init];
    [self createMenu];

    if([[self preferences] firstRun])
    {
        [self showPreferences: self];
    }

    return self;
}

- (void) createMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength:NSVariableStatusItemLength];
    [item retain];
    [item setImage: [self image]];
    [item setHighlightMode: YES];

    menu = [[NSMenu alloc] initWithTitle: @""];


    [[menu addItemWithTitle: @"About Localghost"
           action:@selector(showAbout:)
           keyEquivalent: @""]
        setTarget: self];

    [menu addItem: [NSMenuItem separatorItem]];

    hostsSeparator = [NSMenuItem separatorItem];
    [menu addItem: hostsSeparator];

    [[menu addItemWithTitle: @"Preferences..."
           action:@selector(showPreferences:)
           keyEquivalent: @""]
        setTarget: self];

    [menu addItem: [NSMenuItem separatorItem]];

    [menu addItemWithTitle: @"Quit"
          action:@selector(terminate:)
          keyEquivalent: @""];

    [item setMenu:menu];
    [menu setDelegate: self];

    hostsMenuItems = [[NSMutableArray alloc] init];
}

- (NSImage *) image
{
    NSImage *image = [[NSImage imageNamed: @"Localghost.icns"] copy];

    NSSize size;
    size.height = 22;
    size.width = 22;

    [image setSize: size];

    return image;
}

- (void) menuWillOpen: (NSMenu *) m
{
    for(NSUInteger i = 0; i < [hostsMenuItems count]; i++)
    {
        [menu removeItem: [hostsMenuItems objectAtIndex: i]];
    }

    [hostsMenuItems removeAllObjects];

    NSArray *hosts = [[self preferences] hosts];

    [hostsSeparator setHidden: [hosts count] == 0];

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        Host *host = [hosts objectAtIndex: i];
        NSMenuItem *menuItem = [menu insertItemWithTitle: [host name]
                                     action: @selector(hostSelected:)
                                     keyEquivalent: @""
                                     atIndex: [menu indexOfItem: hostsSeparator]];
        NSInteger state = [host active] ? NSOnState : NSOffState;
        [menuItem setState: state];
        [menuItem setTarget: self];
        [hostsMenuItems addObject: menuItem];
    }
}

- (void) hostSelected: (id) sender
{
    Host *host;
    NSArray *hosts = [preferences hosts];
    BOOL active = NO;

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        host = [hosts objectAtIndex: i];
        if([[sender title] compare: [host name]] == NSOrderedSame)
        {
            active = ![host active];
            break;
        }
    }

    NSString *helper =
        [[NSBundle mainBundle] pathForAuxiliaryExecutable: @"LocalghostHelper"];
    NSArray *arguments =
        [NSArray arrayWithObjects: (active ? @"--enable" : @"--disable"), [sender title], nil];

    if([StatusItem runPrivilegedHelper: helper arguments: arguments])
    {
        [host setActive: active];
    }
}

- (PreferenceController *) preferences
{
    if(!preferences)
    {
        preferences = [[PreferenceController alloc] init];
        [preferences retain];
    }

    return preferences;
}

- (void) showPreferences: (id) sender
{
    [[self preferences] showWindow: self];
    [NSApp activateIgnoringOtherApps: YES];
}

- (void) showAbout: (id) sender;
{
    if(!about)
    {
        about = [[NSWindowController alloc] initWithWindowNibName: @"About"];
        [about retain];
    }

    [about showWindow: self];
    [NSApp activateIgnoringOtherApps: YES];
}

@end
