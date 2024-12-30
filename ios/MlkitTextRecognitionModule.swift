import ExpoModulesCore
import MLKitTextRecognitionJapanese
import MLKitCommon
import MLKitVision
import MLKitTranslate

public class MlkitTextRecognitionModule: Module {
  // See https://docs.expo.dev/modules/module-api for more details about available components.
    public func definition() -> ModuleDefinition {
        // The module will be accessible from `requireNativeModule('MlkitTextRecognition')` in JavaScript.
        Name("MlkitTextRecognition")
        
        // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
        Constants([
            "PI": Double.pi
        ])
        
        // Defines event names that the module can send to JavaScript.
        Events("onChange")
        
        // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
        Function("hello") {
            return "Hello world! 👋"
        }
        
        Function("recognizeTextFromUri") { (uri:String) -> Any in
            let japaneseOptions = JapaneseTextRecognizerOptions()
            let japaneseTextRecognizer = TextRecognizer.textRecognizer(options: japaneseOptions)
            let image =  UIImage(contentsOfFile: uri)
            if image != nil {
                do {
                    let visionImage = VisionImage(image: image!)
                    // Because Miwago only supports portrait mode (no landscape for now but see the getOrientation in comment for later)
                    visionImage.orientation = UIImage.Orientation.right
                    let result = try japaneseTextRecognizer.results(in: visionImage)
                    var blockTexts: [String] = []
                    for block in result.blocks {
                        blockTexts.append(block.text.replacingOccurrences(of: "\n", with: ""))
                    }
                    return blockTexts
                   
                } catch {
                    return "Error Processing Image"
                }
            } else {
                return "Error: Can't find photo with uri: " + uri
            }
        }
        
        AsyncFunction("translateJapaneseText") {(japaneseText: String, targetLanguage: String) async -> String in
            let options = TranslatorOptions(sourceLanguage: .japanese, targetLanguage: TranslateLanguage(rawValue: targetLanguage))
            let japaneseTranslator = Translator.translator(options: options)
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: false,
                allowsBackgroundDownloading: true
            )
     
            do {
                try await japaneseTranslator.downloadModelIfNeeded(with: conditions)
                let translatedText = try await japaneseTranslator.translate(japaneseText)
                return translatedText
            } catch {
                return "Error while downloading the model, make sure you are connected to the internet."
            }
        }
        
        AsyncFunction("getDownloadedTranslationModels") { () async -> [String] in
            let localModels = ModelManager.modelManager().downloadedTranslateModels
            var downloadedModelsLanguages: [String] = []
            for model in localModels {
                downloadedModelsLanguages.append(model.language.rawValue)
            }
            return downloadedModelsLanguages
        }
        
        AsyncFunction("uninstallLanguageModel") {(targetLanguage: String) async -> String in
            let modelToDelete = TranslateRemoteModel.translateRemoteModel(language: TranslateLanguage(rawValue: targetLanguage))
            do {
                try await ModelManager.modelManager().deleteDownloadedModel(modelToDelete)
            } catch {
                return "Error: Could not delete model: " + targetLanguage + "."
            }
            return "Model deleted successfully."
        }
        
//        private func getOrientation(
//            orientation: String
//        ) -> UIImage.Orientation {
//            switch orientation {
//            case "portrait":
//                return .right
//            case "landscapeLeft":
//                return .up
//            case "portraitUpsideDown":
//                return .left
//            case "landscapeRight":
//                return  .down
//            default:
//                return .up
//            }
//            
//        }
    
    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setValueAsync") { (value: String) in
      // Send an event to JavaScript.
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    // View(MlkitTextRecognitionView.self) {
    //   // Defines a setter for the `url` prop.
    //   Prop("url") { (view: MlkitTextRecognitionView, url: URL) in
    //     if view.webView.url != url {
    //       view.webView.load(URLRequest(url: url))
    //     }
    //   }

    //   Events("onLoad")
    // }
  }
}
