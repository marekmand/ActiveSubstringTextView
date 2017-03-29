

#import "ActiveSubstringTextView.h"

@interface ActiveSubstringTextView()

@property (nonatomic, strong) NSMutableArray *tappableItems;
@property (nonatomic, strong) TappableItem *currentItem;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) NSAttributedString *backupAttributedText;
@property (nonatomic, readwrite) BOOL isInitializedActionMod;

- (TappableItem *)getRangeOfTextForPoint:(CGPoint) point;

@end


@implementation ActiveSubstringTextView


- (id)init
{
    self = [super init];
    if (self) {
       [self initBlock];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])){
        [self initBlock];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [self initBlock];
    }
    return self;
}


- (void)initBlock{
    // set UITextView to be similar to a UILabel
    self.backgroundColor = [UIColor clearColor];
    self.editable = NO;
    self.selectable = NO;
    self.scrollEnabled = NO;
    self.multipleTouchEnabled = NO;
    // remove top padding of it (important - characterIndexForPoint's not working without it)
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;

    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    self.panRecognizer.cancelsTouchesInView = NO;
    self.panRecognizer.delegate = self;
    [self addGestureRecognizer:self.panRecognizer];
    
    self.higlightColor = [UIColor blueColor];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    //recognizer must be the panRecognizer
    if (gestureRecognizer == self.panRecognizer){
         // find out if user tapped into the active text
        CGPoint point =  [gestureRecognizer locationInView:self];
        TappableItem * tapItem = [self getRangeOfTextForPoint:point];
        
        if (tapItem){
            // user tapped into the active text
            // share touch events with other recognizers - NO
            return NO;
        }
    }
    // user didn't tap into the active text
    // share touch events with other recognizers - YES
    return YES;
}


- (void)addTapActionWithRange:(NSRange)range withActionBlock:(void (^)())actionBlock{
    
    // init array if it is not yet
    if (!_tappableItems){
        _tappableItems = [NSMutableArray array];
    }
    
    if (!_isInitializedActionMod){
        _isInitializedActionMod = YES;
        
        // allow user interaction
        self.userInteractionEnabled = YES;
    }
    
    // change the color of the text in the submited range
    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:self.higlightColor
                           range:range];
    
    self.attributedText = attributedText;
    
    // create tappable item and add it into the monitoring array
    TappableItem *item = [[TappableItem alloc] init];
    
    item.tapActionBlock = actionBlock;
    item.range = range;
    
    [_tappableItems addObject:item];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _currentItem = nil;
    
    self.backupAttributedText = self.attributedText;
    
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        TappableItem * tapItem = [self getRangeOfTextForPoint:touchPoint];
        if (tapItem) {
            
            NSRange range = tapItem.range;
            _currentItem = tapItem;
            [self highliteTappedAreaInRange:range];
            return;
        }
    }
    
    // send event to the next responder
    [self.nextResponder touchesBegan:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _currentItem = nil;
    self.attributedText = self.backupAttributedText;
    
    // send event to the next responder
    [self.nextResponder touchesCancelled:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.attributedText = self.backupAttributedText;
    
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        TappableItem * tapItem = [self getRangeOfTextForPoint:touchPoint];
        if ( tapItem && _currentItem && tapItem == _currentItem) {
            if (tapItem.tapActionBlock){
                tapItem.tapActionBlock();
            }
        }
    }
    
    // send event to the next responder
    [self.nextResponder touchesEnded:touches withEvent:event];
}


- (void) highliteTappedAreaInRange: (NSRange) range{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    
    UIColor *color = [[UIColor blueColor] colorWithAlphaComponent:0.5f];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:range];
    
    self.attributedText = attributedString;
}


- (TappableItem *)getRangeOfTextForPoint:(CGPoint) point {
    
    NSLayoutManager *layoutManager = self.layoutManager;
    
    NSUInteger characterIndex;
    
    characterIndex = [layoutManager characterIndexForPoint:point
                                           inTextContainer:self.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:characterIndex];
    CGRect rectOfGlyph = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:layoutManager.textContainers[0]];
    BOOL contains = CGRectContainsPoint(rectOfGlyph, point);
    
    if (characterIndex < self.textStorage.length && contains) {
        
//        // test log
//        unichar theChar = [self.text characterAtIndex:characterIndex];
//        NSLog(@"%C", theChar);
        
        for (TappableItem * item in _tappableItems){
            if (NSLocationInRange(characterIndex, item.range)){
                return item;
            }
        }
    }
    
    return nil;
}


- (void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.text.length)];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, self.text.length)];
    
    for (TappableItem * item in self.tappableItems){
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.higlightColor range:item.range];
    }
    
    self.attributedText = attributedString;
}


@end


@implementation TappableItem

@end
