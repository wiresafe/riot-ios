/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RecentsViewController.h"
#import "RoomViewController.h"

#import "RecentTableViewCell.h"

#import "RageShakeManager.h"

#import "NSBundle+MatrixKit.h"

#import "RecentsDataSource.h"

#import "VectorDesignValues.h"

#import "InviteRecentTableViewCell.h"

@interface RecentsViewController ()
{
    // Recents refresh handling
    BOOL shouldScrollToTopOnRefresh;
    
    // Selected room description
    NSString  *selectedRoomId;
    MXSession *selectedRoomSession;
    
    // Keep reference on the current room view controller to release it correctly
    RoomViewController *currentRoomViewController;
    
    // Keep the selected cell index to handle correctly split view controller display in landscape mode
    NSIndexPath *currentSelectedCellIndexPath;
    
    // display a gradient view above the tableview
    CAGradientLayer* tableViewMaskLayer;
    
    // display a button to a new room
    UIImageView* createNewRoomImageView;
}

@end

@implementation RecentsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"recents", @"Vector", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialisation
    currentSelectedCellIndexPath = nil;
    
    // Setup `MXKRecentListViewController` properties
    self.rageShakeManager = [RageShakeManager sharedManager];
    
    // The view controller handles itself the selected recent
    self.delegate = self;
    
    // Register here the customized cell view class used to render recents
    [self.recentsTableView registerNib:RecentTableViewCell.nib forCellReuseIdentifier:RecentTableViewCell.defaultReuseIdentifier];
    [self.recentsTableView registerNib:InviteRecentTableViewCell.nib forCellReuseIdentifier:InviteRecentTableViewCell.defaultReuseIdentifier];
}

- (void)dealloc
{
    [self closeSelectedRoom];
}

- (void)destroy
{
    [super destroy];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.recentsTableView.editing = editing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Deselect the current selected row, it will be restored on viewDidAppear (if any)
    NSIndexPath *indexPath = [self.recentsTableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.recentsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    if (!tableViewMaskLayer)
    {
        tableViewMaskLayer = [CAGradientLayer layer];
        
        CGColorRef opaqueWhiteColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        CGColorRef transparentWhiteColor = [UIColor colorWithWhite:1.0 alpha:0].CGColor;
        
        tableViewMaskLayer.colors = [NSArray arrayWithObjects:(__bridge id)transparentWhiteColor, (__bridge id)transparentWhiteColor, (__bridge id)opaqueWhiteColor, nil];
        
        // display a gradient to the rencents bottom (20% of the bottom of the screen)
        tableViewMaskLayer.locations = [NSArray arrayWithObjects:
                                        [NSNumber numberWithFloat:0],
                                        [NSNumber numberWithFloat:0.8],
                                        [NSNumber numberWithFloat:1.0], nil];
        
        tableViewMaskLayer.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        tableViewMaskLayer.anchorPoint = CGPointZero;
        
        // CAConstraint is not supported on IOS.
        // it seems only being supported on Mac OS.
        // so viewDidLayoutSubviews will refresh the layout bounds.
        [self.view.layer addSublayer:tableViewMaskLayer];
    }
    
    if (!createNewRoomImageView)
    {
        createNewRoomImageView = [[UIImageView alloc] init];
        [createNewRoomImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:createNewRoomImageView];
        
        createNewRoomImageView.backgroundColor = [UIColor clearColor];
        createNewRoomImageView.image = [UIImage imageNamed:@"create_room"];
        
        CGFloat side = 50.0f;
        NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:createNewRoomImageView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:side];
        
        NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:createNewRoomImageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:side];
        
        NSLayoutConstraint* centerXConstraint = [NSLayoutConstraint constraintWithItem:createNewRoomImageView
                                                      attribute:NSLayoutAttributeCenterX
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeCenterX
                                                     multiplier:1
                                                       constant:0];
        
        NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:createNewRoomImageView
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:50];
        
        if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
        {
            [NSLayoutConstraint activateConstraints:@[widthConstraint, heightConstraint, centerXConstraint, bottomConstraint]];
        }
        else
        {
            [createNewRoomImageView addConstraint:widthConstraint];
            [createNewRoomImageView addConstraint:heightConstraint];
            
            [self.view addConstraint:bottomConstraint];
            [self.view addConstraint:centerXConstraint];
        }
        
        createNewRoomImageView.userInteractionEnabled = YES;
        
        // tap -> switch to text edition
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onNewRoomPressed)];
        [tap setNumberOfTouchesRequired:1];
        [tap setNumberOfTapsRequired:1];
        [tap setDelegate:self];
        [createNewRoomImageView addGestureRecognizer:tap];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Leave potential editing mode
    [self setEditing:NO];
    
    selectedRoomId = nil;
    selectedRoomSession = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Release the current selected room (if any) except if the Room ViewController is still visible (see splitViewController.isCollapsed condition)
    // Note: 'isCollapsed' property is available in UISplitViewController for iOS 8 and later.
    if (!self.splitViewController || ([self.splitViewController respondsToSelector:@selector(isCollapsed)] && self.splitViewController.isCollapsed))
    {
        // Release the current selected room (if any).
        [self closeSelectedRoom];
    }
    else
    {
        // In case of split view controller where the primary and secondary view controllers are displayed side-by-side onscreen,
        // the selected room (if any) is highlighted.
        [self refreshCurrentSelectedCell:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // sanity check
    if (tableViewMaskLayer)
    {
        CGRect currentBounds = tableViewMaskLayer.bounds;
        CGRect newBounds = CGRectIntegral(self.view.frame);
        
        // check if there is an update
        if (!CGSizeEqualToSize(currentBounds.size, newBounds.size))
        {
            newBounds.origin = CGPointZero;
            tableViewMaskLayer.bounds = newBounds;
        }
    }
}

#pragma mark -

- (void)selectRoomWithId:(NSString*)roomId inMatrixSession:(MXSession*)matrixSession
{
    if (selectedRoomId && [selectedRoomId isEqualToString:roomId]
        && selectedRoomSession && selectedRoomSession == matrixSession)
    {
        // Nothing to do
        return;
    }
    
    selectedRoomId = roomId;
    selectedRoomSession = matrixSession;
    
    if (roomId && matrixSession)
    {
        [self performSegueWithIdentifier:@"showDetails" sender:self];
    }
    else
    {
        [self closeSelectedRoom];
    }
}

- (void)closeSelectedRoom
{
    selectedRoomId = nil;
    selectedRoomSession = nil;
    
    if (currentRoomViewController)
    {
        if (currentRoomViewController.roomDataSource)
        {
            // Let the manager release this room data source
            MXSession *mxSession = currentRoomViewController.roomDataSource.mxSession;
            MXKRoomDataSourceManager *roomDataSourceManager = [MXKRoomDataSourceManager sharedManagerForMatrixSession:mxSession];
            [roomDataSourceManager closeRoomDataSource:currentRoomViewController.roomDataSource forceClose:NO];
        }

        [currentRoomViewController destroy];
        currentRoomViewController = nil;
    }
}

#pragma mark - Internal methods

- (void)scrollToTop
{
    // Stop any scrolling effect before scrolling to the tableview top
    [UIView setAnimationsEnabled:NO];

    self.recentsTableView.contentOffset = CGPointMake(-self.recentsTableView.contentInset.left, -self.recentsTableView.contentInset.top);
    
    [UIView setAnimationsEnabled:YES];
}

- (void)refreshCurrentSelectedCell:(BOOL)forceVisible
{
    // Update here the index of the current selected cell (if any) - Useful in landscape mode with split view controller.
    currentSelectedCellIndexPath = nil;
    if (currentRoomViewController)
    {
        // Restore the current selected room id, it is erased when view controller disappeared (see viewWillDisappear).
        if (!selectedRoomId)
        {
            selectedRoomId = currentRoomViewController.roomDataSource.roomId;
            selectedRoomSession = currentRoomViewController.mainSession;
        }
        
        // Look for the rank of this selected room in displayed recents
        currentSelectedCellIndexPath = [self.dataSource cellIndexPathWithRoomId:selectedRoomId andMatrixSession:selectedRoomSession];
    }
    
    if (currentSelectedCellIndexPath)
    {
        // Select the right row
        [self.recentsTableView selectRowAtIndexPath:currentSelectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        if (forceVisible)
        {
            // Scroll table view to make the selected row appear at second position
            NSInteger topCellIndexPathRow = currentSelectedCellIndexPath.row ? currentSelectedCellIndexPath.row - 1: currentSelectedCellIndexPath.row;
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:topCellIndexPathRow inSection:currentSelectedCellIndexPath.section];
            [self.recentsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    else
    {
        NSIndexPath *indexPath = [self.recentsTableView indexPathForSelectedRow];
        if (indexPath)
        {
            [self.recentsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Keep ref on destinationViewController
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue identifier] isEqualToString:@"showDetails"])
    {
        UIViewController *controller;
        if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]])
        {
            controller = [[segue destinationViewController] topViewController];
        }
        else
        {
            controller = [segue destinationViewController];
        }
        
        if ([controller isKindOfClass:[RoomViewController class]])
        {
            // Release existing Room view controller (if any)
            if (currentRoomViewController)
            {
                if (currentRoomViewController.roomDataSource)
                {
                    // Let the manager release this room data source
                    MXSession *mxSession = currentRoomViewController.roomDataSource.mxSession;
                    MXKRoomDataSourceManager *roomDataSourceManager = [MXKRoomDataSourceManager sharedManagerForMatrixSession:mxSession];
                    [roomDataSourceManager closeRoomDataSource:currentRoomViewController.roomDataSource forceClose:NO];
                }
                
                [currentRoomViewController destroy];
                currentRoomViewController = nil;
            }
            
            currentRoomViewController = (RoomViewController *)controller;
            
            MXKRoomDataSourceManager *roomDataSourceManager = [MXKRoomDataSourceManager sharedManagerForMatrixSession:selectedRoomSession];
            MXKRoomDataSource *roomDataSource = [roomDataSourceManager roomDataSourceForRoom:selectedRoomId create:YES];
            [currentRoomViewController displayRoom:roomDataSource];
        }
        
        if (self.splitViewController)
        {
            // Refresh selected cell without scrolling the selected cell (We suppose it's visible here)
            [self refreshCurrentSelectedCell:NO];
            
            // IOS >= 8
            if ([self.splitViewController respondsToSelector:@selector(displayModeButtonItem)])
            {
                controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            }
            
            //
            controller.navigationItem.leftItemsSupplementBackButton = YES;
        }
    }
    
    // Hide back button title
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - MXKDataSourceDelegate

- (Class<MXKCellRendering>)cellViewClassForCellData:(MXKCellData*)cellData
{
    id<MXKRecentCellDataStoring> cellDataStoring = (id<MXKRecentCellDataStoring> )cellData;
    
    if (NSNotFound == [cellDataStoring.recentsDataSource.mxSession.invitedRooms indexOfObject:cellDataStoring.roomDataSource.room])
    {
        return RecentTableViewCell.class;
    }
    else
    {
        return InviteRecentTableViewCell.class;
    }
}

- (NSString *)cellReuseIdentifierForCellData:(MXKCellData*)cellData
{
    id<MXKRecentCellDataStoring> cellDataStoring = (id<MXKRecentCellDataStoring> )cellData;
    
    if (NSNotFound == [cellDataStoring.recentsDataSource.mxSession.invitedRooms indexOfObject:cellDataStoring.roomDataSource.room])
    {
        return RecentTableViewCell.defaultReuseIdentifier;
    }
    else
    {
        return InviteRecentTableViewCell.defaultReuseIdentifier;
    }
}

- (void)dataSource:(MXKDataSource *)dataSource didCellChange:(id)changes
{
    if ([dataSource isKindOfClass:[RecentsDataSource class]])
    {
        RecentsDataSource* recentsDataSource = (RecentsDataSource*)dataSource;
    
        recentsDataSource.onRoomInvitationReject = ^(MXRoom* room) {
            
            [self.recentsTableView setEditing:NO];
            
            [room leave:^{
                [self.recentsTableView reloadData];
            } failure:^(NSError *error) {
                NSLog(@"[RecentsViewController] Failed to reject an invited room (%@) failed: %@", room.state.roomId, error);
            }];

        };
        
        recentsDataSource.onRoomInvitationAccept = ^(MXRoom* room) {
            [self selectRoomWithId:room.state.roomId inMatrixSession:room.mxSession];
        };
    }

    
    [self.recentsTableView reloadData];
    
    if (shouldScrollToTopOnRefresh)
    {
        [self scrollToTop];
        shouldScrollToTopOnRefresh = NO;
    }
    
    // In case of split view controller where the primary and secondary view controllers are displayed side-by-side on screen,
    // the selected room (if any) is updated and kept visible.
    // Note: 'isCollapsed' property is available in UISplitViewController for iOS 8 and later.
    if (self.splitViewController && (![self.splitViewController respondsToSelector:@selector(isCollapsed)] || !self.splitViewController.isCollapsed))
    {
        [self refreshCurrentSelectedCell:YES];
    }
}

#pragma mark - swipe actions
static NSMutableDictionary* backgroundByImageNameDict;

- (UIColor*)getBackgroundColor:(NSString*)imageName
{
    UIColor* backgroundColor = VECTOR_LIGHT_GRAY_COLOR;
    
    if (!imageName)
    {
        return backgroundColor;
    }
    
    if (!backgroundByImageNameDict)
    {
        backgroundByImageNameDict = [[NSMutableDictionary alloc] init];
    }
    
    UIColor* bgColor = [backgroundByImageNameDict objectForKey:imageName];
    
    if (!bgColor)
    {
        CGFloat backgroundSide = 74.0;
        CGFloat sourceSide = 30.0;
        
        UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundSide, backgroundSide)];
        backgroundView.backgroundColor = backgroundColor;
        
        CGFloat offset = (backgroundSide - sourceSide) / 2.0f;
        
        UIImageView* resourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, offset, sourceSide, sourceSide)];
        resourceImageView.backgroundColor = [UIColor clearColor];
        resourceImageView.image = [MXKTools resizeImage:[UIImage imageNamed:imageName] toSize:CGSizeMake(sourceSide, sourceSide)];
        
        [backgroundView addSubview:resourceImageView];
        
        // Create a "canvas" (image context) to draw in.
        UIGraphicsBeginImageContextWithOptions(backgroundView.frame.size, NO, 0);
        
        // set to the top quality
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        [[backgroundView layer] renderInContext: UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    
        bgColor = [[UIColor alloc] initWithPatternImage:image];
        [backgroundByImageNameDict setObject:bgColor forKey:imageName];
    }
    
    return bgColor;
}

// for IOS >= 8 devices
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    
    MXRoom* room = [self.dataSource getRoomAtIndexPath:indexPath];
    
    if (room)
    {
        NSString* title = @"      ";
        
        
        // pushes settings
        BOOL isMuted = ![self.dataSource isRoomNotifiedAtIndexPath:indexPath];
        
        UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            
            [self muteRoomNotifications:!isMuted atIndexPath:indexPath];
            
        }];
        
        muteAction.backgroundColor = [self getBackgroundColor:isMuted ? @"unmute_icon" : @"mute_icon"];
        [actions insertObject:muteAction atIndex:0];
        
        // favorites management
        NSDictionary* tagsDict = [[NSDictionary alloc] init];
        
        // sanity cg
        if (room.accountData.tags)
        {
            tagsDict = [NSDictionary dictionaryWithDictionary:room.accountData.tags];
        }
    
        // get the room tag
        // use only the first one
        NSArray<MXRoomTag*>* tags = tagsDict.allValues;
        MXRoomTag* currentTag = nil;
        
        if (tags.count)
        {
            currentTag = [tags objectAtIndex:0];
        }
        
        if (!currentTag || ![kMXRoomTagFavourite isEqualToString:currentTag.name])
        {
            UITableViewRowAction* action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                
                [self updateRoomTagAtIndexPath:indexPath to:kMXRoomTagFavourite];
            }];
            
            action.backgroundColor = [self getBackgroundColor:@"favorite_icon"];
            [actions insertObject:action atIndex:0];
        }
        
        if (currentTag && ([kMXRoomTagFavourite isEqualToString:currentTag.name] || [kMXRoomTagLowPriority isEqualToString:currentTag.name]))
        {
            UITableViewRowAction* action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Std" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                
                [self updateRoomTagAtIndexPath:indexPath to:nil];
            }];
            
            action.backgroundColor = [self getBackgroundColor:nil];
            [actions insertObject:action atIndex:0];
        }
        
        if (!currentTag || ![kMXRoomTagLowPriority isEqualToString:currentTag.name])
        {
            UITableViewRowAction* action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                
                [self updateRoomTagAtIndexPath:indexPath to:kMXRoomTagLowPriority];
            }];
            
            action.backgroundColor = [self getBackgroundColor:@"low_priority_icon"];
            [actions insertObject:action atIndex:0];
        }
        
        UITableViewRowAction *leaveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:title  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self leaveRecentsAtIndexPath:indexPath];
        }];
        leaveAction.backgroundColor = [self getBackgroundColor:@"remove_icon"];
        [actions insertObject:leaveAction atIndex:0];
    }
    
    return actions;
}

- (void)leaveRecentsAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource leaveRoomAtIndexPath:indexPath];
    [self.recentsTableView setEditing:NO];
}

- (void)updateRoomTagAtIndexPath:(NSIndexPath *)indexPath to:(NSString*)tag
{
    [self.dataSource updateRoomTagAtIndexPath:indexPath to:tag];
    [self.recentsTableView setEditing:NO];
}

- (void)muteRoomNotifications:(BOOL)mute atIndexPath:(NSIndexPath*)path
{
    [self.dataSource muteRoomNotifications:mute atIndexPath:path];
    [self.recentsTableView setEditing:NO];
}


#pragma mark - MXKRecentListViewControllerDelegate

- (void)recentListViewController:(MXKRecentListViewController *)recentListViewController didSelectRoom:(NSString *)roomId inMatrixSession:(MXSession *)matrixSession
{
    // Open the room
    [self selectRoomWithId:roomId inMatrixSession:matrixSession];
}

#pragma mark - Override UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Prepare table refresh on new search session
    shouldScrollToTopOnRefresh = YES;
    
    [super searchBar:searchBar textDidChange:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Prepare table refresh on end of search
    shouldScrollToTopOnRefresh = YES;
    
    [super searchBarCancelButtonClicked: searchBar];
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [(RecentsDataSource*)self.dataSource heightForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate)
    {
        id<MXKRecentCellDataStoring> cellData = [self.dataSource cellDataAtIndexPath:indexPath];
        
        // the invited rooms cannot be selected.
        // the invitation is accepted / rejected with dedicated buttons inside the cell.
        // cell.userInteractionEnabled = NO would also disable the button so
        // the cell selection is trapped.
        if (NSNotFound == [cellData.recentsDataSource.mxSession.invitedRooms indexOfObject:cellData.roomDataSource.room])
        {
            [self.delegate recentListViewController:self didSelectRoom:cellData.roomDataSource.roomId inMatrixSession:cellData.roomDataSource.mxSession];
        }
    }
    
    // Hide the keyboard when user select a room
    // do not hide the searchBar until the view controller disappear
    // on tablets / iphone 6+, the user could expect to search again while looking at a room
    [self.recentsSearchBar resignFirstResponder];
}


#pragma mark - Actions.

- (void)onNewRoomPressed
{
    [self performSegueWithIdentifier:@"presentRoomCreationStep1" sender:self];
}

@end
