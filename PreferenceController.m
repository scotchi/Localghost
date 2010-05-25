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
    [@"~/Library/Preferences/Localghost.plist" stringByExpandingTildeInPath]

@implementation PreferenceController

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

- (void) save
{
    NSMutableArray *values = [[NSMutableArray alloc] init];

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        [values addObject: [[hosts objectAtIndex: i] name]];
    }

    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] init];
    [preferences setObject: values forKey: @"hosts" ];

    if(![preferences writeToFile: PREFERENCES_FILE atomically: YES])
    {
        NSLog(@"Could not save to %s", PREFERENCES_FILE);
    }
}

- (void) load
{
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile: PREFERENCES_FILE];
    NSArray *values = [preferences objectForKey: @"hosts"];

    hosts = [[NSMutableArray alloc] init];

    for(NSUInteger i = 0; values && i < [values count]; i++)
    {
        [hosts addObject: [[Host alloc] initWithName: [values objectAtIndex: i]]];
    }
}

@end
