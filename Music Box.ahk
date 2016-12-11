#NoTrayIcon
SetKeyDelay, 0
GoSub, LoadSettings
FileCreateDir, Bell
FileCreateDir, Flute
FileCreateDir, Horn
FileCreateDir, Harp
FileCreateDir, Lute
FileCreateDir, Bell2
FileCreateDir, Bass
Gui,Add,Picture,x0 y-10 w420 h100 gOnLogoButton,Images\Music Box.png
Gui,Add,Picture,x0 y90 w60 h60 gOnBellButton,Images\Bell.png
Gui,Add,Picture,x60 y90 w60 h60 gOnFluteButton,Images\Flute.png
Gui,Add,Picture,x120 y90 w60 h60 gOnHornButton,Images\Horn.png
Gui,Add,Picture,x180 y90 w60 h60 gOnHarpButton,Images\Harp.png
Gui,Add,Picture,x240 y90 w60 h60 gOnLuteButton,Images\Lute.png
Gui,Add,Picture,x300 y90 w60 h60 gOnBell2Button,Images\Bell2.png
Gui,Add,Picture,x360 y90 w60 h60 gOnBassButton,Images\Bass.png
Gui,Add,Progress,x180 y150 w60 h10 vSelectedInstrumentBar c530500,100
Gui,Add,ListView,x0 y160 w360 h320 gOnSelectSong AltSubmit,Select an instrument.
Gui,Add,Picture,x360 y160 w60 h60 gOnNewButton,Images\Page.png
Gui,Add,Text,x360 y220 w60 h20 Center,New
Gui,Add,Picture,x360 y240 w60 h60 gOnImportButton,Images\Stow.png
Gui,Add,Text,x360 y300 w60 h20 Center,Import
Gui,Add,Picture,x360 y320 w60 h60 gOnEditButton,Images\Tool_Kit.png
Gui,Add,Text,x360 y380 w60 h20,Edit
Gui,Add,Picture,x360 y400 w60 h60 gOnDeleteButton,Images\Salvage Kit.png
Gui,Add,Text,x360 y460 w60 h20 Center,Delete
Gui,Add,Text,x0 y480 w420 h20 vSelectedFile Center,Select a song.
Gui,Add,Picture,x0 y500 w60 h60 gOnPlayButton vPlayButton,Images\Fa.png
Gui,Add,Progress,x60 y500 w300 h60 vProgressBar Border c530500 BackgroundFFFFFF,0
Gui,Add,Picture,x360 y500 w60 h60 gOnRewindButton,Images\Return.png
Gui,Add,Text,x2 y562 w25 h20 vChatLabel Left,Chat
Gui,Add,Edit,x25 y560 w355 h20 vChatField
Gui,Add,Button,x380 y560 w40 h20 +default gSubmitChat vChatButton,Send
Gui,Color,FFFFFF
Gui,Show,w420 h580,Guild Wars 2 Music Box
GuiControl, Hide, SelectedInstrumentBar
Gui,NewSong:Add,Text,x0 y3 w50 h20 Center,Title
Gui,NewSong:Add,Edit,x50 y0 w350 h20 vNewSongTitle,
Gui,NewSong:Add,Text,x0 y30 w400 h20 Center,Paste the song's AutoHotkey code below!
Gui,NewSong:Add,Edit,x0 y50 w400 h300 vNewSongCode,
Gui,NewSong:Add,Button,x0 y350 w200 h30 gOnNewSongOkButton,Add song
Gui,NewSong:Add,Button,x200 y350 w200 h30 gOnNewSongCancelButton,Cancel
Gui,NewSong:Color,FFFFFF
Gui,EditSong:Add,Text,x0 y3 w50 h20 Center,Title
Gui,EditSong:Add,Edit,x50 y0 w350 h20 vEditSongTitle,
Gui,EditSong:Add,Text,x0 y30 w400 h20 Center,Song code
Gui,EditSong:Add,Edit,x0 y50 w400 h300 vEditSongCode,
Gui,EditSong:Add,Button,x0 y350 w200 h30 gOnEditSongOkButton,Ok
Gui,EditSong:Add,Button,x200 y350 w200 h30 gOnEditSongCancelButton,Cancel
Gui,EditSong:Color,FFFFFF
return

LoadSettings:
	IniRead, ProcessName, settings.ini, General, ProcessName
	if ProcessName = ERROR
	{
		IniWrite, Gw2-64.exe, settings.ini, General, ProcessName
		ProcessName = Gw2-64.exe
	}
	IniRead, EnableWebsiteShortcut, settings.ini, General, EnableWebsiteShortcut
	if EnableWebsiteShortcut = ERROR
	{
		IniWrite, 1, settings.ini, General, EnableWebsiteShortcut
		EnableWebsiteShortcut = 1
	}
	IniRead, PlayBind, settings.ini, Keybinds, Play
	if PlayBind = ERROR
	{
		IniWrite, NumpadMult, settings.ini, Keybinds, Play
		PlayBind = NumpadMult
	}
	IniRead, RewindBind, settings.ini, Keybinds, Rewind
	if RewindBind = ERROR
	{
		IniWrite, NumpadDiv, settings.ini, Keybinds, Rewind
		RewindBind = NumpadDiv
	}
	Gosub, InitHotkeys
return

InitHotkeys:
	if PlayBind
	{
		Hotkey, %PlayBind%, OnPlayButton
	}
	if RewindBind
	{
		Hotkey, %RewindBind%, OnRewindButton
	}
return

SubmitChat:
	Gui, Submit, NoHide
	if ChatField
	{
		GuiControl, , ChatField
		SetKeyDelay, 10, 10
		ControlSend,, {Enter}, ahk_exe %ProcessName%
		ControlSendRaw,, %ChatField%, ahk_exe %ProcessName%
		ControlSend,, {Enter}, ahk_exe %ProcessName%
		ChatField := ""
		SetKeyDelay, -1, -1
	}
return

OnSelectSong:
	if A_GuiEvent = DoubleClick
	{
		GoSub, OnEditButton
	}
	if A_GuiEvent = Normal
	{
		LV_GetText(NewSelection, A_EventInfo)
		if NewSelection != %Selection%
		{
			Selection := NewSelection
			GuiControl,, SelectedFile, %Selection%
			SleepCount = 0
			Loop, Read, %SelectedInstrument%\%Selection%.ahk
			{
				CurrentLine := A_LoopReadLine
				IfInString, CurrentLine, Sleep
				{
					StringReplace, CurrentLine, CurrentLine, Sleep`, ,
					Sleepcount += CurrentLine
				}
			}
			GuiControl, +Range0-%SleepCount%, ProgressBar,
			GuiControl,, ProgressBar, 0
			CurrentLineNumber = 1
			GoSub, PauseSong
		}
	}
return

TogglePlay:
	SetTimer, TogglePlay, Delete
	if Playing = 0
	{
		GoSub, PlaySong
	}
	else
	{
		GoSub, PauseSong
	}
return

PlaySong:
	Playing = 1
	GuiControl,, PlayButton, Images\Re.png
	While Playing = 1
	{
		FileReadLine, CurrentLine, %SelectedInstrument%\%Selection%.ahk, CurrentLineNumber
		IfInString, CurrentLine, SendInput
		{
			StringReplace, CurrentLine, CurrentLine, SendInput {,
			StringReplace, CurrentLine, CurrentLine, },
			ControlSend,, {%CurrentLine%}, ahk_exe %ProcessName%
		}
		IfInString, CurrentLine, Sleep
		{
			StringReplace, CurrentLine, CurrentLine, Sleep`, ,
			GuiControl,, ProgressBar, +%CurrentLine%
			Sleep, %CurrentLine%
		}
		CurrentLineNumber += 1
	}
return

PauseSong:
	Playing = 0
	GuiControl,, PlayButton, Images\Fa.png
	GoSub, UnstuckKeys
return

OnPlayButton:
	SetTimer, TogglePlay
return

OnRewindButton:
	CurrentLineNumber = 1
	GuiControl,, ProgressBar, 0
	GoSub, UnstuckKeys
return

UnstuckKeys:
	ControlSend,, {Numpad1 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad2 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad3 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad4 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad5 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad6 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad7 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad8 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad9 up}, ahk_exe %ProcessName%
	ControlSend,, {Numpad0 up}, ahk_exe %ProcessName%
return

OnBellButton:
	SelectedInstrument := "Bell"
	GuiControl, Move, SelectedInstrumentBar, x0
	GoSub, ReloadSongs
return

OnFluteButton:
	SelectedInstrument := "Flute"
	GuiControl, Move, SelectedInstrumentBar, x60
	GoSub, ReloadSongs
return

OnHornButton:
	SelectedInstrument := "Horn"
	GuiControl, Move, SelectedInstrumentBar, x120
	GoSub, ReloadSongs
return

OnHarpButton:
	SelectedInstrument := "Harp"
	GuiControl, Move, SelectedInstrumentBar, x180
	GoSub, ReloadSongs
return

OnLuteButton:
	SelectedInstrument := "Lute"
	GuiControl, Move, SelectedInstrumentBar, x240
	GoSub, ReloadSongs
return

OnBell2Button:
	SelectedInstrument := "Bell2"
	GuiControl, Move, SelectedInstrumentBar, x300
	GoSub, ReloadSongs
return

OnBassButton:
	SelectedInstrument := "Bass"
	GuiControl, Move, SelectedInstrumentBar, x360
	GoSub, ReloadSongs
return

ReloadSongs:
	GuiControl, Show, SelectedInstrumentBar
	Gui, 1:Default
	LV_Delete()
	LV_ModifyCol("1", "", SelectedInstrument . " songs")
	Loop, %SelectedInstrument%\*.ahk
	{
		StringReplace SongListFileNameNoExt, A_LoopFileName, .ahk,
		LV_Add("", SongListFileNameNoExt)
	}
return

OnNewButton:
	Gui,NewSong:Show,w400 h380,New Song
return

OnNewSongOkButton:
	MsgBox, 4, Confirm, Are you happy with your song?,
	IfMsgBox Yes
	{
		Gui, NewSong:Submit
		FileAppend, %NewSongCode%, %SelectedInstrument%\%NewSongTitle%.ahk
		GuiControl, NewSong:, NewSongTitle,
		GuiControl, NewSong:, NewSongCode,
		Gui, NewSong:Hide
		GoSub, ReloadSongs
	}
return

OnNewSongCancelButton:
	MsgBox, 4, Are you sure?, Are you sure you wish to discard your new song?,
	IfMsgBox Yes
	{
		GuiControl, NewSong:, NewSongTitle,
		GuiControl, NewSong:, NewSongCode,
		Gui, NewSong:Hide
	}
return

OnEditButton:
	GuiControl,EditSong:, EditSongTitle, %Selection%
	FileRead, SongCode, %SelectedInstrument%\%Selection%.ahk
	GuiControl,EditSong:, EditSongCode, %SongCode%
	Gui,EditSong:Show,w400 h380,Edit song
return

OnEditSongOkButton:
	MsgBox, 4, Confirm edit, Are you happy with your changes?,
	IfMsgBox Yes
	{
		Gui, EditSong:Submit
		FileRecycle, %SelectedInstrument%\%Selection%.ahk
		FileAppend, %EditSongCode%, %SelectedInstrument%\%EditSongTitle%.ahk
		GuiControl, EditSong:, EditSongTitle,
		GuiControl, EditSong:, EditSongCode,
		Gui, EditSong:Hide
		GoSub, ReloadSongs
	}
return

OnEditSongCancelButton:
	MsgBox, 4, Are you sure?, Are you sure you wish to discard your changes?,
	IfMsgBox Yes
	{
		GuiControl, EditSong:, EditSongTitle,
		GuiControl, EditSong:, EditSongCode,
		Gui, EditSong:Hide
	}
return

OnImportButton:
	FileSelectFile, Selection,,,, AutoHotkey script (*.ahk)
	FileCopy, %Selection%, %SelectedInstrument%
	Selection := ""
	GoSub, ReloadSongs
return

OnDeleteButton:
	MsgBox, 4, Confirm action, Are you sure you wish to delete the following song: %Selection%?,
	IfMsgBox Yes
	{
		FileRecycle, %SelectedInstrument%\%Selection%.ahk
		GoSub, ReloadSongs
	}
return

OnLogoButton:
	if EnableWebsiteShortcut = 1
	{
		Run, http://www.gw2mb.com
	}
return

GuiClose:
	GoSub, UnstuckKeys
	ExitApp