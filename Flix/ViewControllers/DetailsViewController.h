//
//  DetailsViewController.h
//  Flix
//
//  Created by Mary Jiang on 6/23/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (nonatomic, strong) NSDictionary *movie; //public property that others can set, we need this so other controllers can talk to the details and tell us which movie we need to display details about

@end

NS_ASSUME_NONNULL_END
