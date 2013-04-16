#import "InsertDiskView.h"
#import <QuartzCore/QuartzCore.h>

@interface InsertDiskView ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation InsertDiskView

- (id)initWithFrame:(CGRect)rect
{
    if ((self = [super initWithFrame:rect]) != nil) {
        _diskFiles = @[];
        
        CGRect tableRect = CGRectMake(0.0, 32, rect.size.width, rect.size.height - 32);
        
        _table = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
        [_table setDelegate:self];
        [_table setDataSource:self];
        
        [self addSubview:_table];
        
        _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, rect.size.width, 32)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:nil];
        
        UIBarButtonItem *button = nil;
        
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(hide)];
        
        [navItem setRightBarButtonItem:button animated:NO];
        
        [_navBar pushNavigationItem:navItem animated:NO];
        
        [self addSubview:_navBar];
        
		[[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
		[[self layer] setShadowOffset:CGSizeMake(-10, 0)];
		[[self layer] setShadowRadius:5];
		[[self layer] setShadowOpacity:0.8];
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInsertDisk:) name:@"diskInserted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEjectDisk:) name:@"diskEjected" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateDisk:) name:@"diskCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_table selector:@selector(reloadData) name:@"diskIconUpdate" object:nil];
		
		_refreshControl = [[UIRefreshControl alloc] init];
		
		[_refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
		
		[[self table] addSubview:_refreshControl];
    }
    
    return self;
}

-(void)updateTable
{
	[self findDiskFiles];
	
	[[self table] reloadData];
	
	[_refreshControl endRefreshing];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:_table];
}

- (void)hide
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFrame:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGRectMake(788, 0.0, 240.0, 1024) : CGRectMake(340, 0.0, 240.0, 480)];
                     }
     
                     completion:nil];
}

- (void)show
{
    NSIndexPath *selectedRow = [_table indexPathForSelectedRow];
    
    if (selectedRow) [_table deselectRowAtIndexPath:selectedRow animated:NO];
    
    [UIView animateWithDuration:0.3
                     animations:^{
												              [self setFrame:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGRectMake(788 - 260.0, 0.0, 240.0, 1024) : CGRectMake(340 - 260, 0.0, 240.0, 480)];
                     }
     
                     completion:^(BOOL finished) {
                         [self findDiskFiles];
                         [_table reloadData];
                     }];
}

- (void)didCreateDisk:(NSNotification *)aNotification
{
    BOOL success = [[aNotification object] boolValue];
    
    if (success) {
        [self findDiskFiles];
        
        [_table reloadData];
	}
}

- (void)didEjectDisk:(NSNotification *)aNotification
{
    [_table reloadData];
}

- (void)didInsertDisk:(NSNotification *)aNotification
{
    [_table reloadData];
}

- (void)findDiskFiles
{
    _diskFiles = [self availableDiskImages];
}

- (NSArray *)availableDiskImages
{
    NSMutableArray *myDiskFiles = [NSMutableArray arrayWithCapacity:10];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *sources = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
	
    NSArray *extensions = @[@"pkg", @"PKG"];
    
    for (NSString *srcDir in sources) {
        NSArray *dirFiles = [[fm contentsOfDirectoryAtPath:srcDir error:NULL] pathsMatchingExtensions:extensions];
        
        for (NSString *filename in dirFiles) {
            [myDiskFiles addObject:[srcDir stringByAppendingPathComponent:filename]];
        }
    }
    
    return myDiskFiles;
}

- (UIImage *)iconForDiskImageAtPath:(NSString *)path
{
    
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
    NSNumber *fileSize = [fileAttrs valueForKey:NSFileSize];
    
    UIImage *iconImage = nil;
    
    if ([fileSize longLongValue] < 1440 * 1024 + 100) {
        iconImage = [UIImage imageNamed:@"DiskListFloppy.png"];
    }
    else {
        iconImage = [UIImage imageNamed:@"DiskListHD.png"];
    }
    
    return iconImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_diskFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"diskCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *diskPath = _diskFiles[[indexPath row]];
    
    [[cell imageView] setImage:[self iconForDiskImageAtPath:diskPath]];
    [[cell textLabel] setText:[diskPath lastPathComponent]];
	
	if ([[[diskPath lastPathComponent] pathExtension] isEqualToString:@".rom"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".ROM"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".img"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".IMG"] ) {
		[[cell textLabel] setTextColor:[UIColor redColor]];
	}
	
	[[cell textLabel] setTextColor:[UIColor blackColor]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *diskPath = _diskFiles[[indexPath row]];
    
	if ([[[diskPath lastPathComponent] pathExtension] isEqualToString:@".rom"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".ROM"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".img"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@".IMG"] ) {
		return UITableViewCellEditingStyleNone;
	}
	
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:diskPath]) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *diskPath = _diskFiles[[indexPath row]];
        
        if ([[NSFileManager defaultManager] removeItemAtPath:diskPath error:NULL]) {
            [self findDiskFiles];
            
            [_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *diskPath = _diskFiles[[indexPath row]];
	
	UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:indexPath];
	
	[tempCell setSelected:NO animated:YES];
	
    @try {
		if ([[[diskPath lastPathComponent] pathExtension] isEqualToString:@"rom"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@"ROM"]) {
			UIAlertView *nothing = [[UIAlertView alloc] initWithTitle:@"Nothing!" message:@"This isn't implemented yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			
			[nothing show];
		}
		
		if ([[[diskPath lastPathComponent] pathExtension] isEqualToString:@"pkg"] | [[[diskPath lastPathComponent] pathExtension] isEqualToString:@"PKG"]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"install_file" object:nil userInfo:@{@"file": diskPath}];
		}
		
        [self hide];
    }
    @catch (NSException *e) {
        NSLog(@"An exception has occured in InsertDiskView while selecting the row");
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        return indexPath;
    }
    @catch (NSException *e) {
        NSLog(@"An exception has occured in InsertDiskView when a row was about to enter the selected state");
    }
}

@end
