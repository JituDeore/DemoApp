//
//  UIScrollView+NHKeyboardAvoidingAdditions.h
//  NHKeyboardAvoidingSample
//
//  Created by Jitendra Deore on 01/04/15.
//  Copyright (c) 2015 Newshunt.com. All rights reserved.
//

/*!
 * @discussion Extended class of scrollView for handling different methods 
 * https://github.com/michaeltyson/TPKeyboardAvoiding
 */

#import <UIKit/UIKit.h>

@interface UIScrollView (NHKeyboardAvoidingAdditions)

- (BOOL)NHKeyboardAvoiding_focusNextTextField;
- (void)NHKeyboardAvoiding_scrollToActiveTextField;

- (void)NHKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification;
- (void)NHKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification;
- (void)NHKeyboardAvoiding_updateContentInset;
- (void)NHKeyboardAvoiding_updateFromContentSizeChange;
- (void)NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view;
- (UIView*)NHKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view;
-(CGSize)NHKeyboardAvoiding_calculatedContentSizeFromSubviewFrames;

@end
