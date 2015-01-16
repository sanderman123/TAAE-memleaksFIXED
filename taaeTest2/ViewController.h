//
//  ViewController.h
//  taaeTest2
//
//  Created by Sander on 12/30/14.
//  Copyright (c) 2014 Sander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"
#import "TPCircularBuffer.h"
#import "TPCircularBuffer+AudioBufferList.h"
#import <Accelerate/Accelerate.h>

//#import "MyAudioReceiver.h"
#import "MyAudioPlayer.h"

@interface ViewController : UIViewController<AEAudioReceiver> {
    @public
    MyAudioPlayer *player1;
    MyAudioPlayer *player2;
    AEChannelGroupRef channel1;
    AEChannelGroupRef channel2;
    float* volumes;
}

@property (retain, nonatomic) AEAudioController *audioController;
@property (nonatomic, strong) AEPlaythroughChannel *playthrough;
@property (nonatomic, assign) TPCircularBuffer cb;
@property (nonatomic) AudioBufferList *abl;// = (AudioBufferList*) malloc(sizeof(AudioBufferList));
@property (nonatomic) AudioBufferList *abl1;
@property (nonatomic) AudioBufferList *abl2;
@property (nonatomic) Byte *byteData;// = (Byte*) malloc(l);
@property (nonatomic) Byte *byteData2;// = (Byte*) malloc(l);


@property (nonatomic) NSMutableData *mutableData;
//@property (nonatomic) AudioBufferList *decodedAbl;

//@property  MyAudioPlayer *player1;
@property (weak, nonatomic) IBOutlet UISlider *slider1;
- (IBAction)slider1ValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
- (IBAction)slider2ValueChanged:(id)sender;

- (NSData *) encodeAudioBufferList:(AudioBufferList *)abl;

- (AudioBufferList *) decodeAudioBufferList: (NSData *) data;

@end

