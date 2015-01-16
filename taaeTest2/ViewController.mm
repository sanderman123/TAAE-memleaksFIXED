//
//  ViewController.m
//  taaeTest2
//
//  Created by Sander on 12/30/14.
//  Copyright (c) 2014 Sander. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Make variables public so they can be reused
    self.abl = (AudioBufferList*) malloc(sizeof(AudioBufferList));
    //self.abl = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    self.abl1 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    self.abl2 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    self.byteData = (Byte*) malloc(1024); //should maybe be a different value in the future
    self.byteData2 = (Byte*) malloc(1024); //should maybe be a different value in the future
    
    //Rotate slider
    UIView *superView = self.slider1.superview;
    [self.slider1 removeFromSuperview];
    [self.slider1 removeConstraints:self.view.constraints];
    self.slider1.translatesAutoresizingMaskIntoConstraints = YES;
    self.slider1.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [superView addSubview:self.slider1];
    [self.slider2 removeFromSuperview];
    [self.slider2 removeConstraints:self.view.constraints];
    self.slider2.translatesAutoresizingMaskIntoConstraints = YES;
    self.slider2.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [superView addSubview:self.slider2];

    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled: YES];
    _audioController.preferredBufferDuration = 0.005;
    
    NSError *error = [NSError alloc];
    if(![self.audioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
    //Initialize audio output channels and audio input
    player1 = [[MyAudioPlayer alloc] init];
    player2 = [[MyAudioPlayer alloc] init];

    channel1 = [self.audioController createChannelGroup];
    channel2 = [self.audioController createChannelGroup];
    
    [self.audioController addInputReceiver:self];
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player1, nil] toChannelGroup:channel1];
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player2, nil] toChannelGroup:channel2];
    
    
    //Initialize volumes
    volumes = (float *)malloc(sizeof(float) * 2);
    volumes[0] = self.slider1.value;
    volumes[1] = self.slider2.value;
    [self.audioController setVolume:volumes[0] forChannelGroup:channel1];
    [self.audioController setVolume:volumes[1] forChannelGroup:channel2];
    
    
//    AudioStreamBasicDescription asbd = [self.audioController inputAudioDescription];
//    [self.audioController set
    
}

static void inputCallback(__unsafe_unretained ViewController *THIS,
                          __unsafe_unretained AEAudioController *audioController,
                          void                     *source,
                          const AudioTimeStamp     *time,
                          UInt32                    frames,
                          AudioBufferList          *audio) {
    
    @autoreleasepool {
        // Code that creates autoreleased objects.
    
    
        //Test encode and decode with NSData
        NSData *data = [THIS encodeAudioBufferList:audio];
        AudioBufferList *decodedAbl = [THIS decodeAudioBufferList:data];
    
        //Make 2 stereo channels out of 2 mono channels
        AudioBuffer ab1 = decodedAbl->mBuffers[0];//audio->mBuffers[0];
        AudioBuffer ab2 = decodedAbl->mBuffers[1];//audio->mBuffers[1];
    
        THIS.abl1->mNumberBuffers = 2;
        THIS.abl1->mBuffers[0] = ab1;
        THIS.abl1->mBuffers[1] = ab1;
        THIS.abl2->mNumberBuffers = 2;
        THIS.abl2->mBuffers[0] = ab2;
        THIS.abl2->mBuffers[1] = ab2;
    
        [THIS->player1 addToBufferAudioBufferList:THIS.abl1 frames:frames timestamp:time];
        [THIS->player2 addToBufferAudioBufferList:THIS.abl2 frames:frames timestamp:time];
    }
}

-(AEAudioControllerAudioCallback)receiverCallback{
    return (AEAudioControllerAudioCallback)inputCallback;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)slider1ValueChanged:(id)sender {
    volumes[0] = self.slider1.value;
    [self.audioController setVolume:volumes[0] forChannelGroup:channel1];
}
- (IBAction)slider2ValueChanged:(id)sender {
    volumes[1] = self.slider2.value;
    [self.audioController setVolume:volumes[1] forChannelGroup:channel2];
}


- (NSData *)encodeAudioBufferList:(AudioBufferList *)abl {
    //NSMutableData *data = [NSMutableData data];
    if(self.mutableData == nil){
        self.mutableData = [NSMutableData data];
    } else {
        [self.mutableData setLength:0];
    }
    
    for (int y = 0; y < abl->mNumberBuffers; y++){
        AudioBuffer ab = abl->mBuffers[y];
        Float32 *frame = (Float32*)ab.mData;
        [self.mutableData appendBytes:frame length:ab.mDataByteSize];
    }
    
    return self.mutableData;
}

- (AudioBufferList *)decodeAudioBufferList:(NSData *)data {
    
    if (data.length > 0) {
        int nc = 2; // This value should be changed once there are more than 2 channels
        
        //AudioBufferList *abl = (AudioBufferList*) malloc(sizeof(AudioBufferList));
        self.abl->mNumberBuffers = nc;
        
        NSUInteger len = [data length];
        
        //Take the range of the first buffer
        NSUInteger olen = 0;
        // NSUInteger lenx = len / nc;
        NSUInteger step = len / nc;
        int i = 0;
        
        while (olen < len) {
            
            //NSData *d = [NSData alloc];
            NSData *pd = [data subdataWithRange:NSMakeRange(olen, step)];
            NSUInteger l = [pd length];
            NSLog(@"l: %lu",(unsigned long)l);
//            Byte *byteData = (Byte*) malloc(l);
            if(i == 0){
                memcpy(self.byteData, [pd bytes], l);
                if(self.byteData){
                    
                    //I think the zero should be 'i', but for some reason that doesn't work...
                    self.abl->mBuffers[i].mDataByteSize = (UInt32)l;
                    self.abl->mBuffers[i].mNumberChannels = 1;
                    self.abl->mBuffers[i].mData = self.byteData;
                    //                memcpy(&self.abl->mBuffers[i].mData, byteData, l);
                }
            } else {
                memcpy(self.byteData2, [pd bytes], l);
                if(self.byteData2){
                    
                    //I think the zero should be 'i', but for some reason that doesn't work...
                    self.abl->mBuffers[i].mDataByteSize = (UInt32)l;
                    self.abl->mBuffers[i].mNumberChannels = 1;
                    self.abl->mBuffers[i].mData = self.byteData2;
                    //                memcpy(&self.abl->mBuffers[i].mData, byteData, l);
                }
            }
            
            
            //Update the range to the next buffer
            olen += step;
            //lenx = lenx + step;
            i++;
//            free(byteData);
        }
        return self.abl;
    }
    return nil;
}



@end
