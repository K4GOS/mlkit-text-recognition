import { useMemo } from "react";
import { VisionCameraProxy, type Frame } from "react-native-vision-camera";

function createTextRecognitionPlugin(): any {
  const plugin = VisionCameraProxy.initFrameProcessorPlugin(
    "getTextBlocksFromFrame",
    {}
  );
  if (!plugin) {
    throw new Error("LINKING_ERROR: no plugin getTextBlocksFromFrame detected");
  }
  return {
    getTextBlocksFromFrame: (frame: Frame): any[] => {
      "worklet";
      // @ts-ignore
      return plugin.call(frame) as Block[];
    },
  };
}

export function useTextRecognition(): any {
  return useMemo(() => createTextRecognitionPlugin(), []);
}
