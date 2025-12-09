- Overall, a significant increase in complexity over the previous days, but nothing hard *yet*.
- Aha, I think my previous trouble with `defer` might be because *`defer` captures the state of a variable at the point of the `defer` statement`*. If the variable is mutable, this can mean that when `defer` procs, it tries to access memory that is no longer valid. I had assumed that what is captured is *the code of the statement*, not any execution of it, but that is apparently not the case.
- "`Allocator.create` and `Allocator.destroy` are for allocating/freeing single items `*T`. `Allocator.alloc` and `Allocator.free` are for allocating/freeing slices `[]T`." -- Thanks, internet!
- I should not `defer for`-deinit `ArrayList`s of *structs*.
- It looks like I need to define `structs` globally if I want them to have member functions? Otherwise it seems like their type is not known and so I cannot use it in the function signature...
- The task description for part 1 seems ambiguous. It says to "make the X shortest connections". The correct solution is to *not skip* connections where two nodes are already in the same circuit, even though I think this should not count as "making that connection".
- I am quite happy that I remembered *most* of UnionFind from when I dabbled with LeetCode.

