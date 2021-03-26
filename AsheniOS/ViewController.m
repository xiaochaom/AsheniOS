//
//  ViewController.m
//  AsheniOS
//
//  Created by 李亚超 on 2021/3/18.
//

#import "ViewController.h"
#import <GCDWebServer/GCDWebUploader.h>
#import "AshenCallBack.h"
#import "AshenUrls.h"
#import "AshenConst.h"
#define DEFAULTS [NSUserDefaults standardUserDefaults]

@interface ViewController ()
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) GCDWebUploader *webUploader;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *functions;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];;
    // Do any additional setup after loading the view.
    [self initdata];
    self.title = @"AsheniOS 接口测试";

    // 执行 init 操作
    
    [AshenCallBack sharedAshenCallBack];
    [self.view addSubview:self.tableView];
    [self startServer];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc{
    [self.webUploader stop];
}


- (UILabel *)hostLabel{
    if (!_hostLabel) {
        _hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        [_hostLabel setFont:[UIFont systemFontOfSize:20]];
        _hostLabel.textAlignment = NSTextAlignmentCenter;
        _hostLabel.textColor = [UIColor blackColor];
        
    }
    return _hostLabel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    label.text = self.webUploader.serverURL.absoluteString;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    return label;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50) style:(UITableViewStylePlain)];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.allowsMultipleSelection = YES;
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    NSArray *allkeys = [self.functions allKeys];
    NSArray *titles = self.functions[allkeys[indexPath.section]];
    NSString *title = titles[indexPath.row];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    if ([title isEqualToString:@"restartServer"]){
        [self setSwitchButtonCell:cell tag:100];
    }
    if ([title isEqualToString:@"checkConfig"]){
        [self setSwitchButtonCell:cell tag:101];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    if ([title isEqualToString:@"restart server"]){
        [self restartServer];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)initdata {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:@[@"restart server",@""] forKey:@"cell"];
    
    self.functions = [dic copy];
}

- (void)setSwitchButtonCell:(UITableViewCell *)cell tag:(int)tag {
    cell.tag = tag;
    [self addSwitchToCell:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

/**
 为cell添加swtich button
 
 @param cell cell对象
 */
- (void)addSwitchToCell:(UITableViewCell *)cell {
    BOOL isNeedAdd = YES;
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UISwitch class]]) {
            isNeedAdd = NO;
            break;
        }
    }
    if (isNeedAdd == NO)
        return;
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
//    [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    switchView.tag = cell.tag;
    BOOL isButtonOn = NO;
    switch (cell.tag) {
        case 100: {
            isButtonOn = [DEFAULTS boolForKey:@"restartServer"];
        } break;
            

        default:
            break;
    }
    switchView.on = isButtonOn;
    [cell.contentView addSubview:switchView];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:-20]];
}

- (void)startServer {
    NSString *homePath = NSHomeDirectory();
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    [[AshenUrls new] webServerUpdateUrls:self.webUploader];
    
    if ([self.webUploader startWithPort:9999 bonjourName:@"AsheniOS Interface Test"]) {
        NSString *host = self.webUploader.serverURL.absoluteString;
        
        [self.view addSubview:self.hostLabel];
        NSString *showText = host;
        [self.hostLabel setText:showText];
        NSLog(@"web uploader host:%@ port:%@", host, @(self.webUploader.port));
        
    }
}

- (void) restartServer {
    [self.webUploader stop];
    [self startServer];
}


@end
