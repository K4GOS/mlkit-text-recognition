import { NativeModule, requireNativeModule } from "expo";

import { MlkitTextRecognitionModuleEvents } from "./MlkitTextRecognition.types";

declare class MlkitTextRecognitionModule extends NativeModule<MlkitTextRecognitionModuleEvents> {
  PI: number;
  recognizeTextFromUri(uri: string): string[];
  translateJapaneseText(
    japaneseText: string,
    targetLanguage: string
  ): Promise<string>;
  getDownloadedTranslationModels(): Promise<string[]>;
  uninstallLanguageModel(targetLanguage: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<MlkitTextRecognitionModule>(
  "MlkitTextRecognition"
);
