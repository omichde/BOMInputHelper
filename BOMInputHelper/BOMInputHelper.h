//
//  InputHelper.h
//  InputHelper
//
//  Created by Oliver Michalak on 26.11.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BOMInputHelper : UIView

- (instancetype) initForView:(UIView<UITextInput>*) view;

- (void) addToken: (NSString*) token;

- (void) removeToken: (NSString*) token;

@end
