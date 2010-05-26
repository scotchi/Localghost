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

@implementation StatusItem

- (StatusItem *) init
{
    [super init];

    authorization = [SFAuthorization authorization];
    [authorization retain];

    [self createMenu];
    return self;
}

- (void) createMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength:NSVariableStatusItemLength];
    [item retain];
    [item setImage: [self image]];
    [item setHighlightMode: YES];
    
    menu = [[NSMenu alloc] initWithTitle:@""];


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

    NSArray *hosts = [[self initPreferences] hosts];

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
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helperPath = [bundle pathForAuxiliaryExecutable: @"LocalghostHelper"];
    const char *arguments[] = { NULL, NULL, NULL };

    NSArray *hosts = [preferences hosts];
    BOOL active = NO;

    for(NSUInteger i = 0; i < [hosts count]; i++)
    {
        Host *host = [hosts objectAtIndex: i];

        if([[sender title] compare: [host name]] == NSOrderedSame)
        {
            active = ![host active];
            [host setActive: active];
            break;
        }
    }

    arguments[0] = active ? "--enable" : "--disable";
    arguments[1] = [[sender title] UTF8String];

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
    [[self initPreferences] showWindow: self];
}

- (void) showAbout: (id) sender;
{
    [[[NSWindowController alloc] initWithWindowNibName: @"About"] showWindow: self];
}

@end
