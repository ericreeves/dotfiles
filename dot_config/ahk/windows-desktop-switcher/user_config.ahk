; ====================
; === INSTRUCTIONS ===
; ====================
; 1. Any lines starting with ; are ignored
; 2. After changing this config file run script file "desktop_switcher.ahk"
; 3. Every line is in the format HOTKEY::ACTION

; === SYMBOLS ===
; !   <- Alt
; +   <- Shift
; ^   <- Ctrl
; #   <- Win
; For more, visit https://autohotkey.com/docs/Hotkeys.htm

; === EXAMPLES ===
; !n::switchDesktopToRight()             <- <Alt> + <N> will switch to the next desktop (to the right of the current one)
; #!space::switchDesktopToRight()        <- <Win> + <Alt> + <Space> will switch to next desktop
; CapsLock & n::switchDesktopToRight()   <- <CapsLock> + <N> will switch to the next desktop (& is necessary when using non-modifier key such as CapsLock)

; ===========================
; === END OF INSTRUCTIONS ===
; ===========================

!1::GoToDesktopNumber(0)
!2::GoToDesktopNumber(1)
!3::GoToDesktopNumber(2)
!4::GoToDesktopNumber(3)
!5::GoToDesktopNumber(4)
!6::GoToDesktopNumber(5)
!7::GoToDesktopNumber(6)
!8::GoToDesktopNumber(7)
!9::GoToDesktopNumber(8)
!0::GoToDesktopNumber(9)

!^1::MoveCurrentWindowToDesktop(0)
!^2::MoveCurrentWindowToDesktop(1)
!^3::MoveCurrentWindowToDesktop(2)
!^4::MoveCurrentWindowToDesktop(3)
!^5::MoveCurrentWindowToDesktop(4)
!^6::MoveCurrentWindowToDesktop(5)
!^7::MoveCurrentWindowToDesktop(6)
!^8::MoveCurrentWindowToDesktop(7)
!^9::MoveCurrentWindowToDesktop(8)
!^0::MoveCurrentWindowToDesktop(9)
