//
//  XLFormTextViewCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Created by Martin Barreto on 31/3/14.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLFormRowDescriptor.h"
#import "UIView+XLFormAdditions.h"
#import "XLFormViewController.h"
#import "XLFormTextView.h"
#import "XLFormTextViewCell.h"

NSString *const kFormTextViewCellPlaceholder = @"placeholder";

@interface XLFormTextViewCell() <UITextViewDelegate>

@end

@implementation XLFormTextViewCell
{
    NSArray * _dynamicCustomConstraints;
}

@synthesize label = _label;
@synthesize textView = _textView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.textView];
        [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
        NSDictionary * views = @{@"label": self.label, @"textView": self.textView};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[label]" options:0 metrics:0 views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.label && [keyPath isEqualToString:@"text"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self needsUpdateConstraints];
        }
    }
}

-(void)dealloc
{
    [self.label removeObserver:self forKeyPath:@"text"];
}


#pragma mark - Properties

-(UILabel *)label
{
    if (_label) return _label;
    _label = [UILabel autolayoutView];
    [_label setContentHuggingPriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    return _label;
}

-(XLFormTextView *)textView
{
    if (_textView) return _textView;
    _textView = [XLFormTextView autolayoutView];
    return _textView;
}


#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
}

-(void)update
{
    [super update];
    self.textView.delegate = self;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textView.placeHolderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textView.keyboardType = UIKeyboardTypeAlphabet;
    self.textView.text = self.rowDescriptor.value;
    self.label.text = ((self.rowDescriptor.required && self.rowDescriptor.title) ? [NSString stringWithFormat:@"%@*", self.rowDescriptor.title]: self.rowDescriptor.title);
}

+(CGFloat)formDescriptorCellHeightForRowDescription:(XLFormRowDescriptor *)rowDescriptor
{
    return 110.f;
}

-(NSError *)formDescriptorCellLocalValidation
{
    if (self.rowDescriptor.required && (self.textView.text == nil || [self.textView.text isEqualToString:@""])){
        return [[NSError alloc] initWithDomain:XLFormErrorDomain code:XLFormErrorCodeRequired userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"%@ can't be empty", nil), self.rowDescriptor.title] }];
        
    }
    return nil;
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

-(BOOL)formDescriptorCellResignFirstResponder
{
    return [self.textView resignFirstResponder];
}

#pragma mark - Constraints

-(void)updateConstraints
{
    if (_dynamicCustomConstraints){
        [self.contentView removeConstraints:_dynamicCustomConstraints];
    }
    NSDictionary * views = @{@"label": self.label, @"textView": self.textView};
    if (!self.label.text || [self.label.text isEqualToString:@""]){
        _dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[textView]-16-|" options:0 metrics:0 views:views];
    }
    else{
        _dynamicCustomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[label]-[textView]-4-|" options:0 metrics:0 views:views];
    }
    [self.contentView addConstraints:_dynamicCustomConstraints];
    [super updateConstraints];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    self.rowDescriptor.value = self.textView.text;
    [self.formViewController textViewDidEndEditing:textView];
}

-(void)textViewDidChange:(UITextView *)textView{
    self.rowDescriptor.value = self.textView.text;
}

@end
