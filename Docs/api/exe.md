# **exe** object reference

**exe** object allow different manipulation with loaded client exe.

## Actual functions

### exe.getUserInput

```
exe.getUserInput(varName, valType, title, prompt, value)
exe.getUserInput(varName, valType, title, prompt, value, minValue)
exe.getUserInput(varName, valType, title, prompt, value, minValue, maxValue)
```

Request information from user.

### exe.getClientDate

``exe.getClientDate()``

Return client date.

### exe.isThemida

``exe.isThemida()``

Return true if client was packed with themida.

### exe.emptyPatch

``exe.emptyPatch(patch)``

Remove patched data for given patch.



## Legacy functions
Better not use this functions. This functions working with bugs or can be removed in future.

### exe.fetchDWord

``exe.fetchDWord(rawAddr)``

Outdated.

Read dword from given address.

### exe.fetchQWord

``exe.fetchQWord(rawAddr)``

Outdated.

Read qword from given address.

### exe.fetchWord

``exe.fetchWord(rawAddr)``

Outdated.

Read word from given address.

### exe.fetchUByte

Outdated.

``exe.fetchUByte(rawAddr)``

Outdated.

Read unsigned byte from given address.

### exe.fetchByte

``exe.fetchByte(rawAddr)``

Outdated.

Read signed byte from given address.

### exe.fetchHex

``exe.fetchHex(rawAddr, size)``

Outdated.

Read hex bytes from given address.

### exe.fetch

``exe.fetch(addr, size)``

Outdated.

Read null terminated string from given address.

### exe.findCode

```
exe.findCode(code)
exe.findCode(code, codeType)
exe.findCode(code, codeType, useMask)
exe.findCode(code, codeType, useMask, mask)
```

Outdated.

Search first hex bytes pattern in main executable section.

Recommended to switch to pe.findCode

### exe.findCodes

```
exe.findCodes(code)
exe.findCodes(code, codeType)
exe.findCodes(code, codeType, useMask)
exe.findCodes(code, codeType, useMask, mask)
```

Outdated.

Search all hex bytes pattern in main executable section.

Recommended to switch to pe.findCodes

### exe.find

```
exe.find(code)
exe.find(code, codeType)
exe.find(code, codeType, useMask)
exe.find(code, codeType, useMask, mask)
exe.find(code, codeType, useMask, mask, start)
exe.find(code, codeType, useMask, mask, start, finish)
```

Outdated.

Search first hex bytes pattern in whole binary.

Recommended to switch to pe.find

### exe.findAll

```
exe.findAll(code)
exe.findAll(code, codeType)
exe.findAll(code, codeType, useMask)
exe.findAll(code, codeType, useMask, mask)
exe.findAll(code, codeType, useMask, mask, start)
exe.findAll(code, codeType, useMask, mask, start, finish)
```

Outdated.

Search all hex bytes pattern in whole binary.

Recommended to switch to pe.findAll

### exe.findString

```
exe.findString(pattern)
exe.findString(pattern, addrType)
exe.findString(pattern, addrType, prefixZero)
```

Outdated.

Find string in whole binary.

### exe.Raw2Rva

``exe.Raw2Rva(rawAddr)``

Outdated.

Convert raw address into virtual address.

If address wrong, return -1.

Recommended to switch to pe.rawToVa

### exe.Rva2Raw

``exe.Rva2Raw(vaAddr)``

Outdated.

Convert virtual address into raw address.

If address wrong, return -1.

Recommended to switch to pe.vaToRaw

### exe.getROffset

``exe.getROffset(section)``

Outdated.

Return raw address of given section.

Recommended to switch to pe.sectionRaw(section)[0]

### exe.getRSize

``exe.getRSize(section)``

Outdated.

Return raw size of given section.

### exe.getVOffset

``exe.getVOffset(section)``

Outdated.

Return rva address of given section.

Recommended to switch to pe.sectionVa(section)[0]

### exe.getVSize

``exe.getVSize(section)``

Outdated.

Return virtual size of given section.

### exe.getPEOffset

``exe.getPEOffset()``

Outdated.

Return PE header raw address.

### exe.getImageBase

``exe.getImageBase()``

Outdated.

Return image base.

### exe.match

Please use pe.match

### exe.fetchValue

Please use pe.fetchValue

### exe.fetchValueSimple

Please use pe.fetchValueSimple

### exe.fetchRelativeValue

Please use pe.fetchRelativeValue

### exe.fetchHexBytes

Please use pe.fetchHexBytes

### exe.replace

Please use pe.replace

### exe.replaceByte

Please use pe.replaceByte

### exe.replaceWord

Please use pe.replaceWord

### exe.replaceDWord

Please use pe.replaceDWord

### exe.replaceAsmText

Please use pe.replaceAsmText

### exe.replaceAsmFile

Please use pe.replaceAsmFile

### exe.setValue

Please use pe.setValue

### exe.setValueSimple

Please use pe.setValueSimple

### exe.setJmpVa

Please use pe.setJmpVa

### exe.setJmpRaw

Please use pe.setJmpRaw

### exe.setNops

Please use pe.setNops

### exe.setNopsRange

Please use pe.setNopsRange

### exe.setShortJmpVa

Please use pe.setShortJmpVa

### exe.setShortJmpRaw

Please use pe.setShortJmpRaw

### exe.findZeros

``exe.findZeros(size)``

Search first empty block in binary with given size.

### exe.insert

```
exe.insert(rawAddr, size, code)
exe.insert(rawAddr, size, code, codeType)
```

Insert custom block of bytes at address returned by exe.findZeros.

### exe.insertAsmText

Please use pe.insertAsmText

### exe.insertAsmTextObj

Please use pe.insertAsmTextObj

### exe.insertAsmFile

Please use pe.insertAsmFile

### exe.insertDWord

Please use pe.insertDWord

### exe.insertHex

Please use pe.insertHex
