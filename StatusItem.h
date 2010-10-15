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

#import <Cocoa/Cocoa.h>
#import "Host.h"

@class SFAuthorization;
@class PreferenceController;

@interface StatusItem : NSObject
{
    NSStatusItem *item;
    NSMenu *menu;
    BOOL enabled;
    PreferenceController *preferences;
    NSWindowController *about;
    NSMenuItem *hostsSeparator;
    NSMutableArray *hostsMenuItems;
}

+ (BOOL) runPrivileged: (NSString *) command arguments: (NSArray *) args;
+ (BOOL) checkHelperPermissions: (NSString *) helper;
+ (BOOL) setHelperPermissions: (NSString *) helper;
+ (BOOL) setHostActive: (Host *) host state: (BOOL) active;

- (StatusItem *) init;
- (void) createMenu;
- (NSImage *) image;
- (void) menuWillOpen: (NSMenu *) m;
- (void) hostSelected: (id) sender;
- (PreferenceController *) preferences;
- (void) showPreferences: (id) sender;
- (void) showAbout: (id) sender;

@end
