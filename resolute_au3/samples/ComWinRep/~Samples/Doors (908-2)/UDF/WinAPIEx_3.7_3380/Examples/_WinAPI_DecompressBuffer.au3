#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $pBuffer[2], $Data, $Size

; Create compressed and uncompressed buffers
For $i = 0 To 1
	$pBuffer[$i] = _WinAPI_CreateBuffer(1024)
Next

; Compress binary data
$Data = Binary('0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF')
$Size = BinaryLen($Data)
DllStructSetData(DllStructCreate('byte[' & $Size & ']', $pBuffer[0]), 1, $Data)
$Size = _WinAPI_CompressBuffer($pBuffer[0], $Size, $pBuffer[1], 1024, BitOR($COMPRESSION_FORMAT_LZNT1, $COMPRESSION_ENGINE_MAXIMUM))
If Not @error Then
	ConsoleWrite('Compressed:   ' & DllStructGetData(DllStructCreate('byte[' & $Size & ']', $pBuffer[1]), 1) & @CR)
EndIf

; Decompress data
$Size = _WinAPI_DecompressBuffer($pBuffer[0], 1024, $pBuffer[1], $Size)
If Not @error Then
	ConsoleWrite('Uncompressed: ' & DllStructGetData(DllStructCreate('byte[' & $Size & ']', $pBuffer[0]), 1) & @CR)
EndIf

; Free memory
For $i = 0 To 1
	_WinAPI_FreeMemory($pBuffer[$i])
Next
