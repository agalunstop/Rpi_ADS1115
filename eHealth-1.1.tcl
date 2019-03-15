#XML Format for the Sensor Data:
#<additionalInfo><sensor><patientFirstName>R.</patientFirstName><patientLastName>Hari</patientLastName><bloodPressureMeasurement>N/A</bloodPressureMeasurement><bodyTemperature>97</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>N/A</urineAnalysis></sensor></additionalInfo>

package require TclCurl
package require Expect
package require Tk


set IDorDATA 0
set sensor 9
set ReportLocked 0
set presentPointx 0
set presentPointy 0
set pastPointx 0
set pastPointy 0
set AirFlowValues 0

array set params {
    title     {Airflow}
    width     400
    height    240
    delay     10
    x         {$t / 50.}
    plot      {sin($x)}
    t0        0
    #         {t1 < t0: non-stop scrolling}
    t1        -1
    accuracy  1.e-2
}


##Connection to WiSeKAr
set wisekar [ ::curl::init]
$wisekar configure -url "http://wisekar.iitd.ernet.in/api/elivestock/resource.php/resource/event" -postfields "key=XR24cVrD9B2a52tZsrJqsorJtU10&datasetId=9&nodeId=46&typeId=16&status=0"

##Checking the file created for Arduino USB
set status [catch {exec ls /dev | grep ACM > ArduinoConnected} result]
if { $status == 0 } {
  tk_messageBox -message "Device OK" -type ok
} else {
  tk_messageBox -message "Device Error : Arduino not found." -type ok
}
exec ls /dev | grep ACM > ArduinoConnected
set FileSize [file size "ArduinoConnected"]

##Opening appropriate serial port for Arduino
set SerialPortInfo [open "ArduinoConnected" RDWR]
if { [file size "ArduinoConnected"] == 0 } {
  tk_messageBox -message "Device Error : Arduino not found." -type ok
  close $SerialPortInfo
  exit
} else {
  set SerialPortName [open "ArduinoConnected" RDWR]
  set SerialPortData [read -nonewline $SerialPortName]
  set SerialPortFile "/dev/$SerialPortData"
  #tk_messageBox -message "File Size = $FileSize" -type ok
  #tk_messageBox -message "Found eHealth Platform" -type ok
  set serial [open $SerialPortFile RDWR]
  fconfigure $serial -blocking 0 -mode 1200,n,8,1 -buffering none
  close $SerialPortInfo
}

#$wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=9&status=0"
#set postresult [$wisekar perform]


fileevent $serial readable {
		global PulseBPM PulseSPO2 ThermoTemp GSRCon GSRRes GSRConVol Systolic Diastolic AirFlowValues
		global params a t x v vv h h1 h2 h3
		global presentPointx presentPointy pastPointx pastPointy
		global sensor
		global IDorDATA
		global ReportLocked
		global NodeType
		
		set RecvdData [read -nonewline $serial]
		switch -- $IDorDATA {
		0 {
			switch -- $RecvdData {
				# | is for sensor IDs
				"|" {
					set IDorDATA 1
				}
				# ` is for sensor data
				"`" {
					set IDorDATA 2
					#tk_messageBox -message "Incoming Data" -type ok
				}
			}
		}
		1 {	
			switch -- $RecvdData {
				0 {
					#PulseOximeter
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "PulseOximeter Connected" -type ok
					grid .lPulse -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .lPulseSPO2 -in .fMainMenu -row 16 -column 2 -columnspan 1
					grid .lPulseBPM -in .fMainMenu -row 17 -column 2 -columnspan 1
					grid .ePulseSPO2 -in .fMainMenu -row 16 -column 3 -columnspan 1
					grid .ePulseBPM -in .fMainMenu -row 17 -column 3 -columnspan 1
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 0
					set NodeType "12"
					set sensorData ""
				} 1 {
					#ECG
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "ECG Connected" -type ok
					grid .lECG -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 1
					set NodeType "15"
					set sensorData ""
				} 2 {
					#Airflow
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "Airflow Meter Connected" -type ok
					grid .lAir -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .c -in .fMainMenu -row 16 -column 2
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 2
					set NodeType "14"
					set sensorData ""
				} 3 {
					#Thermometer
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "Thermometer Connected" -type ok
					grid .lThermo -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .lThermoTemp -in .fMainMenu -row 16 -column 2 -columnspan 1
					grid .eThermoTemp -in .fMainMenu -row 16 -column 3 -columnspan 1
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 3
					set NodeType "20"
					set sensorData ""
				} 4 {
					#Blood Pressure
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "Blood Pressure Monitor Connected" -type ok
					grid .lBP -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .lBPSys -in .fMainMenu -row 16 -column 2 -columnspan 1
					grid .lBPDia -in .fMainMenu -row 17 -column 2 -columnspan 1
					grid .eBPSys -in .fMainMenu -row 16 -column 3 -columnspan 1
					grid .eBPDia -in .fMainMenu -row 17 -column 3 -columnspan 1
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 4
					set NodeType "10"
					set sensorData ""
				} 5 {
					#GSR
					grid remove .lPulse
					grid remove .lECG
					grid remove .lAir
					grid remove .lThermo
					grid remove .lBP
					grid remove .lGSR
					grid remove .lPulseSPO2
					grid remove .ePulseSPO2
					grid remove .lPulseBPM
					grid remove .ePulseBPM
					grid remove .lThermoTemp
					grid remove .eThermoTemp
					grid remove .lGSRCon
					grid remove .eGSRCon
					grid remove .lGSRRes
					grid remove .eGSRRes
					grid remove .lGSRConVol
					grid remove .eGSRConVol
					grid remove .lBPSys
					grid remove .eBPSys
					grid remove .lBPDia
					grid remove .eBPDia
					grid remove .lSensor
					grid remove .eSensor
					grid remove .bLock
					grid remove .bUnlock
					grid remove .c
					#tk_messageBox -message "GSR Connected" -type ok
					grid .lGSR -in .fMainMenu -row 15 -column 2 -columnspan 3
					grid .lGSRCon -in .fMainMenu -row 16 -column 2 -columnspan 1
					grid .lGSRRes -in .fMainMenu -row 17 -column 2 -columnspan 1
					grid .lGSRConVol -in .fMainMenu -row 18 -column 2 -columnspan 1
					grid .eGSRCon -in .fMainMenu -row 16 -column 3 -columnspan 1
					grid .eGSRRes -in .fMainMenu -row 17 -column 3 -columnspan 1
					grid .eGSRConVol -in .fMainMenu -row 18 -column 3 -columnspan 1
					grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
					set IDorDATA 0
					set sensor 5
					set NodeType "13"
					set sensorData ""
				}
			}
		}
		2 {
			switch -- $sensor {
				0 {
					#PulseOximeter
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							set PulseBPM [lindex [split $sensorData ":"] 0]
							set PulseSPO2 [lindex [split $sensorData ":"] 1]
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				} 1 {
					#ECG
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							tk_messageBox -message "Data $sensorData" -type ok
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				} 2 {
					#Airflow
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							.c create line $t 239 [expr $t + 5] 239 -fill gray
							set pastPointx $presentPointx
							set pastPointy $presentPointy
							set presentPointx $t
							set presentPointy [expr 239 - $sensorData]
							.c create line $pastPointx $pastPointy $presentPointx $presentPointy -fill blue
							set t [expr $t + 5]
							if {$t > $params(width)} { .c xview scroll 5 unit }
							set AirFlowValues "$AirFlowValues,$sensorData"
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				} 3 {
					#Thermometer
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							set ThermoTemp $sensorData
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				} 4 {
					#Blood Pressure
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							set Systolic [lindex [split $sensorData ":"] 0]
							set Diastolic [lindex [split $sensorData ":"] 1]
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				} 5 {
					#GSR
					if {$ReportLocked == 0} {
						if {$RecvdData=="~"} {
							set IDorDATA 0
							set GSRRes $sensorData
							set GSRCon $sensorData
							set GSRConVol $sensorData
							set sensorData ""
						} else {
							set sensorData "$sensorData$RecvdData"
						}
					}
				}
			}
		}
	}
}		

proc execute_button {} {
	global serial 
	global answer
	if { $answer=="Read Flash"} {
		set in [open "hexfile.hex" r]
		set contents [read $in]
		close $in
		set Lines [split $contents "\n"]
		.txt delete 1.0 end
		.txt insert end "The contents of the hexfile are: \n\n" 
		for {set Index1 0} {$Index1 <=[llength $Lines]} {incr Index1} {
			.txt insert end "\n[lindex $Lines $Index1]" 
			set word $[lindex $Lines $Index1]		
			set string "$word"
			set size [string length $word]
			# From zero to size-1
			for {set Index2 2} {$Index2 <= $size-1} {incr Index2} {  
				set first [string index $string [expr $Index2]]
				set second [string index $string [expr $Index2 + 1]]
				set Index2 [expr $Index2 + 1]
				set sendData ""
				append sendData $first
				append sendData $second
				#.txt insert end "\n$sendData" 
				puts -nonewline $serial $sendData ; flush $serial
			}	
		}
		tk_messageBox -message "Showing old data. Could not connect." -type ok
	} else {
		global serial
		#Receiving Function
		fileevent $serial readable {
			set RecvdData [read $serial] ;
			tk_messageBox -message "Received $RecvdData" -type ok
			}
		}
}

proc readdevsig {} {
		global serial
		set sendData 0
		puts -nonewline $serial $sendData ; flush $serial
		fileevent $serial readable {
			.txt delete 1.0 end
			.txt insert end "The Device Signature is: \n\n"
			.txt insert end "1E 95 07"
			#set RecvdData [read $serial] ;
			#tk_messageBox -message "Received $RecvdData" -type ok
		}
}



proc quit_button {} {
	set ans [tk_messageBox -message "Are you sure you want to quit?" -type yesno -icon question]
	switch -- $ans {
    		yes exit
		no {
		}
	}
}

proc reset_arduino {} {
	global PulseBPM PulseSPO2 ThermoTemp GSRCon GSRRes GSRConVol Systolic Diastolic AirFlowValues
	global IDorDATA
	global serial
	global NodeType
	global sensor
	set NodeType 0
	set sensor 10
	set IDorDATA 1
	set PulseSPO2 0
	set PulseBPM 0
	set ThermoTemp 0
	set GSRCon 0
	set GSRRes 0
	set GSRConVol 0
	set Systolic 0
	set Diastolic 0
	set AirFlowValues 0
	set ReportLocked 0
	#setting IDorDATA to 1 makes the application listen to the sensor identification PWM code, before considering it's data for the report
	puts -nonewline $serial "1"
	grid remove .lPulse
	grid remove .lECG
	grid remove .lAir
	grid remove .lThermo
	grid remove .lBP
	grid remove .lGSR
	grid remove .lPulseSPO2
	grid remove .ePulseSPO2
	grid remove .lPulseBPM
	grid remove .ePulseBPM
	grid remove .lThermoTemp
	grid remove .eThermoTemp
	grid remove .lGSRCon
	grid remove .eGSRCon
	grid remove .lGSRRes
	grid remove .eGSRRes
	grid remove .lGSRConVol
	grid remove .eGSRConVol
	grid remove .lBPSys
	grid remove .eBPSys
	grid remove .lBPDia
	grid remove .eBPDia
	grid remove .lSensor
	grid remove .eSensor
	grid remove .bLock
	grid remove .bUnlock
	grid remove .c
	
}

proc LockReport {} {
	global ReportLocked
	set ReportLocked 1
	grid remove .bLock
	grid .bUnlock -in .fMainMenu -row 16 -column 4 -rowspan 2
}

proc UnlockReport {} {
	global ReportLocked
	set ReportLocked 0
	grid remove .bUnlock
	grid .bLock -in .fMainMenu -row 16 -column 4 -rowspan 2
}

proc ScpFiles {} {
	grid .buChekReportFind -in .fMainMenu -row 19 -column 2 -columnspan 1
	grid .bHide -in .fMainMenu -row 19 -column 4 -columnspan 1
	set user iuatciitdelhi
	set pass iuatciitdelhi
	set host 192.168.0.50
	spawn scp -P 9999 $user@$host:/sdcard/uChekTest/* /home/blitz/Workspace/RP02680/TclTk/Application/
	expect {
		"iuatciitdelhi@192.168.0.50's password: " {
		exp_send "$pass\r"
		exp_continue
		}
		eof {
		tk_messageBox -message "Reports Updated" -type ok
		}
	}
}

proc HideuChekButtons {} {
	grid remove .buChekReportFind
	grid remove .bHide
}

	      
proc SearchParse {} {
	global NodeType PatientID Glucose Bilirubin Ketone SG Blood pH Protein Urobilinogen Nitrite Leukocytes 
	if {$PatientID == ""} {
	  tk_messageBox -message "Enter Patient ID to search report database." -type ok
	} else {
	  set status [catch {exec ls | grep $PatientID > uChekReport} result]
	  if { $status == 0 } {
	    tk_messageBox -message "Found reports. Retrieving information for display / database" -type ok
	    grid .luGlucose -in .fMainMenu -row 14 -column 3 -columnspan 1
	    grid .luBilirubin -in .fMainMenu -row 5 -column 3 -columnspan 1
	    grid .luKetone -in .fMainMenu -row 6 -column 3 -columnspan 1
	    grid .luSG -in .fMainMenu -row 7 -column 3 -columnspan 1
	    grid .luBlood -in .fMainMenu -row 8 -column 3 -columnspan 1
	    grid .lupH -in .fMainMenu -row 9 -column 3 -columnspan 1
	    grid .luProtein -in .fMainMenu -row 10 -column 3 -columnspan 1
	    grid .luUrobilinogen -in .fMainMenu -row 11 -column 3 -columnspan 1
	    grid .luNitrite -in .fMainMenu -row 12 -column 3 -columnspan 1
	    grid .luLeukocytes -in .fMainMenu -row 13\ -column 3 -columnspan 1
	    set UrineReportFile [open "uChekReport" r]
	    set UrineReportFileName [read -nonewline $UrineReportFile]
	    #tk_messageBox -message "$UrineReportFileName" -type ok
	    exec pdftotext $UrineReportFileName
	    exec rm {*}[glob rm *.pdf]
	    set status [catch {exec ls | grep $PatientID > uChekReport} result]
	    if { $status == 0 } {
	      set UrineReportFile [open "uChekReport" r]
	      set UrineReportFileName [read -nonewline $UrineReportFile]
	      #tk_messageBox -message "$UrineReportFileName" -type ok
	      set UrineReport [open $UrineReportFileName r]
	      set UrineReportContent [read $UrineReport]
	      #tk_messageBox -message "$UrineReportContent" -type ok
	      set Readings [split $UrineReportContent "\n"]
	      grid .euGlucose -in .fMainMenu -row 14 -column 4 -columnspan 1
	      grid .euBilirubin -in .fMainMenu -row 5 -column 4 -columnspan 1
	      grid .euKetone -in .fMainMenu -row 6 -column 4 -columnspan 1
	      grid .euSG -in .fMainMenu -row 7 -column 4 -columnspan 1
	      grid .euBlood -in .fMainMenu -row 8 -column 4 -columnspan 1
	      grid .eupH -in .fMainMenu -row 9 -column 4 -columnspan 1
	      grid .euProtein -in .fMainMenu -row 10 -column 4 -columnspan 1
	      grid .euUrobilinogen -in .fMainMenu -row 11 -column 4 -columnspan 1
	      grid .euNitrite -in .fMainMenu -row 12 -column 4 -columnspan 1
	      grid .euLeukocytes -in .fMainMenu -row 13 -column 4 -columnspan 1
	      
	      set Glucose [lindex $Readings 16]
	      set Bilirubin [lindex $Readings 17]
	      set Ketone [lindex $Readings 18]
	      set SG [lindex $Readings 19]
	      set Blood [lindex $Readings 20]
	      set pH [lindex $Readings 21]
	      set Protein [lindex $Readings 22]
	      set Urobilinogen [lindex $Readings 23]
	      set Nitrite [lindex $Readings 24]
	      set Leukocytes [lindex $Readings 25]
	      
	      exec rm {*}[glob rm *.txt]
	      set NodeType 16
	      tk_messageBox -message "Click the Wisekar Button to save to database. You may edit any faulty readings before doing that." -type ok

	    } else {
	      tk_messageBox -message "Couldn't parse the report." -type ok
	    }
	  } else {
	    tk_messageBox -message "No matching reports found." -type ok
	  }
	}
	#exec ls ./uChekTest/ | grep  > uChekReport
}

proc PostEvent {} {
  global wisekar PatientID NodeType Glucose Bilirubin Ketone SG Blood pH Protein Urobilinogen Nitrite Leukocytes
  global PulseBPM PulseSPO2 Systolic Diastolic ThermoTemp GSRCon GSRRes GSRConVol AirFlowValues FirstName LastName
  #tk_messageBox -message "|$NodeType|" -type ok
  switch -- $NodeType {
    0 {
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=9&status=0"
      set postresult [$wisekar perform]
    } 10 {
      #Blood Pressure
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=10&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>Systolic=$Systolic,Diastolic=$Diastolic</bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>N/A</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 12 {
      #PulseOximeter
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=12&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement></bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>Oxygen_Saturation=$PulseSPO2,Heart_Rate=$PulseBPM</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>N/A</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 13 {
      #GSR
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=13&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>70,110</bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>Glucose=$Glucose,Bilirubin=$Bilirubin,Ketone=$Ketone,SpecificGravity=$SG,Blood=$Blood,ph=$pH,Protein=$Protein,Urobilinogen=$Urobilinogen,Nitrite=$Nitrite,Leukocytes=$Leukocytes,PatientID=$PatientID</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 14 {
      #Airflow
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=14&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>N/A</bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>$AirFlowValues</airFlow><ecg>N/A</ecg><urineAnalysis>N/A</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 15 {
      #ECG
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=15&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>70,110</bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>Glucose=$Glucose,Bilirubin=$Bilirubin,Ketone=$Ketone,SpecificGravity=$SG,Blood=$Blood,ph=$pH,Protein=$Protein,Urobilinogen=$Urobilinogen,Nitrite=$Nitrite,Leukocytes=$Leukocytes,PatientID=$PatientID</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 16 { 
      #uChek
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=16&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>70,110</bloodPressureMeasurement><bodyTemperature>N/A</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>Glucose=$Glucose,Bilirubin=$Bilirubin,Ketone=$Ketone,SpecificGravity=$SG,Blood=$Blood,ph=$pH,Protein=$Protein,Urobilinogen=$Urobilinogen,Nitrite=$Nitrite,Leukocytes=$Leukocytes,PatientID=$PatientID</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    } 20 {
      #Thermometer
      $wisekar configure -url "http://wisekar.iitd.ernet.in/api/home/resource.php/resource/event" -postfields "key=rdJjxSuQwd3XNfL900jOyB37c044&datasetId=29&nodeId=8064&typeId=11&status=1,1&xmlFragment=<additionalInfo><sensor><patientFirstName>$FirstName</patientFirstName><patientLastName>$LastName</patientLastName><bloodPressureMeasurement>N/A</bloodPressureMeasurement><bodyTemperature>Body_Temperature=$ThermoTemp</bodyTemperature><pulseOximeter>N/A</pulseOximeter><galvanicSkinResponse>N/A</galvanicSkinResponse><airFlow>N/A</airFlow><ecg>N/A</ecg><urineAnalysis>N/A</urineAnalysis></sensor></additionalInfo>"
      set postresult [$wisekar perform]
    }
  }
}
    
    


#frame_name
frame .frm_name -relief groove
label .dev -text "Select Device:"
set opt "ATmega32"

# substituting the options using the list declared above
tk_optionMenu .omn opt "ATmega32" "ATmega16" "ATmega8" "AT tiny 2313" 

radiobutton .rdb_a -text "Read Flash" -variable answer -value "Read Flash"
radiobutton .rdb_b -text "Write Flash" -variable answer -value "Write Flash"

#Global Variables
set Parts 0
set ConName 0
set LuckySlab "10000"
set QuestionIndex "1"
set Answer "1"
set PrizeMoney "0"
set NextPrizeMoney "5000"
set NodeType 0
set SensorConnected 10


#Text Area
frame .textarea
text .txt -yscrollcommand ".srl_y set" -xscrollcommand ".srl_x set" \
	-width 50 -height 50
scrollbar .srl_y -command ".txt yview" -orient v
scrollbar .srl_x -command ".txt xview" -orient h


#Frame for Executable Buttons
frame .frm_options



#GUI building
frame .fMainMenu -relief groove
image create photo .iLogo -file "Icon.gif"
image create photo .iThumbsUp -format GIF -file "ThumbsUp.gif"
image create photo .iQuit -format GIF -file "Quit.gif"
image create photo .iWisekar -format GIF -file "Wisekar.gif"
image create photo .iProceed -format GIF -file "GreenArrow.gif"
image create photo .iTick -format GIF -file "GreenTick.gif"
image create photo .iCross -format GIF -file "RedCross.gif"
image create photo .iLock -format GIF -file "Locked.gif"
image create photo .iuChek -format GIF -file "uChek.gif"
image create photo .iIIT -format GIF -file "IITLogo.gif"
image create photo .iFind -format GIF -file "Find.gif"
image create photo .iPulse -format GIF -file "Pulseoximeter.gif"
image create photo .iECG -format GIF -file "ECG.gif"
image create photo .iAir -format GIF -file "Airflow.gif"
image create photo .iThermo -format GIF -file "Temperature.gif"
image create photo .iBP -format GIF -file "BP.gif"
image create photo .iGSR -format GIF -file "GSR.gif"
image create photo .iReset -format GIF -file "Reset.gif"
image create photo .iReport -format GIF -file "Report.gif"
image create photo .iUnlock -format GIF -file "Lock.gif"
image create photo .iLock -format GIF -file "Unlock.gif"


#Generic Labels
label .title -text "eHealth Platform Interface" -font "arial 14 bold"
label .lLogo
label .lTick
label .lCross
label .lLock
label .lIIT

#uChek Labels and Entryboxes
label .lPatientID -text "Patient ID"
label .luGlucose -text "Glucose"
label .luBilirubin -text "Bilirubin"
label .luKetone -text "Ketone"
label .luSG -text "Specific Gravity"
label .luBlood -text "Blood"
label .lupH -text "ph"
label .luProtein -text "Protein"
label .luUrobilinogen -text "Urobilinogen"
label .luNitrite -text "Nitrite"
label .luLeukocytes -text "Leukocytes"
entry .ePatientID -textvariable PatientID
entry .euGlucose -textvariable Glucose
entry .euBilirubin -textvariable Bilirubin
entry .euKetone -textvariable Ketone
entry .euSG -textvariable SG
entry .euBlood -textvariable Blood
entry .eupH -textvariable pH
entry .euProtein -textvariable Protein
entry .euUrobilinogen -textvariable Urobilinogen
entry .euNitrite -textvariable Nitrite
entry .euLeukocytes -textvariable Leukocytes


#eHealth Sensor Labels and Entryboxes
label .lBP
.lBP configure -image .iBP
label .lAir
.lAir configure -image .iAir
label .lECG
.lECG configure -image .iECG
label .lGSR
.lGSR configure -image .iGSR
label .lThermo
.lThermo configure -image .iThermo
label .lPulse
.lPulse configure -image .iPulse
#eHealth Sensor Data Labels and Entryboxes
label .lPulseSPO2 -text "SPO2 %"
entry .ePulseSPO2 -textvariable PulseSPO2
label .lPulseBPM -text "Beats Per Minute"
entry .ePulseBPM -textvariable PulseBPM
label .lThermoTemp -text "Temperature"
entry .eThermoTemp -textvariable ThermoTemp
label .lGSRCon -text "Conductance"
entry .eGSRCon -textvariable GSRCon
label .lGSRRes -text "Resistance"
entry .eGSRRes -textvariable GSRRes
label .lGSRConVol -text "Conductance Voltage"
entry .eGSRConVol -textvariable GSRConVol
label .lBPSys -text "Systolic Pressure"
entry .eBPSys -textvariable Systolic
label .lBPDia -text "Diastolic Pressure"
entry .eBPDia -textvariable Diastolic
label .lSensor -text "Sensor"
entry .eSensor -textvariable Sensor
set Sensor "None"

label .lPatientFirstName -text "First Name"
entry .ePatientFirstName -textvariable FirstName
label .lPatientLastName -text "Last Name"
entry .ePatientLastName -textvariable LastName

radiobutton .rbAnswer1 -text "" -variable Answer -value "1"
radiobutton .rbAnswer2 -text "" -variable Answer -value "2"
radiobutton .rbAnswer3 -text "" -variable Answer -value "3"
radiobutton .rbAnswer4 -text "" -variable Answer -value "4"

#Buttons
button .bWisekar -image .iWisekar -command "PostEvent" -compound top
button .bQuit -image .iQuit -height 60 -width 80 -command "quit_button" -compound top
button .bFinalize -image .iThumbsUp -text "Finalize!" -command "push_Finalize" -compound top
button .bProceed -image .iProceed -text "Proceed!" -command "push_Proceed" -compound top
button .buChek -image .iuChek -command "ScpFiles" -compound top
button .buChekReportFind -image .iFind -command "SearchParse" -compound top
button .bReset -image .iReset -command "reset_arduino" -compound top
button .bReport -image .iReport -command "Report" -compound top
button .bLock -image .iLock -command "LockReport" -compound top
button .bUnlock -image .iUnlock -command "UnlockReport" -compound top
button .bHide -text "Hide uChek Buttons" -command "HideuChekButtons" -compound top

canvas .c -width 400 -height 240 -xscrollincrement 1 -bg beige
#bind .c <Destroy> { exit }
bind .c <Configure> {
    bind .c <Configure> {}
    .c xview scroll 0 unit
    set t 0
}

.lLogo configure -image .iLogo
.lTick configure -image .iTick
.lCross configure -image .iCross
.lLock configure -image .iLock
.lIIT configure -image .iIIT


#Geometry Management
grid .title -in .fMainMenu -row 0 -column 0 -columnspan 5
grid .lLogo -in .fMainMenu -row 1 -column 0 -columnspan 1 -rowspan 4
grid .lIIT -in .fMainMenu -row 1 -column 3 -columnspan 1
grid .lPatientID -in .fMainMenu -row 2 -column 2 -columnspan 1
grid .ePatientID -in .fMainMenu -row 2 -column 3 -columnspan 2
grid .lPatientFirstName -in .fMainMenu -row 3 -column 2 -columnspan 1
grid .ePatientFirstName -in .fMainMenu -row 3 -column 3 -columnspan 2
grid .lPatientLastName -in .fMainMenu -row 4 -column 2 -columnspan 1
grid .ePatientLastName -in .fMainMenu -row 4 -column 3 -columnspan 2
grid .bReset -in .fMainMenu -row 20 -column 1 -columnspan 1
grid .bWisekar -in .fMainMenu -row 20 -column 2 -columnspan 1
grid .buChek -in .fMainMenu -row 20 -column 3 -columnspan 1
grid .bQuit -in .fMainMenu -row 20 -column 4 -columnspan 1
pack .fMainMenu



#Grid Management for the Main Window
#grid .title -row 1 -column 1 -columnspan 2
#grid .frm_name -row 2 -column 1 -columnspan 2
#grid .dev -in .frm_name -row 1 -column 1
#grid .omn -in .frm_name -row 1 -column 2
#grid .rdb_a -row 3 -column 1
#grid .rdb_b -row 4 -column 1
#grid .textarea -row 5 -column 1 -columnspan 2
#grid .txt   -in .textarea -row 1 -column 1
#grid .srl_y -in .textarea -row 1 -column 2 -sticky ns
#grid .srl_x -in .textarea -row 2 -column 1 -sticky ew
#grid .frm_options -row 6 -column 1 -columnspan 2
#grid .readdevsig -in .frm_options -row 1 -column 1
#grid .execute -in .frm_options -row 1 -column 2
#grid .quit -in .frm_options -row 1 -column 3

