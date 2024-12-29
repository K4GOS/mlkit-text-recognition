//
//  VisionCameraTextRecognition.swift
//  MlkitTextRecognition
//
//  Created by Côme Paya on 27/12/2024.
//

import Foundation
import VisionCamera
import MLKitVision

import MLKitTextRecognitionJapanese
import MLKitCommon


@objc(VisionCameraTextRecognition)
public class VisionCameraTextRecognition: FrameProcessorPlugin {
  
  private var textRecognizer = TextRecognizer()
  private static let japaneseOptions = JapaneseTextRecognizerOptions()
    private var data: [Any] = []
  
  public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
    super.init(proxy: proxy, options: options)
    self.textRecognizer = TextRecognizer.textRecognizer(options: VisionCameraTextRecognition.japaneseOptions)
  }

  public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
    let buffer = frame.buffer
    let image = VisionImage(buffer: buffer)
    image.orientation = getOrientation(orientation: frame.orientation)
 
    do {
        let result = try self.textRecognizer.results(in: image)
        let blocks = VisionCameraTextRecognition.processBlocks(blocks: result.blocks)
        data = blocks
        if result.text.isEmpty {
            return []
        } else {
            return data
        }
     } catch {
         print("Failed to recognize text: \(error.localizedDescription).")
        return []
     }
      // return []
  }
    
    
    static func processBlocks(blocks:[TextBlock]) -> Array<Any> {
        var blockArray: [[String: Any]] = []
        for block in blocks {
            var blockMap: [String: Any] = [:]
            var blockDimensions: [String: Double] = [:]

            blockMap["text"] = block.text
            blockMap["isJapanese"] = isJapanese(text: block.text)

            if block.cornerPoints.count >= 3 {
                blockDimensions["originX"] = Double(block.cornerPoints[2].cgPointValue.x)
                blockDimensions["originY"] = Double(block.cornerPoints[2].cgPointValue.y)
                blockDimensions["width"] = Double(abs(block.cornerPoints[0].cgPointValue.x - block.cornerPoints[1].cgPointValue.x))
                blockDimensions["height"] = Double(abs(block.cornerPoints[0].cgPointValue.y - block.cornerPoints[2].cgPointValue.y))
                blockMap["dimensions"] = blockDimensions
            }
            blockArray.append(blockMap)
        }
        
        return blockArray
    }
    
    static func isJapanese(text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
            return false
        }
        
        // Regular expression for Japanese characters (Kanji, Hiragana, Katakana, and optionally numbers)
        let regex = "[一-龯ぁ-んァ-ン0-9]"
        let japaneseCharacters = trimmedText.filter { String($0).range(of: regex, options: .regularExpression) != nil }
        
        return !japaneseCharacters.isEmpty && Double(japaneseCharacters.count) > 0.6 * Double(trimmedText.count)
    }
    
    private func getOrientation(orientation: UIImage.Orientation) -> UIImage.Orientation {
            switch orientation {
            case .up:
              return .up
            case .left:
              return .right
            case .down:
              return .down
            case .right:
              return .left
            default:
              return .up
            }
        }
}
