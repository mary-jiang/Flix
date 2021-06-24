//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Mary Jiang on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumLineSpacing = 5; //space between each item in same column
    layout.minimumInteritemSpacing = 5; //space between each item in same row
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1))  / postersPerLine; //make the width scale with width of the screen based on how many posters in row and width of the screen
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)fetchMovies {
    
//    [self.activityIndicatorView startAnimating]; //start animating the loading thing when we fetch movies
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
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
//               for(NSDictionary *movie in movies){
//                   NSLog(@"%@", movie[@"title"]);
//               }
//               [self.tableView reloadData]; //data may have changed so call data source methods again
               [self.collectionView reloadData];
//               [self.activityIndicatorView stopAnimating]; //after we stop loading the movies we should stop animating the thing
           }
//        [self.refreshControl endRefreshing]; //once we get our data we have to tell refresh control to stop refreshing manually
       
       }];
    [task resume];
    
    
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.item];

    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500"; //base url given my movieapi documentation that we append all the poster paths unique to each movie to actually access each movie's poster
    NSString *posterURLString = movie[@"poster_path"]; //partial url that corrosponds to movie's poster
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString]; //combine the two portions above to make a full poster url
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; //NSURL is a string that checks to see if it's a valid url

    cell.posterView.image = nil; //clear out previous image, blank it out before it downloads a new one
    [cell.posterView setImageWithURL:posterURL]; //sets the UIImage that is posterView to the proper image url
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UICollectionViewCell *tappedCell = sender; //tapped cell is what is sending us to another
    NSIndexPath *indexPath  = [self.collectionView indexPathForCell:tappedCell]; //asking the table view to get us the index of said tapped cell (indexPath is a struct)
    NSDictionary *movie = self.movies[indexPath.item]; //getting the corrosponding movie out of the array for the cell that was just tapped on
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie; //pass over the movie that was tapped to the details view controller so they can do what they want with it
}





@end
