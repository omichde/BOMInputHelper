//
//  ViewController.m
//  BOMInputHelper
//
//  Created by Oliver Michalak on 02.12.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import "ViewController.h"
#import "BOMInputHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *text1;
@property (weak, nonatomic) IBOutlet UITextField *text2;
@property (weak, nonatomic) IBOutlet UITextView *text3;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.text1.inputAccessoryView = [[BOMInputHelper alloc] initForView:self.text1];
	BOMInputHelper *helper = [[BOMInputHelper alloc] initForView:self.text2 forGroup:@"email"];
	helper.editable = NO;
	helper.liveFilter = YES;
	[helper addToken:@"everybody@mac.com"];
	[helper addToken:@"them@mac.com"];
	[helper addToken:@"you@mac.com"];
	[helper addToken:@"me@mac.com"];
	self.text2.inputAccessoryView = helper;
	self.text3.inputAccessoryView = [[BOMInputHelper alloc] initForView:self.text3];
}

@end
