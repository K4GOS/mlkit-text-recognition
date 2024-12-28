import type { Frame } from "react-native-vision-camera";

type BlockDimensions = {
  height: number;
  width: number;
  x: number;
  y: number;
};

export type Block = {
  isJapanese: boolean;
  text: string;
  dimensions?: BlockDimensions;
};

export type TextRecognition = {
  getTextBlocksFromFrame: (frame: Frame) => Block[];
};
