//
//  ViewController.m
//  KeychainDemo
//
//  Created by yujie on 17/1/5.
//  Copyright © 2017年 yujie. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableDictionary+CTM_RequestDic.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableDictionary * requestDic = [NSMutableDictionary requestDictionaryWithToken:@""];
    
    [requestDic setValue:@"123456" forKey:@"password"]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
