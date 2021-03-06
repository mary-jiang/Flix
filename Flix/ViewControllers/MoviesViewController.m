//
//  MoviesViewController.m
//  Flix
//
//  Created by Mary Jiang on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h" //import our custom movie cell
#import "UIImageView+AFNetworking.h" //add helper methods that weren't part of orginal to UIImageView (categories)
#import "DetailsViewController.h" //import the detailsviewcontroller

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> //this class implements these protocols (promise that we will implement methods inside of these protocols, like interface in Java)

@property (nonatomic, strong) NSArray *movies; //making basically like a private array so we can refer to it in all functions
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self; //setting datasource to view controller (self), will call 2 data source req functions on this view controller
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self fetchMovies]; //when view loads get movies
    
    self.activityIndicatorView.hidesWhenStopped = true; //make sure that the loading circle hides once it's stopped and we no longer want to indicate that things are loading
    
    self.refreshControl = [[UIRefreshControl alloc] init]; //this is similar to making an object in Java
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged]; //refreshControl targets self (this view controller) and will call fetchMovies on it for the control events when event value changed
    [self.tableView insertSubview:self.refreshControl atIndex:0]; //inserts the refresh control spinny thing on the top, knows scrolling is parent and makes it so when we pull down it will start refreshing (what happens when we start refreshing is defined line before)
    
}

- (void)fetchMovies {
    
    [self.activityIndicatorView startAnimating]; //start animating the loading thing when we fetch movies
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet" message:@"Could not retrieve movies. Please check your connection and try again." preferredStyle: UIAlertControllerStyleAlert]; //creates an alert controller with title and message
               UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self fetchMovies]; //once they hit try again try to fetch movies again
                    }]; //creates an action to try fetching movies again when pressed
               [alert addAction:tryAgain]; //adds action to the alert controller
               
               [self presentViewController:alert animated:true completion:^{}]; //make the alert appear on screen
              
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               self.movies = dataDictionary[@"results"]; //puts everything in results from api into movies array
               self.filteredMovies = self.movies;
               
               [self.tableView reloadData]; //data may have changed so call data source methods again
               
               [self.activityIndicatorView stopAnimating]; //after we stop loading the movies we should stop animating the thing
           }
        [self.refreshControl endRefreshing]; //once we get our data we have to tell refresh control to stop refreshing manually
       
       }];
    [task resume];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovies.count; //how many rows we have is equal to how many movies we have
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"]; //dequeue means when we have something loaded and don't need it anymore put it in some reusable bag, only create from scratch if we haven't seein it before
    
    NSDictionary *movie = self.filteredMovies[indexPath.row]; //access the corrosponding movie from the array, indexPath.row is the row this cell is in in the table
    
    //set the labels to have information based on which movie this cell is displaying
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500"; //base url given my movieapi documentation that we append all the poster paths unique to each movie to actually access each movie's poster
    NSString *posterURLString = movie[@"poster_path"]; //partial url that corrosponds to movie's poster
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString]; //combine the two portions aboce to make a full poster url
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; //NSURL is a string that checks to see if it's a valid url
    cell.posterView.image = nil; //clear out previous image, blank it out before it downloads a new one
    //[cell.posterView setImageWithURL:posterURL]; //sets the UIImage that is posterView to the proper image url
    
    //makes pictures fade in when they load
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
        //imageResponse is null if image is cached
        if(imageResponse){ //image is not cached
            cell.posterView.alpha = 0.0; //make invisible
            cell.posterView.image = image; //update image
            
            [UIView animateWithDuration:0.3 animations:^{ //over the course of time duration sec make poster visible
                cell.posterView.alpha = 1.0;
            }];
        }else{ //image is cached
            cell.posterView.image = image; //update image
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //do nothing for now if it fails
    }];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchBar.showsCancelButton = true; //so we can cancel out of our search bar
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject[@"title"] hasPrefix:searchText]; //gets title out of dictionary and see if it has the prefix of whatever is in the search bar
                }];
       self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate]; //filter array with an established predicate

    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
 
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = false; //hide the cancel button once they cancle
    self.searchBar.text = @""; //clear out all the text in search bar
    [self.searchBar resignFirstResponder]; //hide keyboard
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { //called when about to leave this view controller, anything you want to send to the new destination view controller?
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *tappedCell = sender; //tapped cell is what is sending us to another
    NSIndexPath *indexPath  = [self.tableView indexPathForCell:tappedCell]; //asking the table view to get us the index of said tapped cell (indexPath is a struct)
    NSDictionary *movie = self.movies[indexPath.row]; //getting the corrosponding movie out of the array for the cell that was just tapped on
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie; //pass over the movie that was tapped to the details view controller so they can do what they want with it
}


@end
