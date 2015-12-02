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
@property (weak, nonatomic) IBOutlet UITextView *text2;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.text1.inputAccessoryView = [[BOMInputHelper alloc] initForView:self.text1];
	self.text2.inputAccessoryView = [[BOMInputHelper alloc] initForView:self.text2];
}

@end
