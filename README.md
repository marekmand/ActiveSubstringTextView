# ActiveSubstringTextView


if you want to have acitve substring of your UITextView you can use my code or at least take some inspiration from it...

It would be nice to hear/see 'Thank you', if it is helpful for you :)





my easy way of using it:

   // common staff: init the textView, set font, textColor, frame or constrains....

   self.textView.text = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed elit dolor, placerat non sodales et, vehicula eget nisl. Sed iaculis rutrum sem, eu finibus elit tristique sit amet.", nil);
   
   NSString *activeSubstring = NSLocalizedString(@"vehicula eget nisl", nil);
   
   NSRange range = [self.textView.text rangeOfString:activeSubstring];
   
   [self.textView addTapActionWithRange:range withActionBlock:^{
   
        // anything you want to do - show something
        
    }];
