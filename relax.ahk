#SingleInstance FORCE
#InstallKeybdHook
#InstallMouseHook
#Persistent
SetTitleMatchMode RegEx
Menu, Tray, Icon, %A_ScriptDir%\relax.ico

CHECK_INTERVAL   :=    2000  ; 2sec
CHECK_INTV_SLEEP :=    1000  ; 1sec

MICRO_BREAK_WORK :=  120000  ; 2min
MICRO_BREAK      :=    5000  ; 5sec

REST_BREAK_WORK  :=  600000  ; 10min
REST_BREAK       :=   45000  ; 45sec

FOCUS_TIME       := 3600000  ; 1h

WORK_REST  := 0
WORK_MICRO := 0
SLEEP_TIME := 0
FOCUSING   := false


SetTimer, Check, %CHECK_INTERVAL%
Return


Check:
  If (FOCUSING)
    Return
  n := A_TimeIdlePhysical
  If (n > REST_BREAK)
  {
    WORK_MICRO := 0
    WORK_REST := 0
    Return
  }
  If (n > MICRO_BREAK)
  {
    WORK_MICRO := 0
    Return
  }
  If (n > CHECK_INTERVAL)
  {
    Return
  }
  If (WORK_REST >= REST_BREAK_WORK)
  {
    Do_Rest(REST_BREAK, 500)
    WORK_MICRO := 0
    WORK_REST := 0
    Return
  }
  If (WORK_MICRO >= MICRO_BREAK_WORK)
  {
    Do_Rest(MICRO_BREAK, 200)
    WORK_MICRO := 0
    Return
  }
  WORK_MICRO += CHECK_INTERVAL
  WORK_REST += CHECK_INTERVAL
  Return


Sleeping:
  If (A_TimeIdlePhysical >= CHECK_INTV_SLEEP)
  {
    SLEEP_TIME -= CHECK_INTV_SLEEP
    If (SLEEP_TIME <= 0)
    {
      GoSub DoneSleep
      Return
    }
    GuiControl,, Timer, +1000
  }
  Return


DoneSleep:
  Gui, Destroy
  SetTimer, Sleeping, Off
  SetTimer, Check, %CHECK_INTERVAL%
  Return


StopFocus:
  FOCUSING := false
  Return


Do_Rest(t, width)
{
  global SLEEP_TIME := t
  global CHECK_INTV_SLEEP

  SetTimer, Check, Off
  SetTimer, Sleeping, 1000

  global Timer

  Gui, -Caption +AlwaysOnTop
  Gui, Font, s15, Brawler
  Gui, Color, Gray
  Gui, Margin,, 80
  Gui, Add, Progress, w%width% h20 Center cBlack vTimer Range1-%t%, 1
  Gui, Show

  Return
}


#IfWinExist ahk_class ^AutoHotkeyGUI$
  ~RCtrl Up:: GoSub DoneSleep

  ~^RCtrl::
    GoSub DoneSleep
    FOCUSING := true
    SetTimer, StopFocus, -%FOCUS_TIME%
    Return

#IfWinExist
