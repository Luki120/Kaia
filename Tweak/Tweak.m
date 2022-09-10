#import "Headers/Common.h"
@import CydiaSubstrate;
@import LocalAuthentication;


@interface PXNavigationListGadget : UIViewController
@end

static BOOL isKaiaToggleSelected;

static void aheadOfYou() {

	NSString *nsFaceIDUsageDescription = @"I need your permission for this meatbag";
	NSString *nsFaceIDUsageDescriptionKey = @"NSFaceIDUsageDescription";

	NSURL *plistURL = [NSURL URLWithString: @"file:///Applications/MobileSlideShow.app/Info.plist"];
	NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfURL: plistURL];

	if(plistDict[nsFaceIDUsageDescriptionKey] != nil) return;
	[plistDict setObject:nsFaceIDUsageDescription forKey: nsFaceIDUsageDescriptionKey];
	[plistDict writeToURL:plistURL error: nil];

}

static void (*origVDL)(PXNavigationListGadget *, SEL);
static void overrideVDL(PXNavigationListGadget *self, SEL _cmd) {

	origVDL(self, _cmd);

	[NSDistributedNotificationCenter.defaultCenter removeObserver:self name:@"didTapHiddenCellNotification" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(toggleKaiaState:) name:@"didTapHiddenCellNotification" object:nil];

	[NSDistributedNotificationCenter.defaultCenter postNotificationName:@"didRetrieveKaiaToggleStateNotification" object:nil];

}

static void (*origDidSelectRowAtIndexPath)(PXNavigationListGadget *, SEL, UITableView *, NSIndexPath *);
static void overrideDidSelectRowAtIndexPath(PXNavigationListGadget *self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath) {

	if(!isKaiaToggleSelected) return origDidSelectRowAtIndexPath(self, _cmd, tableView, indexPath);

	UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
	if(![cell isKindOfClass:NSClassFromString(@"PXNavigationListCell")] || indexPath.row != 1)
		return origDidSelectRowAtIndexPath(self, _cmd, tableView, indexPath);

	[[LAContext new] evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Show yourself bozo, authenticate" reply:^(BOOL success, NSError *error) {
		if(!success && error != nil) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		else
			dispatch_async(dispatch_get_main_queue(), ^{
				origDidSelectRowAtIndexPath(self, _cmd, tableView, indexPath);
			});
	}];

}

static void new_toggleKaiaState(PXNavigationListGadget *self, SEL _cmd, NSNotification *notification) {

	NSDictionary *userInfo = notification.userInfo;
	NSNumber *kaiaToggleSelected = userInfo[@"kaiaToggleSelected"];

	isKaiaToggleSelected = kaiaToggleSelected.boolValue;

}


__attribute__((constructor)) static void init() {

	aheadOfYou();
	MSHookMessageEx(NSClassFromString(@"PXNavigationListGadget"), @selector(viewDidLoad), (IMP) &overrideVDL, (IMP *) &origVDL);
	MSHookMessageEx(NSClassFromString(@"PXNavigationListGadget"), @selector(tableView:didSelectRowAtIndexPath:), (IMP) &overrideDidSelectRowAtIndexPath, (IMP *) &origDidSelectRowAtIndexPath);

	class_addMethod(
		NSClassFromString(@"PXNavigationListGadget"),
		@selector(toggleKaiaState:),
		(IMP) &new_toggleKaiaState,
		"v@:@"
	);

}
