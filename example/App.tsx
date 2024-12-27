import { useEvent } from "expo";
import MlkitTextRecognition, {
  useTextRecognition,
} from "mlkit-text-recognition";
import { useRef } from "react";
import { Button, Text, View } from "react-native";
import {
  Camera,
  useCameraDevice,
  useCameraFormat,
  useCameraPermission,
  useFrameProcessor,
} from "react-native-vision-camera";

export default function App() {
  const onChangePayload = useEvent(MlkitTextRecognition, "onChange");

  const device = useCameraDevice("back");
  const { hasPermission } = useCameraPermission();
  const format = useCameraFormat(device, [
    { videoResolution: "max" },
    { photoResolution: "max" },
  ]);
  const { getTextBlocksFromFrame } = useTextRecognition();
  // console.log(
  //   console.log(MlkitTextRecognition.recognizeTextFromFrame("scasc"))
  // );

  const frameProcessor = useFrameProcessor((frame) => {
    "worklet";
    const text = getTextBlocksFromFrame(frame);
    console.log(text);
  }, []);

  const cameraRef = useRef<Camera>(null);

  const takePhoto = async () => {
    const file = await cameraRef.current?.takePhoto();
    if (file) {
      // const res = MlkitTextRecognition.recognizeTextFromUri(file.path);
      // console.log(res);
    }
  };

  // if (!hasPermission) return <Text>No permission</Text>;
  if (device == null) return <Text>No device</Text>;

  return (
    <>
      <Camera
        style={{ flex: 1 }}
        ref={cameraRef}
        device={device}
        frameProcessor={frameProcessor}
        format={format}
        focusable
        isActive
        photo
        pixelFormat="yuv"
        fps={format?.maxFps || 30}
      />
      <View
        style={{
          position: "absolute",
          bottom: 50,
          width: 100,
          alignSelf: "center",
        }}
      >
        <Button title="Start" onPress={takePhoto} />
      </View>
    </>
  );
}
