import { Dialog as SheetPrimitive } from "bits-ui";
import { cn } from "$lib/utils";

const Root = SheetPrimitive.Root;
const Trigger = SheetPrimitive.Trigger;
const Close = SheetPrimitive.Close;
const Portal = SheetPrimitive.Portal;
const Overlay = SheetPrimitive.Overlay;
const Content = SheetPrimitive.Content;
const Header = (props: { class?: string; children?: import("svelte").Snippet }) => props;
const Footer = (props: { class?: string; children?: import("svelte").Snippet }) => props;
const Title = SheetPrimitive.Title;
const Description = SheetPrimitive.Description;

export {
	Root,
	Trigger,
	Close,
	Portal,
	Overlay,
	Content,
	Header,
	Footer,
	Title,
	Description,
};
