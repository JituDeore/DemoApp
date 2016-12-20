//
//  UIScrollView+NHKeyboardAvoidingAdditions.m
//  NHKeyboardAvoidingSample
//
//  Created by Jitendra Deore on 01/04/15.
//  Copyright (c) 2015 Newshunt.com. All rights reserved.
//

#import "UIScrollView+NHKeyboardAvoidingAdditions.h"
#import "NHKeyboardAvoidingScrollView.h"
#import <objc/runtime.h>

static const CGFloat kCalculatedContenNHadding = 10;
static const CGFloat kMinimumScrollOffseNHadding = 20;

static const int kStateKey;

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#define fequal(a,b) (fabs((a) - (b)) < DBL_EPSILON)


@interface NHKeyboardAvoidingState : NSObject
@property (nonatomic, assign) UIEdgeInsets priorInset;
@property (nonatomic, assign) UIEdgeInsets priorScrollIndicatorInsets;
@property (nonatomic, assign) BOOL         keyboardVisible;
@property (nonatomic, assign) CGRect       keyboardRect;
@property (nonatomic, assign) CGSize       priorContentSize;


@property (nonatomic) BOOL priorPagingEnabled;
@end

@implementation UIScrollView (NHKeyboardAvoidingAdditions)

/*!
 * @discussion Method used to get the current state of keyboard.
 * @return NHKeyboardAvoidingState Call
 */
- (NHKeyboardAvoidingState*)keyboardAvoidingState {
    NHKeyboardAvoidingState *state = objc_getAssociatedObject(self, &kStateKey);
    if ( !state ) {
        state = [[NHKeyboardAvoidingState alloc] init];
        objc_setAssociatedObject(self, &kStateKey, state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
        [state release];
#endif
    }
    return state;
}

/*!
 * @discussion Method used to prepared view to be scrolled as keyboard will show.
 * @param notification Pass current notification
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardRect)) {
        return;
    }
    
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    UIView *firstResponder = [self NHKeyboardAvoiding_findFirstResponderBeneathView:self];
    
    if ( !firstResponder ) {
        return;
    }
    
    state.keyboardRect = keyboardRect;
    
    if ( !state.keyboardVisible ) {
        state.priorInset = self.contentInset;
        state.priorScrollIndicatorInsets = self.scrollIndicatorInsets;
        state.priorPagingEnabled = self.pagingEnabled;
    }
    
    state.keyboardVisible = YES;
    self.pagingEnabled = NO;
        
    if ( [self isKindOfClass:[NHKeyboardAvoidingScrollView class]] ) {
        state.priorContentSize = self.contentSize;
        
        if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
            // Set the content size, if it's not set. Do not set content size explicitly if auto-layout
            // is being used to manage subviews
            self.contentSize = [self NHKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
        }
    }
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    self.contentInset = [self NHKeyboardAvoiding_contentInsetForKeyboard];
    
    CGFloat viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    [self setContentOffset:CGPointMake(self.contentOffset.x,
                                       [self NHKeyboardAvoiding_idealOffsetForView:firstResponder
                                                             withViewingAreaHeight:viewableHeight])
                  animated:NO];
    
    self.scrollIndicatorInsets = self.contentInset;
    [self layoutIfNeeded];
    
    [UIView commitAnimations];
}

/*!
 * @discussion Method to reposition view based on keyboard dismissal.
 * @param notification Pass notification related to keyboard state
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification {
    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardRect)) {
        return;
    }
    
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if ( !state.keyboardVisible ) {
        return;
    }
    
    state.keyboardRect = CGRectZero;
    state.keyboardVisible = NO;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    if ( [self isKindOfClass:[NHKeyboardAvoidingScrollView class]] ) {
        self.contentSize = state.priorContentSize;
    }
    
    self.contentInset = state.priorInset;
    self.scrollIndicatorInsets = state.priorScrollIndicatorInsets;
    self.pagingEnabled = state.priorPagingEnabled;
	[self layoutIfNeeded];
    [UIView commitAnimations];
}

/*!
 * @discussion Method to update content inset.
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_updateContentInset {
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if ( state.keyboardVisible ) {
        self.contentInset = [self NHKeyboardAvoiding_contentInsetForKeyboard];
    }
}

/*!
 * @discussion Method to update as content size changes.
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_updateFromContentSizeChange {
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if ( state.keyboardVisible ) {
		state.priorContentSize = self.contentSize;
        self.contentInset = [self NHKeyboardAvoiding_contentInsetForKeyboard];
    }
}

#pragma mark - Utilities
/*!
 * @discussion Method to navigate to next text fields.
 * @return Bool Call
 */
- (BOOL)NHKeyboardAvoiding_focusNextTextField {
    UIView *firstResponder = [self NHKeyboardAvoiding_findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        return NO;
    }
    
    CGFloat minY = CGFLOAT_MAX;
    UIView *view = nil;
    [self NHKeyboardAvoiding_findTextFieldAfterTextField:firstResponder beneathView:self minY:&minY foundView:&view];
    
    if ( view ) {
        [view performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        return YES;
    }
    
    return NO;
}

/*!
 * @discussion Method help to scroll directly to active text field.
 * @return Void Call
 */
-(void)NHKeyboardAvoiding_scrollToActiveTextField {
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if ( !state.keyboardVisible ) return;
    
    CGFloat visibleSpace = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(0, [self NHKeyboardAvoiding_idealOffsetForView:[self NHKeyboardAvoiding_findFirstResponderBeneathView:self]
                                                               withViewingAreaHeight:visibleSpace]);

    // Ordinarily we'd use -setContentOffset:animated:YES here, but it interferes with UIScrollView
    // behavior which automatically ensures that the first responder is within its bounds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setContentOffset:idealOffset animated:YES];
    });
}

#pragma mark - Helpers
/*!
 * @discussion Method to return the selected textfield.
 * @return Uiview Call
 */
- (UIView*)NHKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self NHKeyboardAvoiding_findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

/*!
 * @discussion Method to find textfield after another textfield selected.
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_findTextFieldAfterTextField:(UIView*)priorTextField beneathView:(UIView*)view minY:(CGFloat*)minY foundView:(UIView* __autoreleasing *)foundView {
    // Search recursively for text field or text view below priorTextField
    CGFloat priorFieldOffset = CGRectGetMinY([self convertRect:priorTextField.frame fromView:priorTextField.superview]);
    for ( UIView *childView in view.subviews ) {
        if ( childView.hidden ) continue;
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) && childView.isUserInteractionEnabled) {
            CGRect frame = [self convertRect:childView.frame fromView:view];
            if ( childView != priorTextField
                    && CGRectGetMinY(frame) >= priorFieldOffset
                    && CGRectGetMinY(frame) < *minY &&
                    !(fequal(frame.origin.y, priorTextField.frame.origin.y)
                      && frame.origin.x < priorTextField.frame.origin.x) ) {
                *minY = CGRectGetMinY(frame);
                *foundView = childView;
            }
        } else {
            [self NHKeyboardAvoiding_findTextFieldAfterTextField:priorTextField beneathView:childView minY:minY foundView:foundView];
        }
    }
}

/*!
 * @discussion method to set delegate for text field.
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            [self NHKeyboardAvoiding_initializeView:childView];
        } else {
            [self NHKeyboardAvoiding_assignTextDelegateForViewsBeneathView:childView];
        }
    }
}

/*!
 * @discussion Method to calculate content size of the scrollview based on subviews.
 * @return Void Call
 */
-(CGSize)NHKeyboardAvoiding_calculatedContentSizeFromSubviewFrames {
    
    BOOL wasShowingVerticalScrollIndicator = self.showsVerticalScrollIndicator;
    BOOL wasShowingHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    CGRect rect = CGRectZero;
    for ( UIView *view in self.subviews ) {
        rect = CGRectUnion(rect, view.frame);
    }
    rect.size.height += kCalculatedContenNHadding;
    
    self.showsVerticalScrollIndicator = wasShowingVerticalScrollIndicator;
    self.showsHorizontalScrollIndicator = wasShowingHorizontalScrollIndicator;
    
    return rect.size;
}


/*!
 * @discussion Method to calculate and return content inset for scrollview.
 * @return UIEdgeInsets Call
 */
- (UIEdgeInsets)NHKeyboardAvoiding_contentInsetForKeyboard {
    NHKeyboardAvoidingState *state = self.keyboardAvoidingState;
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = state.keyboardRect;
    newInset.bottom = keyboardRect.size.height - MAX((CGRectGetMaxY(keyboardRect) - CGRectGetMaxY(self.bounds)), 0);
    return newInset;
}

/*!
 * @discussion Method to calcualate content offset for scrollview.
 * @param view Content view whose offset going to be change
 * @param viewAreaHeight pass view area height
 * @return Void Call
 */
-(CGFloat)NHKeyboardAvoiding_idealOffsetForView:(UIView *)view withViewingAreaHeight:(CGFloat)viewAreaHeight {
    CGSize contentSize = self.contentSize;
    CGFloat offset = 0.0;

    CGRect subviewRect = [view convertRect:view.bounds toView:self];
    
    // Attempt to center the subview in the visible space, but if that means there will be less than kMinimumScrollOffseNHadding
    // pixels above the view, then substitute kMinimumScrollOffseNHadding
    CGFloat padding = (viewAreaHeight - subviewRect.size.height) / 2;
    if ( padding < kMinimumScrollOffseNHadding ) {
        padding = kMinimumScrollOffseNHadding;
    }

    // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
    // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
    // things like navigation bars.
    offset = subviewRect.origin.y - padding - self.contentInset.top;
    
    // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
    // inset into account, as this is manipulated to make space for the keyboard.
    if ( offset > (contentSize.height - viewAreaHeight) ) {
        offset = contentSize.height - viewAreaHeight;
    }
    
    // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
    if ( offset < -self.contentInset.top ) {
        offset = -self.contentInset.top;
    }

    return offset;
}

/*!
 * @discussion Method to init view with keyboard button types.
 * @return Void Call
 */
- (void)NHKeyboardAvoiding_initializeView:(UIView*)view {
    if ( [view isKindOfClass:[UITextField class]]
            && ((UITextField*)view).returnKeyType == UIReturnKeyDefault
            && (![(UITextField*)view delegate] || [(UITextField*)view delegate] == (id<UITextFieldDelegate>)self) ) {
        [(UITextField*)view setDelegate:(id<UITextFieldDelegate>)self];
        UIView *otherView = nil;
        CGFloat minY = CGFLOAT_MAX;
        [self NHKeyboardAvoiding_findTextFieldAfterTextField:view beneathView:self minY:&minY foundView:&otherView];
        
        if ( otherView ) {
            ((UITextField*)view).returnKeyType = UIReturnKeyNext;
        } else {
            ((UITextField*)view).returnKeyType = UIReturnKeyDone;
        }
    }
}

@end


@implementation NHKeyboardAvoidingState
@end
