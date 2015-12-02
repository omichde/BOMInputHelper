//
//  InputHelper.m
//  InputHelper
//
//  Created by Oliver Michalak on 26.11.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import "InputHelper.h"

static NSString *kInputHelperKey = @"_inputHelper";
static CGFloat kPadding = 2;

@interface InputHelper ()
@property (nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIView<UITextInput> *referenceView;

@end

@implementation InputHelper

- (instancetype) initForView:(UIView<UITextInput>*) view {
	CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30);
	if ((self = [self initWithFrame:frame])) {
		self.referenceView = view;
	}
	return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor lightGrayColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.scrollView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:kInputHelperKey object:nil];
		[self update];
	}
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) update {
	for (UIView *view in self.scrollView.subviews) {
		if ([view isKindOfClass:UIButton.class])
			[view removeFromSuperview];
	}

	CGFloat viewSize = CGRectGetHeight(self.scrollView.frame);

	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	addButton.frame = CGRectMake(0, 0, viewSize, viewSize);
	addButton.tintColor = [UIColor whiteColor];
	[addButton addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollView addSubview:addButton];

	NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSArray <NSString*> *list = [[NSUserDefaults standardUserDefaults] objectForKey:kInputHelperKey];
	CGFloat xPos = CGRectGetWidth(addButton.frame);
	for (NSString *token in list) {
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
		button.layer.cornerRadius = (viewSize - 2 * kPadding) / 2;
		button.layer.borderColor = [UIColor darkGrayColor].CGColor;
		button.layer.borderWidth = 1;
		button.backgroundColor = [UIColor grayColor];
		[button setAttributedTitle:[[NSAttributedString alloc] initWithString:token attributes:attributes] forState:UIControlStateNormal];
		CGSize textSize = [token sizeWithAttributes: attributes];
		button.frame = CGRectMake(xPos, kPadding, MIN(200, viewSize / 2 + ceil(textSize.width)), viewSize - 2 * kPadding);

		[button addTarget:self action:@selector(tokenPressed:) forControlEvents:UIControlEventTouchUpInside];
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tokenLongPressed:)];
		[button addGestureRecognizer:longPress];
		[self.scrollView addSubview:button];

		xPos += CGRectGetWidth(button.frame) + 2 * kPadding;
	}
	self.scrollView.contentSize = CGSizeMake(xPos, viewSize - 2 * kPadding);
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
	UITextRange *range = [self.referenceView selectedTextRange];
	if (range) {
		[self.referenceView replaceRange:range withText:button.currentAttributedTitle.string];
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
			button.layer.borderColor = [UIColor darkGrayColor].CGColor;
	}
}

- (void) addToken: (NSString*) token {
	if (!token.length)
		return;
	NSMutableArray <NSString*> *list = [[[NSUserDefaults standardUserDefaults] objectForKey:kInputHelperKey] mutableCopy];
	list = list ?: [@[] mutableCopy];
	NSUInteger pos = [list indexOfObject:token];
	if (NSNotFound == pos) {
		[list insertObject:token atIndex:0];
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:kInputHelperKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:kInputHelperKey object:nil];
	}
}

- (void) removeToken: (NSString*) token {
	NSMutableArray <NSString*> *list = [[[NSUserDefaults standardUserDefaults] objectForKey:kInputHelperKey] mutableCopy];
	list = list ?: [@[] mutableCopy];
	NSUInteger pos = [list indexOfObject:token];
	if (NSNotFound != pos) {
		[list removeObjectAtIndex:pos];
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:kInputHelperKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:kInputHelperKey object:nil];
	}
}

@end
