# **Resource** object reference

**Resource** object allow access different resources embedded into binary.

## Functions

### resource.getEntry

``resource.getEntry(rTree, hierList)``

| Argument | Description |
| -------- | ----------- |
| rTree    | Resource tree object. |
| hierList | List of ids for search in tree. |

Returns resource entry from resource tree.

Example:

Search for resource GROUP_ICON with given attributes

``entry = resource.getEntry(rsrcTree, [0xE, 0x72, 0x412]);``

### resource.dir

``resource.dir(rsrcAddr, addrOffset, id)``

Read dir object at given address.

### resource.file

``resource.file(rsrcAddr, addrOffset, id)``

Read dir object at given address.

### resource.readIconFile

``resource.readIconFile(fname)``

Read icon file from disk into object.

### resource.selectIconFile

``resource.selectIconFile(varName, def)``

| Argument | Description |
| -------- | ----------- |
| varName  | Variable name. |
| def      | Default file name. |

Ask path and read icon file from disk.

Returns file parsed file from disk same as resource.readIconFile.

Selected path stored in input variable varName.
