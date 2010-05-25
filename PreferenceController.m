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

@implementation PreferenceController

- (id) init
{
    if(![super initWithWindowNibName: @"Preferences"])
    {
        return nil;
    }

    hosts = [[NSMutableArray alloc] init];
    [hosts addObject: [[Host alloc] initWithName: @"scotchi.net"]];

    return self;
}

- (void) dealloc
{
    hosts = nil;
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
    [self addHostCancel: sender];
}

- (IBAction) addHostCancel: (id) sender
{
    [NSApp endSheet: addHostSheet];
    [addHostSheet orderOut: sender];
}

@end
