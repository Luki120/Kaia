#import "KaiaToggle.h"


@implementation KaiaToggle {

	BOOL _selected;
	NSUserDefaults *defaults;

}


- (id)init {

	self = [super init];
	if(!self) return nil;

	defaults = [NSUserDefaults standardUserDefaults];

	[NSDistributedNotificationCenter.defaultCenter removeObserver:self name:@"didRetrieveKaiaToggleStateNotification" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(setToggleState) name:@"didRetrieveKaiaToggleStateNotification" object:nil];

	return self;

}


- (BOOL)isSelected { return [defaults boolForKey: @"kaiaToggleSelected"]; }
- (void)setSelected:(BOOL)selected {

	_selected = selected;
	[defaults setBool:_selected forKey: @"kaiaToggleSelected"];

	[self setToggleState];
	[super setSelected:selected];

}


- (void)setToggleState {

	NSDictionary *userInfo = @{ @"kaiaToggleSelected": [NSNumber numberWithBool: [defaults boolForKey: @"kaiaToggleSelected"]] };
	[NSDistributedNotificationCenter.defaultCenter postNotificationName:@"didTapHiddenCellNotification" object:nil userInfo:userInfo];

}


- (UIImage *)iconGlyph { return [UIImage systemImageNamed: @"eye"]; }
- (UIImage *)selectedIconGlyph { return [UIImage systemImageNamed:@"eye.slash"]; }
- (UIColor *)selectedColor { return UIColor.systemPurpleColor; }

@end
