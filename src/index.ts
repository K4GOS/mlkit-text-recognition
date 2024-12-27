// Reexport the native module. On web, it will be resolved to MlkitTextRecognitionModule.web.ts
// and on native platforms to MlkitTextRecognitionModule.ts
export { default } from "./MlkitTextRecognitionModule";
export { useTextRecognition } from "./useTextRecognition";
