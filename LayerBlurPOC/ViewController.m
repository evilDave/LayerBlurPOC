//
//  ViewController.m
//  LayerBlurPOC
//
//  Created by David Clark on 18/02/2016.
//  Copyright (c) 2016 David Clark. All rights reserved.
//


#import "ViewController.h"


@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController {
	UIView *_placeholderView;
	UIImageView *_blurredImageView;
}

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    [self setView:view];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background1"]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imageView];
    [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    // make a demo form for the background
    UIView *lastView = nil;
    lastView = [self addLabelWithText:@"some other label" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addLabelWithText:@"some other label" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addLabelWithText:@"some other label" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];
    lastView = [self addLabelWithText:@"some other label" toView:self.view belowView:lastView];
    lastView = [self addTextFieldWithText:@"some text field" toView:self.view belowView:lastView];

	_placeholderView = [[UIView alloc] init];
}

- (void)addBlurView {
	// capture view contents
	UIGraphicsBeginImageContext(self.view.frame.size);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *testImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// blur it
	CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[blurFilter setValue:[CIImage imageWithCGImage:testImage.CGImage] forKey:@"inputImage"];
	[blurFilter setValue:@2.5f forKey:@"inputRadius"];
	CIImage *filterOutput = [blurFilter valueForKey:@"outputImage"];
	// get just the original part of the new image (it's bigger)
	CGRect rect = [filterOutput extent];
	rect.origin.x += (rect.size.width  - testImage.size.width ) / 2;
	rect.origin.y += (rect.size.height - testImage.size.height) / 2;
	rect.size = testImage.size;
	CIContext *context = [CIContext contextWithOptions:nil];
	UIImage *blurredImage = [UIImage imageWithCGImage:[context createCGImage:filterOutput fromRect:rect]];

	// insert it into the view stack
	_blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
	[_blurredImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:_blurredImageView];
	[_blurredImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
	[_blurredImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
	[_blurredImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
	[_blurredImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

- (UITextField *)addTextFieldWithText:(NSString *)text toView:(UIView *)containerView belowView:(UIView *)belowView {
    UITextField *textField = [[UITextField alloc] init];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:22]];
    [textField.layer setCornerRadius:5];
    [textField.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [textField.layer setBorderWidth:0.5];
    [textField setText:text];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setDelegate:self];
    [containerView addSubview:textField];
    [textField.topAnchor constraintEqualToAnchor:belowView ? belowView.bottomAnchor : containerView.topAnchor constant:belowView ? 20 : 50].active = YES;
    [textField.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:50].active = YES;
    [textField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-50].active = YES;
    return textField;
}

- (UILabel *)addLabelWithText:(NSString *)text toView:(UIView *)containerView belowView:(UIView *)belowView {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:text];
    [containerView addSubview:label];
    [label.topAnchor constraintEqualToAnchor:belowView ? belowView.bottomAnchor : containerView.topAnchor constant:belowView ? 20 : 50].active = YES;
    [label.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:50].active = YES;
    [label.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-50].active = YES;
    return label;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// TODO: look at what happens if the view moves after did begin editing
	[self addBlurView];
	[self.view addSubview:_placeholderView];
	[self.view exchangeSubviewAtIndex:[self.view.subviews indexOfObject:_placeholderView] withSubviewAtIndex:[self.view.subviews indexOfObject:textField]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self.view exchangeSubviewAtIndex:[self.view.subviews indexOfObject:_placeholderView] withSubviewAtIndex:[self.view.subviews indexOfObject:textField]];
	[_placeholderView removeFromSuperview];
	[_blurredImageView removeFromSuperview]; // encapsulate
}

@end
