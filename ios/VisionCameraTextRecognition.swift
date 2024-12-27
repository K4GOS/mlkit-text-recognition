//
//  VisionCameraTextRecognition.swift
//  MlkitTextRecognition
//
//  Created by Côme Paya on 27/12/2024.
//

import Foundation
import VisionCamera

@objc(VisionCameraTextRecognition)
public class VisionCameraTextRecognition: FrameProcessorPlugin {
  public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
    super.init(proxy: proxy, options: options)
  }

  public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
    let buffer = frame.buffer
    let orientation = frame.orientation
    // code goes here
    return "Hello from swift !"
  }
}
