#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>

Example()

Func Example()
	Local $iAlgorithm = $CALG_SHA1

	Local $hGUI = GUICreate("Hash File", 500, 100)
	Local $idInput = GUICtrlCreateInput(@ScriptFullPath, 5, 5, 200, 20)
	Local $idBrowse = GUICtrlCreateButton("...", 210, 5, 35, 20)
	Local $idCombo = GUICtrlCreateCombo("", 250, 5, 100, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData($idCombo, "MD2 (128bit)|MD4 (128bit)|MD5 (128bit)|SHA1 (160bit)|SHA_256 (256bit)|SHA_384 (384bit)|SHA_512 (512bit)", "SHA1 (160bit)")
	Local $idCalculate = GUICtrlCreateButton("Calculate", 400, 40, 65, 25)
	Local $idHashLabel = GUICtrlCreateEdit("Hash Digest", 5, 45, 350, 40)
	GUISetState(@SW_SHOW, $hGUI)

	_Crypt_Startup() ; To optimize performance start the crypt library.

	Local $dHash = 0, _
			$sRead = ""
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idBrowse
				Local $sFilePath = FileOpenDialog("Open a file", "", "All files (*.*)") ; Select a file to find the hash.
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idInput, $sFilePath) ; Set the inputbox with the filepath.
				GUICtrlSetData($idHashLabel, "Hash Digest") ; Reset the hash digest label.

			Case $idCombo ; Check when the combobox is selected and retrieve the correct algorithm.
				Switch GUICtrlRead($idCombo) ; Read the combobox selection.
					Case "MD2 (128bit)"
						$iAlgorithm = $CALG_MD2

					Case "MD4 (128bit)"
						$iAlgorithm = $CALG_MD4

					Case "MD5 (128bit)"
						$iAlgorithm = $CALG_MD5

					Case "SHA1 (160bit)"
						$iAlgorithm = $CALG_SHA1

                    Case  "SHA_256 (256bit)"
                        $iAlgorithm = $CALG_SHA_256

                    Case "SHA_384 (384bit)"
                        $iAlgorithm = $CALG_SHA_384

                    Case "SHA_512 (512bit)"
                        $iAlgorithm = $CALG_SHA_512

				EndSwitch

			Case $idCalculate
				$sRead = GUICtrlRead($idInput)
				If StringStripWS($sRead, $STR_STRIPALL) <> "" And FileExists($sRead) Then ; Check there is a file available to find the hash digest
					$dHash = _Crypt_HashFile($sRead, $iAlgorithm) ; Create a hash of the file.
					GUICtrlSetData($idHashLabel, $dHash) ; Set the hash digest label with the hash data.
				EndIf
		EndSwitch
	WEnd

	GUIDelete($hGUI) ; Delete the previous GUI and all controls.
	_Crypt_Shutdown() ; Shutdown the crypt library.
EndFunc   ;==>Example
