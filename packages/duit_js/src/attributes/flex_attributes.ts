import type { Clip } from "./clip";
import type { CrossAxisAlignment } from "./cross_axis_alignment";
import type { MainAxisAlignment } from "./main_axis_alignment";
import type { TextDirection } from "./text_direction";
import type { VerticalDirection } from "./vertical_direction";

export interface FlexAttributes {
  mainAxisAlignment?: keyof typeof MainAxisAlignment;
  mainAxisSize?: string;
  crossAxisAlignment?: keyof typeof CrossAxisAlignment;
  textDirection?: keyof typeof TextDirection;
  verticalDirection?: keyof typeof VerticalDirection;
  clipBehavior?: keyof typeof Clip;
}
