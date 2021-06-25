//
//  DetailsViewController.m
//  Flix
//
//  Created by Mary Jiang on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h" //adds helper functions so we can make our images work
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500"; //base url given my movieapi documentation that we append all the poster paths unique to each movie to actually access each movie's poster
    NSString *posterURLString = self.movie[@"poster_path"]; //partial url that corrosponds to movie's poster
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString]; //combine the two portions aboce to make a full poster url
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; //NSURL is a string that checks to see if it's a valid url
    [self.posterView setImageWithURL:posterURL];
    
    //same stuff as above but with the backdrop instead
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropView setImageWithURL:backdropURL];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit]; //adjusts label to fit contents of stuff in it
    [self.synopsisLabel sizeToFit];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

//    //the endpoint requires us to have the movie id to get the trailer information so this will put in the movie id into the api request by constructing the end point through string concatination
    NSString *movieId = [NSString stringWithFormat:@"%@", self.movie[@"id"]]; //the id of the movie we are trying to get the trailer for, formated as a string so we can actually concat with it
    TrailerViewController *test = [segue destinationViewController];
    test.movieId = movieId; //send the movieId info over to the trailer view controller to deal with it

    
}


@end
