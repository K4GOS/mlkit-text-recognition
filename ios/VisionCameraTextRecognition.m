//
//  VisionCameraTextRecognition.m
//  MlkitTextRecognition
//
//  Created by Côme Paya on 27/12/2024.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#import "MlkitTextRecognition-Swift.h"
#import "VisionCameraTextRecognition-Bridging-Header.h"

// // Example for a Swift Frame Processor plugin automatic registration
//VISION_EXPORT_SWIFT_FRAME_PROCESSOR(VisionCameraTextRecognition, getTextBlocksFromFrame)
@interface VisionCameraTextRecognition (FrameProcessorPluginLoader)
@end

@implementation VisionCameraTextRecognition (FrameProcessorPluginLoader)

+ (void)load
{
    [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"getTextBlocksFromFrame"
                                        withInitializer:^FrameProcessorPlugin* (VisionCameraProxyHolder* proxy, NSDictionary* options) {
        return [[VisionCameraTextRecognition alloc] initWithProxy:proxy withOptions:options];
    }];
}

@end
