package expo.modules.mlkittextrecognition

import android.graphics.BitmapFactory
import android.util.Log
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.mrousavy.camera.frameprocessors.FrameProcessorPluginRegistry
import expo.modules.core.interfaces.Arguments
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import java.io.File
import java.net.URL

class MlkitTextRecognitionModule : Module() {
  companion object {
    init {
      FrameProcessorPluginRegistry.addFrameProcessorPlugin("getTextBlocksFromFrame") { proxy, options ->
        VisionCameraTextRecognitionPlugin(proxy, options)
      }
    }
  }
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  override fun definition() = ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('MlkitTextRecognition')` in JavaScript.
    Name("MlkitTextRecognition")

    // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
    Constants(
      "PI" to Math.PI
    )

    // Defines event names that the module can send to JavaScript.
    Events("onChange")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("hello") {
      "Hello world! 👋"
    }

    Function("recognizeTextFromUri") { uri:String ->
      val file = File(uri)
      if (!file.exists()) {
        throw Exception("File not found at: $uri")
      }

      // Load the image from the URI
      val bitmap = BitmapFactory.decodeFile(file.absolutePath)
      val inputImage = InputImage.fromBitmap(bitmap, 0)

      // Perform text recognition
      val recognizer = TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build())
      val visionText = try {
        Tasks.await(recognizer.process(inputImage))
      } catch (e: Exception) {
        throw Exception("Text recognition failed: ${e.message}")
      }
      val res = ArrayList<String>()
      visionText.textBlocks.forEach{textBlock -> res.add(textBlock.text.lines().joinToString(""))}
      res
    }

    AsyncFunction("translateJapaneseText") { japaneseText: String, targetLanguage: String, promise: Promise ->
      val options = TranslatorOptions.Builder()
        .setSourceLanguage(TranslateLanguage.JAPANESE)
        .setTargetLanguage(targetLanguage)
        .build()
      val japaneseTranslator = Translation.getClient(options)

      val conditions = DownloadConditions.Builder()
        .requireWifi()
        .build()

      try {
        Tasks.await(japaneseTranslator.downloadModelIfNeeded(conditions))
      } catch (e: Exception) {
        e.printStackTrace()
        Log.e("Error","Model has not been downloaded")
      }

      val result = Tasks.await(japaneseTranslator.translate(japaneseText))
      promise.resolve(result)
    }

    AsyncFunction("getDownloadedTranslationModels") { promise: Promise ->
      val modelManager = RemoteModelManager.getInstance()
      // Get translation models stored on the device.
      val models = Tasks.await(modelManager.getDownloadedModels(TranslateRemoteModel::class.java))
      val modelNames = ArrayList<String>()
      promise.resolve(modelNames.apply { models.forEach { add(it.language) } })
    }

    AsyncFunction("uninstallLanguageModel") { targetLanguage: String, promise: Promise ->
      val modelManager = RemoteModelManager.getInstance()
      val modelToDelete = TranslateRemoteModel.Builder(targetLanguage).build()
      Tasks.await(modelManager.deleteDownloadedModel(modelToDelete))
      promise.resolve("Model for language $targetLanguage has been successfully deleted")
    }



    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setValueAsync") { value: String ->
      // Send an event to JavaScript.
      sendEvent("onChange", mapOf(
        "value" to value
      ))
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of
    // the view definition: Prop, Events.
//    View(MlkitTextRecognitionView::class) {
//      // Defines a setter for the `url` prop.
//      Prop("url") { view: MlkitTextRecognitionView, url: URL ->
//        view.webView.loadUrl(url.toString())
//      }
//      // Defines an event that the view can send to JavaScript.
//      Events("onLoad")
//    }
  }
}
