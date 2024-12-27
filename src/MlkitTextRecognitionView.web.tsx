import * as React from 'react';

import { MlkitTextRecognitionViewProps } from './MlkitTextRecognition.types';

export default function MlkitTextRecognitionView(props: MlkitTextRecognitionViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
