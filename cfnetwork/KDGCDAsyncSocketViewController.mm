//
//  KDGCDAsyncSocketViewController.m
//  cfnetwork
//
//  Created by KudoCC on 16/8/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "KDGCDAsyncSocketViewController.h"
#import "HKMessageTextTableViewCell.h"
#import "HKAutoresizeTextView.h"
#import "UIPullMoreTableView.h"
#import "UIColor+Util.h"
#import <GCDAsyncSocket.h>
#import "KDConfig.h"
#import "KDPacket.h"
#import "KDNetworkUtility.h"
#import "Message.h"
#import "UIView+Coordinate.h"
#import "PacketMemoryManager.h"

#define ScreenHeight         [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth          [[UIScreen mainScreen] bounds].size.width

#define BACKGROUND_COLOR @"#f2f2f2"   // 系统背景色
#define LINE_COLOR @"#e4e4e4"         // 分割线

static const CGFloat BottomToolbarHeight = 40.0;
static const CGFloat PaddingTableViewAndBottom = 2.0;

@interface KDGCDAsyncSocketViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, GCDAsyncSocketDelegate> {
    CPacketMemoryManager *_memoryManager;
}

@property (nonatomic, strong) UIPullMoreTableView *tableView;
@property (nonatomic, strong) UIView *viewBottomToolbar;
@property (nonatomic, strong) HKAutoresizeTextView *textView;

@property (nonatomic, strong) NSMutableArray *mArrayMessage;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;


@property (nonatomic) GCDAsyncSocket *socket;

@end

@implementation KDGCDAsyncSocketViewController

- (void)dealloc {
    if (_memoryManager) {
        delete _memoryManager;
    }
    
    [_textView removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UIPullMoreTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, ScreenWidth, ScreenHeight-PaddingTableViewAndBottom-BottomToolbarHeight)
                                                      style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor opaqueColorWithHexString:BACKGROUND_COLOR];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.allowsSelection = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _viewBottomToolbar = [[UIView alloc] initWithFrame:CGRectMake(0.0, ScreenHeight-BottomToolbarHeight, ScreenWidth, BottomToolbarHeight)];
    [self.view addSubview:_viewBottomToolbar];
    _viewBottomToolbar.backgroundColor = [UIColor lightGrayColor];
    
    _textView = [[HKAutoresizeTextView alloc] initWithFrame:CGRectInset(_viewBottomToolbar.bounds, 5.0, 3.0)];
    _textView.layer.cornerRadius = 2.0;
    _textView.layer.borderWidth = 1.0;
    _textView.layer.borderColor = [UIColor opaqueColorWithHexString:LINE_COLOR].CGColor;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.maxHeight = 100.0;
    _textView.font = [UIFont systemFontOfSize:15.0];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    [_viewBottomToolbar addSubview:_textView];
    [_textView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    
    // socket
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [_socket connectToHost:[KDConfig sharedConfig].serverIp onPort:[KDConfig sharedConfig].serverPort error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    _mArrayMessage = [NSMutableArray array];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _memoryManager = new CPacketMemoryManager();
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    delete _memoryManager;
    _memoryManager = NULL;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _memoryManager->addToBuffer((const unsigned char *)data.bytes, (unsigned int)data.length);
    while (1) {
        unsigned int len = _memoryManager->getUseBufferLength() ;
        if (len > sizeof(NetWorkHeader)) {
            unsigned char *p = _memoryManager->getBufferPointer() ;
            NSData *data = [NSData dataWithBytes:p length:sizeof(BaseNetworkPacket)] ;
            KDPacket *packet = [KDPacket deSerialization:data] ;
            unsigned int packetLen = packet.packet->header.length ;
            if (len < packetLen) {
                break;
            }
            data = [NSData dataWithBytes:p length:packetLen] ;
            packet = [KDPacket deSerialization:data] ;
            _memoryManager->removeBuffer(packetLen) ;
            
            BaseNetworkPacket *basePacket = [packet packet] ;
            if (basePacket->header.cmd == Cmd_Text) {
                TextPacket *textpacket = (TextPacket *)basePacket ;
                textpacket->text[textpacket->textLen] = '\0' ;
                Message *message = [Message new];
                message.text = [NSString stringWithUTF8String:textpacket->text];
                message.peer = YES;
                message.date = [NSDate date];
                [_mArrayMessage addObject:message];
                [_tableView reloadData];
            }
        } else {
            break ;
        }
    }
    
    [_socket readDataWithTimeout:-1 tag:0];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    return YES;
}

- (void)sendMessage {
    // send message
    NSString *text = _textView.text;
    
    if ([text length] == 0) {
        return;
    }
    _textView.text = @"";
    
    NSString *strSend = text;
    NSData *dataSend = nil;
    if ([strSend length] > 0) {
        dataSend = [strSend dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([dataSend length] > 0) {
        if (_socket.isConnected) {
            TextPacket s_packet;
            s_packet.setTransId([KDNetworkUtility generatorTransId]) ;
            s_packet.textLen = [dataSend length] ;
            memcpy(s_packet.text, dataSend.bytes, [dataSend length]) ;
            KDPacket *packet = [KDPacket serialization:&s_packet] ;
            NSData *data = [packet data];
            [_socket writeData:data withTimeout:0 tag:0];
            Message *message = [[Message alloc] init];
            message.text = [NSString stringWithUTF8String:s_packet.text];
            message.peer = NO;
            message.date = [NSDate date];
            [_mArrayMessage addObject:message];
        }
    }
    
    [_tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_mArrayMessage.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)scrollToBottom:(BOOL)animate {
    if ([_mArrayMessage count] > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_mArrayMessage count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _textView && [keyPath isEqualToString:@"frame"]) {
        NSValue *value = change[NSKeyValueChangeNewKey];
        CGRect frame = [value CGRectValue];
        CGFloat height = frame.size.height + 4.0;
        frame = CGRectMake(0.0, _viewBottomToolbar.top+_viewBottomToolbar.height-height, ScreenWidth, height);
        [UIView animateWithDuration:0.3 animations:^{
            _viewBottomToolbar.frame = frame;
            
            CGRect frameTableView = _tableView.frame;
            frameTableView.size.height = _viewBottomToolbar.top - PaddingTableViewAndBottom;
            _tableView.frame = frameTableView;
        }];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = _viewBottomToolbar.frame;
    frame.origin.y = self.view.height-keyboardFrame.size.height-frame.size.height;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        _viewBottomToolbar.frame = frame;
        
        CGRect frameTableView = _tableView.frame;
        frameTableView.size.height = _viewBottomToolbar.top - PaddingTableViewAndBottom;
        _tableView.frame = frameTableView;
        
        if (frameTableView.size.height - _tableView.contentInset.top < _tableView.contentSize.height) {
            _tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, _tableView.contentSize.height-_tableView.size.height);
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frame = _viewBottomToolbar.frame;
    frame.origin.y = self.view.height-frame.size.height;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _viewBottomToolbar.frame = frame;
        
        CGRect frameTableView = _tableView.frame;
        frameTableView.size.height = _viewBottomToolbar.top - PaddingTableViewAndBottom;
        _tableView.frame = frameTableView;
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HKMessageTextTableViewCell cellSizeForMessage:_mArrayMessage[indexPath.row]].height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_mArrayMessage count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cellId";
    HKMessageTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HKMessageTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Message *message = _mArrayMessage[indexPath.row];
    cell.message = message;
    cell.labelTime.text = [_dateFormatter stringFromDate:message.date];
    return cell;
}

@end