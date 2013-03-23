//
//  HSUStatusViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusViewController.h"

@interface HSUStatusViewController ()

@end

@implementation HSUStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    HSUTableCellData *cellData = [self.dataSource dataAtIndex:indexPath.row];
    if ([cellData.dataType isEqualToString:@"Status"]) {
        if ([HSUCommonTools isIPhone]) {
            HSUStatusViewController *statusVC = [[HSUStatusViewController alloc] init];
            [self.navigationController pushViewController:statusVC animated:YES];
        } else {
            
        }
    }
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishUpdateWithError:(NSError *)error
{
    [super dataSource:dataSource didFinishUpdateWithError:error];
    
    HSUUIEvent *event = [[HSUUIEvent alloc] initWithName:@"follow" target:self action:@selector(follow:) events:UIControlEventTouchUpInside];
    [dataSource addEvent:event];
}

- (void)follow:(NSDictionary *)cellData
{
    NSLog(@"follow fired with data: %@", cellData);
}

@end
