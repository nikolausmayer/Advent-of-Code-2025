Ok, day 2. I'm looking up other Zig AoC stuff to get some wrist slaps.

- I have learned that I can `return error.ErrorName` instead of `return error{ErrorName}.ErrorName`. GitHub Copilot (Claude 4.5, I believe) was no help here, it claimed that this is not possible.
- Apparently I should `defer` my allocator's own `.deinit()`, too. I do not yet know why; but then again I do not yet know what the `deinit`s do either. Yet.
- With `std.fs.cwd().openFile*Z*` I do not need to `std.mem.span(..)` my filename in `std.os.argv[1]`. (I'm on 0.15.2, so AFAICT no `std.Io` for me yet).
- Even better, with `std.fs.cwd().readFileAlloc` I can actually read the entire file without bothering with manual buffer allocation. Alas, I need `std.mem.span` again...
- Speaking of allocators, I don't yet grok what `std.heap.GeneralPurposeAllocator`*is* and why I have to both instantiate it and call its `.allocator()` *to actually get an allocator*.
- I think my slow stdout comes from using Zig in a Docker container, not Zig itself. I even went through the trouble of using a buffered writer, and it's still not great.


