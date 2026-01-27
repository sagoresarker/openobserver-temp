/// <reference types="vite/client" />

// Build-time constants injected by Vite
declare const __COMMIT_HASH__: string;
declare const __BUILD_TIME__: number;

// Platform UI (simplified nav + dev-focused design) is on by default. Set VITE_PLATFORM_UI=false to disable.
interface ImportMetaEnv {
  readonly VITE_PLATFORM_UI?: string;
}
