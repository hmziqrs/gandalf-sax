import { Dialog as SheetPrimitive } from "bits-ui";

const Root = SheetPrimitive.Root;
const Trigger = SheetPrimitive.Trigger;
const Close = SheetPrimitive.Close;

export { Root, Trigger, Close };
export { default as SheetOverlay } from "./SheetOverlay.svelte";
export { default as SheetContent } from "./SheetContent.svelte";
export { default as SheetHeader } from "./SheetHeader.svelte";
export { default as SheetFooter } from "./SheetFooter.svelte";
export { default as SheetTitle } from "./SheetTitle.svelte";
export { default as SheetDescription } from "./SheetDescription.svelte";
