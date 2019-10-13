//
//  InputHelper.h
//  InputHelper
//
//  Created by Oliver Michalak on 26.11.15.
//  Copyright © 2015 Oliver Michalak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BOMInputHelper : UIView

/**
 * YES if the user can add/delete token on his own. If NO the tokens must be provided programmatically, default YES
 */
@property (assign, nonatomic) BOOL editable;

/**
 * YES will filter out visible entries to partially match current input, default NO
 */
@property (assign, nonatomic) BOOL liveFilter;

/**
 *	Initializes the helper view
 *	@param	view	The source view from/in which to take/save text
 */
- (instancetype) initForView:(UIView<UITextInput>*) view;

/**
 *	Initializes the helper view
 *	@param	view	The source view from/in which to take/save text
 *	@param	groupName	To save different tokens into different groups, name the group here
 */
- (instancetype) initForView:(UIView<UITextInput>*) view forGroup:(NSString*)groupName;

/**
 *	Add token to a helper
 *	@param	token	Token value
 */
- (void) addToken: (NSString*) token;

/**
 *	Remove token from a field
 *	@param	token	Token to be removed
 */
- (void) removeToken: (NSString*) token;

@end
