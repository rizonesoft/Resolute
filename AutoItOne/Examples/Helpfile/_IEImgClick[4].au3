; Click on IMG by full src string

#include <IE.au3>

Local $oIE = _IE_Example("basic")
_IEImgClick($oIE, "http://www.autoitscript.com/images/logo_autoit_210x72.png")
