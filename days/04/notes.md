More learning!
- Instead of `GeneralPurposeAllocator(.{}){}`, I can write `GeneralPurposeAllocator(.{}).init`
- I have tried to search for how to move memory out of a variable, or to swap variables, but no luck so far.
- I cannot comprehend how loop variables can only be `usize`, it is ridiculous that I have to write `var i: i32 = -1; while (i < 10) : (i += 1) {..}` when the syntax could just be something like `for: i32 (-1..10) |i| {..}`.
- And why is casting `usize` into `i32` done via `@as(i32, @intCast(usize_value))`? I *really* hope that I just don't know the actually useable method yet. And then I can cast `i32` back into `usize` with just `@intCast(i32_value)`! Why? How is this any safer?
- Why does `for (0..) |i| {` not work... it very clearly shows forever-loop intent, why do I have to bother with *another* while-loop?

Anyway, this day was still very easy, the only new language features I needed over the previous days were these abysmal type coercions.

