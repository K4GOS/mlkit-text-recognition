import { requireNativeView } from 'expo';
import * as React from 'react';

import { MlkitTextRecognitionViewProps } from './MlkitTextRecognition.types';

const NativeView: React.ComponentType<MlkitTextRecognitionViewProps> =
  requireNativeView('MlkitTextRecognition');

export default function MlkitTextRecognitionView(props: MlkitTextRecognitionViewProps) {
  return <NativeView {...props} />;
}
