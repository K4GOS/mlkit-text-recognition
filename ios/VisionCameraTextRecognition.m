//
//  VisionCameraTextRecognition.m
//  MlkitTextRecognition
//
//  Created by Côme Paya on 27/12/2024.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#import "VisionCameraTextRecognition-Bridging-Header.h"

// if else to make it work both for the example app of the expo native module
// and when we npm install it in another app
#if __has_include("MlkitTextRecognition/MlkitTextRecognition-Swift.h")
#import "MlkitTextRecognition/MlkitTextRecognition-Swift.h"
#else
#import "MlkitTextRecognition-Swift.h"
#endif

// We export our swift plugin
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
