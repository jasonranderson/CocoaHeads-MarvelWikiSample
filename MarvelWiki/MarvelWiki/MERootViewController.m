//
//  MERootViewController.m
//  MarvelWiki
//
//  Created by Jason Anderson on 5/13/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import "MERootViewController.h"
#import "MEDataManager.h"
#import "MECharacter.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MERootViewController () <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSArray *searchResults;

@property (weak,nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak,nonatomic) IBOutlet UILabel *nameLabel;
@property (weak,nonatomic) IBOutlet UIButton *detailButton;

@property (strong,nonatomic) MECharacter *character;

- (void)_loadDetailImage:(NSURL *)detailURL;
- (void)_openDetailLink:(UIButton *)sender;

@end

@implementation MERootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.nameLabel setText:@"Search For A Character"];
    [self.detailButton setEnabled:NO];
    [self.detailButton setHidden:YES];
    [self.detailButton addTarget:self action:@selector(_openDetailLink:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UISearchDisplayDelegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //implement if search should happen while typing
    return YES;
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[MEDataManager sharedManager] searchAPIWithString:searchBar.text completion:^(NSArray *resultsArray) {
        [self setSearchResults:resultsArray];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MECharacter *character = [self.searchResults objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:character.name];
    [cell.imageView setImageWithURL:[NSURL URLWithString:character.thumbnailPath] placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
    
    return cell;
}

#pragma mark - UITableViewDataSource Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.character = [self.searchResults objectAtIndex:indexPath.row];
    [self.nameLabel setText:self.character.name];
    [self _loadDetailImage:[NSURL URLWithString:self.character.imagePath]];
    [self.detailButton setHidden:NO];
    
    if (self.character.detailLink) {
        [self.detailButton setEnabled:YES];
    } else {
        [self.detailButton setEnabled:NO];
    }
    
    [self.searchDisplayController setActive:NO animated:YES];
}

#pragma mark - private methods
- (void)_loadDetailImage:(NSURL *)detailURL
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:detailURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (image)
            [self.detailImageView setImage:image];
    }];
}

- (void)_openDetailLink:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:self.character.detailLink];
}

@end
