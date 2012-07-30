//
//  TestViewController.m
//  FreshestBooks
//
//  Created by Fang Chen on 7/28/12.
//  Copyright (c) 2012 GoldenGloves. All rights reserved.
//

#import "TestViewController.h"
#import "FreshBooks.h"

@interface TestViewController () <FreshBooksDelegate>
@property (nonatomic, strong) FreshBooks *freshb;
@property (weak, nonatomic) IBOutlet UITextField *subdomainTextField;
@end

@implementation TestViewController
@synthesize freshb = _freshb;
@synthesize subdomainTextField = _subdomainTextField;

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    if (!_freshb) {
      _freshb = [[FreshBooks alloc] init];
      [_freshb setDelegate:self];
    }
  }
  return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidUnload {
  [self setSubdomainTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark - FRESHBOOKS
- (IBAction)loginToFreshBooksPressed:(id)sender {
  
  if (self.subdomainTextField.text) {
    [self.freshb setCompanyName:self.subdomainTextField.text];
    [self.freshb startSession];
  }
  
}

#pragma mark -
#pragma mark - FRESHBOOKSDELEGATE
- (void)didAuthorizeFreshBooks {
  /**
   freshbooks is ready
   do what you will
   */
  NSLog(@"%@ FRESHBOOK READY %@",self, self.freshb);
}
- (void)didEpicFail {
  /**
   you pooped your pants
   move back 3 spaces
   */
  NSLog(@"%@ FRESHBOOK FAIL", self);
}

@end
