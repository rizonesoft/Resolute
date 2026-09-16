#include-once



Func _SetDescription()

	Switch @GUI_CtrlId
		Case $BTNHLP_MALWARE1[0]
			_ShowDescription("Terminate (Kill) known malware processes so that security programs can run and clean your computer of infections. " & _
			"This option will also remove incorrect executable associations and policies that stop us from using certain troubleshooting tools." & @CRLF & @CRLF & _
			"This option will not delete any files; this means that the infections will return upon rebooting your computer. Check out the Malware " & _
			"troubleshooting section for options to clean your computer of infections.")
		Case $BTNHLP_SYSTEM1[10]
			_ShowDescription("Repair Font Registrations.")

	EndSwitch

EndFunc


Func _SetPageDescription($iPage)

	Switch $iPage
		Case 8
			_ShowDescription(	"'Malware' is a generic term for malicious software. This covers Spyware, Viruses, Rootkits, and Rogueware. " & _
								"Some common symptoms of malware infections are popups saying that your computer is infected, " & _
								"Antivirus programs you have not installed asking you to buy them, restricted access to certain Windows features " & _
								"and Windows not working correctly. The repair options above will attempt to repair your computer after a " & _
								"malware infection. Your personal data will NOT be affected." & @CRLF & @CRLF & _
								"Please note that Alien Hive is not an Anti-Malware solution and you will need to clean your computer with a few " & _
								"of the recommended solutions before running the malware repair options.")
		Case 12
			_ShowDescription(	"Run the repair options above if for any reason, you cannot connect to the internet properly, " & _
								"or the internet is behaving erratically when connected. Here we will attempt to repair many issues like, " & _
								"Windows not updating, connecting a printer, or even detecting computers on your workgroup.")
		Case 17
			_ShowDescription(	"If your computer is running slower than normal, run the options above. " & _
								"Unnecessary programs often start when you log in, slowing down your computer, " & _
								"and can make your computer slow and unusable. There are also many other causes of performance issues.")
	EndSwitch

EndFunc