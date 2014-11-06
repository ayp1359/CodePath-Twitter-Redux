
#import <MBProgressHUD.h>
#import "SignInViewController.h"
#import "TwitterClient.h"

@interface SignInViewController ()
@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}


- (IBAction)signIn:(id)sender {
  [[TwitterClient instance]
   loginWithSuccess:^{
     [self fetchAndSaveCurrentUser];
   }
   failure:^(NSError* error) {
     [self errorDuringSignIn:error];
   }];
}

- (void)fetchAndSaveCurrentUser {
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  [[TwitterClient instance] currentUserWithSuccess:^(User *currentUser) {
    [User setCurrentUser:currentUser];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  } failure:^(NSError *error) {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self errorDuringSignIn:error];
  }];
}

- (void)errorDuringSignIn:(NSError *)error {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not signin." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
  [alertView show];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
