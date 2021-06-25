//
//  TrailerViewController.m
//  Flix
//
//  Created by Mary Jiang on 6/25/21.
//

#import "TrailerViewController.h"
#import "WebKit/WebKit.h"

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *trailerView;
@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

        NSString *beginningAPIURL = @"https://api.themoviedb.org/3/movie/"; //the beginning part of the api endpoint
        NSString *endAPIURL = @"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"; //end part of the api endpoint
    
        NSString *fullAPIURL = [[beginningAPIURL stringByAppendingString:self.movieId] stringByAppendingString:endAPIURL]; //build the api url with the movie id we are supposed to be displaying on this page
    
        NSURL *url = [NSURL URLWithString:fullAPIURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               if (error != nil) {
                   NSLog(@"%@", [error localizedDescription]);
               }
               else {
                   NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                   NSArray *results = dataDictionary[@"results"]; //results is an array of dictionaries where each dictionary has information about a different trailer associated with that
                   if(results.count != 0){ //make sure that results isn't empty before we try using anything in it
                       NSString *key = results[0][@"key"]; //just use the key of the first trailer associated with that movie
                       NSString *baseURL = @"https://www.youtube.com/watch?v="; //the base url we have to append key to to get the actual video url
                       NSString *videoURL = [baseURL stringByAppendingString:key];
    
                       NSURL *url = [NSURL URLWithString:videoURL]; //convert url string to nsurl object
                       NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0]; //place the url in a url request
                       [self.trailerView loadRequest:request]; //load that request into webview
                   }
    
               }
    
    
           }];
        [task resume];
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
