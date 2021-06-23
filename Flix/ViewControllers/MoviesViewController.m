//
//  MoviesViewController.m
//  Flix
//
//  Created by Mary Jiang on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h" //import our custom movie cell
#import "UIImageView+AFNetworking.h" //add helper methods that weren't part of orgiinal to UIImageView (categories)

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate> //this class implements these protocols (promise that we will implement methods inside of these protocols, like interface in Java)

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self; //setting datasource to view controller (self), will call 2 data source req functions on this view controller
    self.tableView.delegate = self;
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               //NSLog(@"%@", dataDictionary); //just prints out the dictionary we fetched using api
               
               self.movies = dataDictionary[@"results"]; //puts everything in results from api into movies array
//               for(NSDictionary *movie in movies){
//                   NSLog(@"%@", movie[@"title"]);
//               }
               [self.tableView reloadData]; //data may have changed so call data source methods again
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count; //how many rows we have is equal to how many movies we have
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"]; //dequeue means when we have something loaded and don't need it anymore put it in some reusable bag, only create from scratch if we haven't seein it before, if not found create a cell looking like our story board cell that's asscoiated with MovieCell.m and MovieCell.h
    
    NSDictionary *movie = self.movies[indexPath.row]; //access the corrosponding movie from the array, indexPath.row is the row this cell is in in the table
    
    cell.titleLabel.text = movie[@"title"]; //set the titlelabel in the cell to be the title of the movie (accessed through the api)
    cell.synopsisLabel.text = movie[@"overview"]; //set the synoposilabel in the cell to be synopsis of the movie
    //cell.textLabel.text = movie[@"title"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500"; //base url given my movieapi documentation that we append all the poster paths unique to each movie to actually access each movie's poster
    NSString *posterURLString = movie[@"poster_path"]; //partial url that corrosponds to movie's poster
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString]; //combine the two portions aboce to make a full poster url
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; //NSURL is a string that checks to see if it's a valid url
    cell.posterView.image = nil; //clear out previous image, blank it out before it downloads a new one 
    [cell.posterView setImageWithURL:posterURL]; //sets the UIImage that is posterView to the proper image url
    
    return cell;
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
