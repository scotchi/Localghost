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
#import "PreferenceController.h"

#import <SecurityFoundation/SFAuthorization.h>

@implementation StatusItem

- (StatusItem *) init
{
    [super init];

    authorization = [SFAuthorization authorization];
    [authorization retain];

    enabled = NO;

    [self createMenu];
    return self;
}

- (void) createMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength:NSVariableStatusItemLength];
    [item retain];
 
    [item setTitle:NSLocalizedString(@"Localghost", @"")];
    [item setHighlightMode:YES];
    
    menu = [[NSMenu alloc] initWithTitle:@""];

    [[menu addItemWithTitle: @"Enabled" action:@selector(enable:) keyEquivalent:@""]
        setTarget: self];
    [menu addItem: [NSMenuItem separatorItem]];
    [[menu addItemWithTitle: @"Preferences..." action:@selector(showPreferences:) keyEquivalent: @""]
        setTarget: self];
    [menu addItem: [NSMenuItem separatorItem]];
    [menu addItemWithTitle: @"Quit" action:@selector(terminate:) keyEquivalent: @""];
    [item setMenu:menu];

    [menu setDelegate: self];

    hostsMenuItems = [[NSMutableArray alloc] init];
}

- (void) menuWillOpen: (NSMenu *) m
{
    for(NSUInteger i = 0; i < [hostsMenuItems count]; i++)
    {
        [menu removeItem: [hostsMenuItems objectAtIndex: i]];
    }

    [hostsMenuItems removeAllObjects];

    NSArray *hosts = [[self initPreferences] hosts];

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        NSMenuItem *menuItem = [menu addItemWithTitle: [[hosts objectAtIndex: i] name]
                                     action: @selector(enable:)
                                     keyEquivalent: @""];
        [menuItem setTarget: self];
        [hostsMenuItems addObject: menuItem];
    }
}

- (void) enable: (id) sender
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helperPath = [bundle pathForAuxiliaryExecutable: @"LocalghostHelper"];
    const char *arguments[] = { NULL, NULL, NULL };

    enabled = !enabled;

    arguments[0] = enabled ? "--enable" : "--disable";
    arguments[1] = [@"scotchi.net" UTF8String];

    AuthorizationExecuteWithPrivileges([authorization authorizationRef],
                                       [helperPath UTF8String],
                                       kAuthorizationFlagDefaults,
                                       (char * const *) arguments,
                                       NULL);
}

- (PreferenceController *) initPreferences
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
    [[self initPreferences] showWindow:self];
}

@end
