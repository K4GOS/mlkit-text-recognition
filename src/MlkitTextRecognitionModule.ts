import { NativeModule, requireNativeModule } from 'expo';

import { MlkitTextRecognitionModuleEvents } from './MlkitTextRecognition.types';

declare class MlkitTextRecognitionModule extends NativeModule<MlkitTextRecognitionModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<MlkitTextRecognitionModule>('MlkitTextRecognition');
