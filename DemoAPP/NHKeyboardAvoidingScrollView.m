//
//  NHKeyboardAvoidingScrollView.m
//  Common
//
//  Created by Jitendra Deore on 03/04/15.
//  Copyright (c) 2015 Newshunt.com. All rights reserved.
//

#import "NHKeyboardAvoidingScrollView.h"

@interface NHKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation NHKeyboardAvoidingScrollView

#pragma mark - Setup/Teardown

/*!
 * @discussion This method is used to add notifications related to keyboard activities.
 * @return Void Call
 */
- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NHKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NHKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

/*!
 * @discussion Removed all the added notifications.
 * @return Void Call
 */
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

/*!
 * @discussion Setting scrollview frame.
 * @return Void Call
 */
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self NHKeyboardAvoiding_updateContentInset];
}

/*!
 * @discussion Setting scrollview content size by updating insets.
 * @return Void Call
 */
-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self NHKeyboardAvoiding_updateFromContentSizeChange];
}

/*!
 * @discussion Assign content size of scrollview based on subviews.
 * @return Void Call
 */
- (void)contentSizeToFit {
    self.contentSize = [self NHKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

/*!
 * @discussion Focus on next textfield.
 * @return Void Call
 */
- (BOOL)focusNextTextField {
    return [self NHKeyboardAvoiding_focusNextTextField];
    
}

/*!
 * @discussion Method to scroll view to avtive text field.
 * @return Void Call
 */
- (void)scrollToActiveTextField {
    return [self NHKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events
/*!
 * @discussion Method to move to superview.
 * @param newSuperview
 * @return Void Call
 */
-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ( !newSuperview ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    }
}

/*!
 * @discussion Method to dismiss keyboard on view touch.
 * @param touches Pass end touch values
 * @return Void Call
 */
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self NHKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

/*!
 * @discussion Method to dismiss keyboard on tapping return key.
 * @return Bool as Yes to resign keyboard
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    return YES;
}

/*!
 * @discussion Method to change frame of subviews based on parent view.
 * @return Void Call
 */
-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}


@end
