import { PaintStyle, Skia } from "@shopify/react-native-skia";
import { useEvent } from "expo";
import MlkitTextRecognition, {
  useTextRecognition,
} from "mlkit-text-recognition";
import { useRef, useState } from "react";
import { Button, Text, View } from "react-native";
import {
  Camera,
  runAsync,
  useCameraDevice,
  useCameraFormat,
  useCameraPermission,
  useFrameProcessor,
  useSkiaFrameProcessor,
} from "react-native-vision-camera";
import { useSharedValue } from "react-native-worklets-core";

export default function App() {
  const onChangePayload = useEvent(MlkitTextRecognition, "onChange");

  const device = useCameraDevice("back");
  const { hasPermission } = useCameraPermission();
  const format = useCameraFormat(device, [
    { videoResolution: "max" },
    { photoResolution: "max" },
  ]);

  const [isLoading, setIsLoading] = useState(false);

  const { getTextBlocksFromFrame } = useTextRecognition();

  const blocksCoords = useSharedValue<any[]>([]);
  const paint = Skia.Paint();
  paint.setStyle(PaintStyle.Stroke);
  paint.setStrokeWidth(5);

  const frameProcessor = useSkiaFrameProcessor((frame) => {
    "worklet";
    runAsync(frame, () => {
      "worklet";
      const blocks = getTextBlocksFromFrame(frame);

      if (blocks.length > 0) {
        blocksCoords.value = blocks;
      } else {
        blocksCoords.value = [];
      }
    });
    frame.render();

    const BORDER_RADIUS = 15;
    for (const blockCoord of blocksCoords.value) {
      paint.setColor(
        Skia.Color(!blockCoord.isJapanese ? "#f58d42" : "#42f569")
      );
      const roundedRect = Skia.RRectXY(
        Skia.XYWHRect(
          blockCoord.dimensions.originX,
          blockCoord.dimensions.originY,
          blockCoord.dimensions.width,
          blockCoord.dimensions.height
        ),
        BORDER_RADIUS,
        BORDER_RADIUS
      );
      frame.drawRRect(roundedRect, paint);
    }
  }, []);

  const cameraRef = useRef<Camera>(null);

  const takePhoto = async () => {
    const file = await cameraRef.current?.takePhoto();
    // if (file) {
    //   const res = MlkitTextRecognition.recognizeTextFromUri(file.path);
    //   console.log("haha", res);
    // }
    setIsLoading(true);
    // const res = await MlkitTextRecognition.translateJapaneseText(
    //   "日本語",
    //   "fr"
    // );
    // const models = await MlkitTextRecognition.getDownloadedTranslationModels();
    // console.log(models);

    setIsLoading(false);
  };

  if (!hasPermission) return <Text>No permission</Text>;
  if (device == null) return <Text>No device</Text>;

  return (
    <>
      <Camera
        style={{ flex: 1 }}
        ref={cameraRef}
        device={device}
        // frameProcessor={frameProcessor}
        format={format}
        isActive
        photo
        pixelFormat="yuv"
        fps={45}
      />
      <View
        style={{
          position: "absolute",
          bottom: 50,
          width: 100,
          alignSelf: "center",
        }}
      >
        {isLoading ? (
          <Text>Loading...</Text>
        ) : (
          <Button title="Take photo" onPress={takePhoto} />
        )}
      </View>
    </>
  );
}
