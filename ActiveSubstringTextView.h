
#import <Foundation/Foundation.h>

@interface ActiveSubstringTextView : UITextView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIColor *higlightColor;

- (void)addTapActionWithRange:(NSRange)range withActionBlock:(void (^)())actionBlock;

@end


@interface TappableItem : NSObject

@property (nonatomic) NSRange range;
@property (nonatomic, copy) void (^tapActionBlock)();

@end
