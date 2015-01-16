//
//  MyAudioReceiver.h
//  
//
//  Created by Sander on 1/13/15.
//
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import "TPCircularBuffer.h"
#import "TPCircularBuffer+AudioBufferList.h"


@interface MyAudioReceiver : NSObject <AEAudioReceiver, AEAudioPlayable> {
    
}

@property (nonatomic, assign) TPCircularBuffer cbuffer;

static void receiverCallback(__unsafe_unretained MyAudioReceiver *THIS,
                             __unsafe_unretained AEAudioController *audioController,
                             void                     *source,
                             const AudioTimeStamp     *time,
                             UInt32                    frames,
                             AudioBufferList          *audio);

-(void) initAudioReceiver;



@end
