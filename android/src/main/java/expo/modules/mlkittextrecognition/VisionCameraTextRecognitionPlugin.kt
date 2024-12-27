package expo.modules.mlkittextrecognition

import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.mrousavy.camera.frameprocessors.Frame
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessors.VisionCameraProxy
import kotlin.math.abs

class VisionCameraTextRecognitionPlugin(proxy: VisionCameraProxy, options: Map<String, Any>?) :
    FrameProcessorPlugin() {

    private val japaneseOption = JapaneseTextRecognizerOptions.Builder().build()
    private val recognizer = TextRecognition.getClient(japaneseOption)

//  init {
//    val language = options?.get("language").toString()
//  }

    override fun callback(frame: Frame, arguments: Map<String, Any>?): List<Any> {
        val image = frame.image
        val inputImage = InputImage.fromMediaImage(image, 0)

        // Perform text recognition
        val visionText = try {
            Tasks.await(recognizer.process(inputImage))
        } catch (e: Exception) {
            throw Exception("Text recognition failed: ${e.message}")
        }

        if (visionText.text.isEmpty()) {
            return ArrayList()
        }

        return getBlocks(visionText.textBlocks)
    }

    companion object {
        private fun getBlocks(blocks: MutableList<Text.TextBlock>): ArrayList<Any> {
            val blockArray = ArrayList<Any>()

            for (block in blocks) {
                val blockMap = HashMap<String, Any>()
                val blockDimensions = HashMap<String, Int>()
                blockMap["text"] = block.text
                blockMap["isJapanese"] = isJapanese(block.text)

                if (block.cornerPoints !== null && (block.cornerPoints?.size ?: 0) >= 3) {
                    blockDimensions["originX"] = block.cornerPoints!![2].x
                    blockDimensions["originY"] = block.cornerPoints!![2].y
                    blockDimensions["width"] = abs(block.cornerPoints!![0].x - block.cornerPoints!![1].x)
                    blockDimensions["height"] = abs(block.cornerPoints!![0].y - block.cornerPoints!![2].y)
                    blockMap["dimensions"] = blockDimensions
                }
                blockArray.add(blockMap)
            }
            return blockArray
        }

        private fun isJapanese(text: String):Boolean {
            if (text.trim().isEmpty()) {
                return false
            }
            val japaneseCharacters = text.toList().filter { it.toString().matches(Regex("[一-龯ぁ-んア-ン0-9]")) }
            return japaneseCharacters.isNotEmpty() && japaneseCharacters.size > 0.6 * text.length
        }

//    private fun getCornerPoints(points: Array<Point>): WritableNativeArray {
//      val cornerPoints = WritableNativeArray()
//      points.forEach { point ->
//        cornerPoints.pushMap(WritableNativeMap().apply {
//          putInt("x", point.x)
//          putInt("y", point.y)
//        })
//      }
//      return cornerPoints
//    }
//
//    private fun getFrame(boundingBox: Rect?): WritableNativeMap {
//      return WritableNativeMap().apply {
//        boundingBox?.let {
//          putDouble("x", it.exactCenterX().toDouble())
//          putDouble("y", it.exactCenterY().toDouble())
//          putInt("width", it.width())
//          putInt("height", it.height())
//          putInt("boundingCenterX", it.centerX())
//          putInt("boundingCenterY", it.centerY())
//        }
//      }
//    }
    }
}