//
//  InputHelper.m
//  InputHelper
//
//  Created by Oliver Michalak on 26.11.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import "BOMInputHelper.h"

static NSString *kInputHelperKey = @"_BOMInputHelper";
static NSString *kInputHelperDefaultGroupName = @"_BOMInputHelperDefaultGroupName";
static CGFloat kPadding = 2;

@interface BOMInputHelper ()
@property (nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIView<UITextInput> *referenceView;
@property (nonatomic) NSString *groupName;
@property (readonly, nonatomic) UIColor *generalBackgroundColor;
@property (readonly, nonatomic) BOOL isDarkModeEnabled;
@end

@implementation BOMInputHelper

- (instancetype) initForView:(UIView<UITextInput>*) view {
  return [self initForView:view forGroup:kInputHelperDefaultGroupName];
}

- (instancetype) initForView:(UIView<UITextInput>*) view forGroup:(NSString*)groupName {
	CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30);
	if ((self = [self initWithFrame:frame])) {
		_referenceView = view;
		_groupName = groupName;
		_editable = YES;
		_liveFilter = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:self.lookupKey object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filter:) name:UITextFieldTextDidChangeNotification object:nil];
		[self update];
	}
	return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = self.generalBackgroundColor;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.scrollView];
	}
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setEditable:(BOOL)editable {
	_editable = editable;
	[self update];
}

- (NSString*) lookupKey {
  return [NSString stringWithFormat:@"%@:%@", kInputHelperKey, self.groupName];
}

- (void) update {
	for (UIView *view in self.scrollView.subviews) {
		if ([view isKindOfClass:UIButton.class])
			[view removeFromSuperview];
	}

	CGFloat viewSize = CGRectGetHeight(self.scrollView.frame);

	UIButton *addButton;
	if (self.editable) {
		addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
		addButton.frame = CGRectMake(0, 0, viewSize, viewSize);
		addButton.tintColor = [UIColor whiteColor];
		[addButton addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:addButton];
	}

	NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSArray <NSString*> *list = [[NSUserDefaults standardUserDefaults] objectForKey:self.lookupKey];
	CGFloat xPos = CGRectGetWidth(addButton.frame);
	for (NSString *token in list) {
		if (self.liveFilter) {
			NSString *string = [self.referenceView textInRange:[self.referenceView textRangeFromPosition:self.referenceView.beginningOfDocument toPosition:self.referenceView.endOfDocument]];
			if (string.length && [token rangeOfString:string].location == NSNotFound)
				continue;
		}
		
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
		button.layer.cornerRadius = (viewSize - 2 * kPadding) / 2;
		button.layer.borderColor = self.generalBackgroundColor.CGColor;
		button.layer.borderWidth = 1;
		button.backgroundColor = [UIColor grayColor];
		[button setAttributedTitle:[[NSAttributedString alloc] initWithString:token attributes:attributes] forState:UIControlStateNormal];
		CGSize textSize = [token sizeWithAttributes: attributes];
		button.frame = CGRectMake(xPos, kPadding, MIN(200, viewSize / 2 + ceil(textSize.width)), viewSize - 2 * kPadding);

		[button addTarget:self action:@selector(tokenPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:button];

		if (self.editable) {
			UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tokenLongPressed:)];
			[button addGestureRecognizer:longPress];
		}

		xPos += CGRectGetWidth(button.frame) + 2 * kPadding;
	}
	self.scrollView.contentSize = CGSizeMake(xPos, viewSize - 2 * kPadding);
}

- (void) filter:(NSNotification*)note {
	if (note.object == self.referenceView && self.liveFilter) {
		[self update];
	}
}

- (void) addPressed {
	UITextRange *range = [self.referenceView textRangeFromPosition:self.referenceView.beginningOfDocument toPosition:self.referenceView.endOfDocument];
	if (range) {
		if (!range.empty) {
			NSString *token = [self.referenceView textInRange:range];
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"Add '%@'", token] preferredStyle:UIAlertControllerStyleAlert];
			[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
			[alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self addToken:token];
			}]];
			[self.referenceView.window.rootViewController presentViewController:alert animated:YES completion:nil];
		}
	}
}

- (void) tokenPressed: (UIButton*) button {
	if (self.liveFilter) {
		[self.referenceView replaceRange:[self.referenceView textRangeFromPosition:self.referenceView.beginningOfDocument toPosition:self.referenceView.endOfDocument] withText:button.currentAttributedTitle.string];
	}
	else {
		UITextRange *range = [self.referenceView selectedTextRange];
		if (range) {
			[self.referenceView replaceRange:range withText:button.currentAttributedTitle.string];
		}
	}
}

- (void) tokenLongPressed: (UILongPressGestureRecognizer*) gesture {
	UIButton *button = (UIButton*) gesture.view;
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStatePossible:
		case UIGestureRecognizerStateChanged:
			button.layer.borderColor = [UIColor redColor].CGColor;
			break;
		case UIGestureRecognizerStateEnded: {
				NSString *token = button.currentAttributedTitle.string;
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"Delete '%@'", token] preferredStyle:UIAlertControllerStyleAlert];
				[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
				[alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
					[self removeToken:token];
				}]];
				[self.referenceView.window.rootViewController presentViewController:alert animated:YES completion:nil];
			}
			// don't break;
		default:
			button.layer.borderColor = self.generalBackgroundColor.CGColor;
	}
}

- (void) addToken: (NSString*) token {
	if (!token.length)
		return;
	NSMutableArray <NSString*> *list = [[[NSUserDefaults standardUserDefaults] objectForKey:self.lookupKey] mutableCopy];
	list = list ?: [@[] mutableCopy];
	NSUInteger pos = [list indexOfObject:token];
	if (NSNotFound == pos) {
		[list insertObject:token atIndex:0];
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:self.lookupKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:self.lookupKey object:nil];
	}
}

- (void) removeToken: (NSString*) token {
	NSMutableArray <NSString*> *list = [[[NSUserDefaults standardUserDefaults] objectForKey:self.lookupKey] mutableCopy];
	list = list ?: [@[] mutableCopy];
	NSUInteger pos = [list indexOfObject:token];
	if (NSNotFound != pos) {
		[list removeObjectAtIndex:pos];
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:self.lookupKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:self.lookupKey object:nil];
	}
}

- (UIColor*) generalBackgroundColor {
	return self.isDarkModeEnabled ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
}

- (BOOL) isDarkModeEnabled {
	if (@available(iOS 13.0, *))
		return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
	else
		return NO;
}

@end
