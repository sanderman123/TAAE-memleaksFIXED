//
//  MyAudioReceiver.m
//  
//
//  Created by Sander on 1/13/15.
//
//

#import "MyAudioReceiver.h"

@implementation MyAudioReceiver

-(instancetype)init{
    TPCircularBufferInit(&_cbuffer, 16384);
    
    return self;
}

-(void)initAudioReceiver{
    TPCircularBufferInit(&_cbuffer, 16384);
}

-(AEAudioControllerAudioCallback)receiverCallback {
    return receiverCallback;
}

static void receiverCallback(__unsafe_unretained MyAudioReceiver *THIS,
                             __unsafe_unretained AEAudioController *audioController,
                             void                     *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio) {
    
    // Do something with 'audio'
    NSLog(@"Blaat");
    
}

static OSStatus renderCallback(__unsafe_unretained MyAudioReceiver *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {
    
    return noErr;
}

-(AEAudioControllerRenderCallback) renderCallback {
    return renderCallback;
}



-(void)addToBufferAudioBufferList:(AudioBufferList *)abl frames:(UInt32)frames timestamp:(AudioTimeStamp *)time {
    TPCircularBufferCopyAudioBufferList(&_cbuffer, abl, time, kTPCircularBufferCopyAll, NULL);
}

@end
