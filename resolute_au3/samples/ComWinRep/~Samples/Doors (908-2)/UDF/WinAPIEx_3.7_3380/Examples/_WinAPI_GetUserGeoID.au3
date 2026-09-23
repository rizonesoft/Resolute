#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $ID = _WinAPI_GetUserGeoID()

ConsoleWrite('ID:        0x' & Hex($ID) & @CR)
ConsoleWrite('Latitude:  ' & _WinAPI_GetGeoInfo($ID, $GEO_LATITUDE) & @CR)
ConsoleWrite('Longitude: ' & _WinAPI_GetGeoInfo($ID, $GEO_LONGITUDE) & @CR)
ConsoleWrite('Name:      ' & _WinAPI_GetGeoInfo($ID, $GEO_FRIENDLYNAME) & @CR)
ConsoleWrite('ISO code:  ' & _WinAPI_GetGeoInfo($ID, $GEO_ISO3) & @CR)
