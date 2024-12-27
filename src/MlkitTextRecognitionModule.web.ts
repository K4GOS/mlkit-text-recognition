import { registerWebModule, NativeModule } from 'expo';

import { MlkitTextRecognitionModuleEvents } from './MlkitTextRecognition.types';

class MlkitTextRecognitionModule extends NativeModule<MlkitTextRecognitionModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(MlkitTextRecognitionModule);
