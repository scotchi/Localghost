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

@interface PreferenceController : NSWindowController
{
    NSMutableArray *hosts;
    NSInteger openOnLoginState;
    BOOL firstRun;
    IBOutlet NSArrayController *hostsController;
    IBOutlet NSButton *openOnLoginButton;
    IBOutlet NSWindow *addHostSheet;
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *portTextField;
}

@property (retain) NSArray *hosts;
@property (assign) NSInteger openOnLoginState;
@property (assign) BOOL firstRun;

- (id) init;
- (void) dealloc;
- (IBAction) addHost: (id) sender;
- (IBAction) removeHost: (id) sender;
- (IBAction) addHostOk: (id) sender;
- (IBAction) addHostCancel: (id) sender;
- (IBAction) openOnLoginClicked: (id) sender;
- (IBAction) proxyRequestsClicked: (id) sender;
- (void) save;
- (void) load;
- (void) activateHosts: (NSDictionary *) allHosts;
- (void) setOpenOnLogin: (BOOL) open;

@end
