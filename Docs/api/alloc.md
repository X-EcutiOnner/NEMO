# **alloc** object reference

**alloc** object allow low level allocations in loaded binary.

## Functions

### alloc.find

``alloc.find(size)``

Search free area in exe with given size.

### alloc.reserve

``alloc.reserve(rawAddr, size)``

Mark free area at address rawAddr in exe as used.
