//
//  NHKeyboardAvoidingScrollView.h
//  Common
//
//  Created by Jitendra Deore on 03/04/15.
//  Copyright (c) 2015 Newshunt.com. All rights reserved.
//

/*!
 * @discussion Class to scroll the view to active textfield
               Easy to navigate between different textfields 
 * https://github.com/michaeltyson/TPKeyboardAvoiding
 */

#import <UIKit/UIKit.h>
#import "UIScrollView+NHKeyboardAvoidingAdditions.h"

@interface NHKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>

- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@end
