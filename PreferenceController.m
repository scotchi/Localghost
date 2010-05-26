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

#import "PreferenceController.h"
#import "Host.h"

#define PREFERENCES_FILE \
    [@"~/Library/Preferences/net.scotchi.Localghost.plist" stringByExpandingTildeInPath]

#define HOSTS_FILE \
    @"/etc/hosts"

@implementation PreferenceController

@synthesize hosts;
@synthesize openOnLoginState;
@synthesize firstRun;

- (id) init
{
    if(![super initWithWindowNibName: @"Preferences"])
    {
        return nil;
    }

    [self load];

    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (IBAction) addHost: (id) sender
{
    [NSApp beginSheet: addHostSheet
           modalForWindow: [self window]
           modalDelegate: nil
           didEndSelector: NULL
           contextInfo: NULL];
}

- (IBAction) addHostOk: (id) sender
{
    [hostsController addObject: [[Host alloc] initWithName: [addHostTextField stringValue]]];
    [self save];
    [self addHostCancel: sender];
}

- (IBAction) addHostCancel: (id) sender
{
    [NSApp endSheet: addHostSheet];
    [addHostSheet orderOut: sender];
}

- (IBAction) removeHost: (id) sender
{
    [hostsController remove: sender];
    [self save];
}

- (void) openOnLoginClicked: (id) sender
{
    [self setOpenOnLogin: ([sender state] == NSOnState)];
    openOnLoginState = [sender state];
    [self save];
}

- (void) save
{
    NSMutableArray *values = [[NSMutableArray alloc] init];

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        [values addObject: [[hosts objectAtIndex: i] name]];
    }

    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] init];
    [preferences setObject: values forKey: @"Hosts" ];
    [preferences setObject: (openOnLoginState == NSOnState ? @"1" : @"0")
                 forKey: @"OpenOnLogin"];

    if(![preferences writeToFile: PREFERENCES_FILE atomically: YES])
    {
        NSLog(@"Could not save to %s", PREFERENCES_FILE);
    }
}

- (void) load
{
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile: PREFERENCES_FILE];

    // Read the HostsList

    NSArray *values = [preferences objectForKey: @"Hosts"];
    NSMutableDictionary *hostsDict = [[NSMutableDictionary alloc] init];

    hosts = [[NSMutableArray alloc] init];

    for(NSUInteger i = 0; values && i < [values count]; i++)
    {
        NSString *name = [values objectAtIndex: i];
        Host *host = [[Host alloc] initWithName: name];
        [hosts addObject: host];
        [hostsDict setValue: host forKey: name];
    }

    [self activateHosts: hostsDict];

    // Read the OpenOnLogin preference

    firstRun = ![[preferences allKeys] containsObject: @"OpenOnLogin"];

    if(firstRun)
    {
        openOnLoginState = NSOnState;
        [self setOpenOnLogin: YES];
        [self save];
    }
    else
    {
        NSString *value = [preferences valueForKey: @"OpenOnLogin"];
        openOnLoginState = [value compare: @"1"] == NSOrderedSame ? NSOnState : NSOffState;
    }
}

- (void) activateHosts: (NSDictionary *) allHosts;
{
    NSArray *lines = [[NSString stringWithContentsOfFile: HOSTS_FILE
                                encoding: NSUTF8StringEncoding
                                error: nil]
                         componentsSeparatedByString: @"\n"];

    NSArray *keys = [allHosts allKeys];

    for(NSUInteger i = 0; i < [lines count]; i++)
    {
        NSString *line = [lines objectAtIndex: i];

        if([line length] > 0 && [line characterAtIndex: 0] != '#')
        {
            for(NSUInteger j = 0; j < [keys count]; j++)
            {
                NSString *key = [keys objectAtIndex: j];

                if([line rangeOfString: key].location != NSNotFound)
                {
                    [[allHosts objectForKey: key] setActive: YES];
                }
            }
        }
    }
}

- (void) setOpenOnLogin: (BOOL) open
{
    CFURLRef url = (CFURLRef) [NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];

    LSSharedFileListRef items =
        LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if(open)
    {
        LSSharedFileListItemRef item =
            LSSharedFileListInsertItemURL(items, kLSSharedFileListItemLast, NULL, NULL,
                                          url, NULL, NULL);
        CFRelease(item);
    }
    else
    {
        UInt32 seedValue;
        NSArray  *values = (NSArray *) LSSharedFileListCopySnapshot(items, &seedValue);

        for(NSUInteger i = 0; i < [values count]; i++)
        {
            LSSharedFileListItemRef itemRef =
                (LSSharedFileListItemRef)[values objectAtIndex: i];

            if(LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *) &url, NULL) == noErr)
            {
                NSString *urlPath = [(NSURL *) url path];

                if([urlPath compare: [[NSBundle mainBundle] bundlePath]] == NSOrderedSame)
                {
                    LSSharedFileListItemRemove(items, itemRef);
                }
            }
        }

        [values release];
    }

    CFRelease(items);
}

@end
