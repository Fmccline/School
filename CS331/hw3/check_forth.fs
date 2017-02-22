\ check_forth.fs
\ Glenn G. Chappell
\ 11 Feb 2017
\
\ For CS F331 / CSCE A331 Spring 2017
\ A Forth Program to Run
\ Used in Assignment 3, Exercise A


999 constant end-mark  \ End marker for pushed data


\ push-data
\ Push our data, end-mark first.
: push-data ( -- end-mark <lots of numbers> )
  end-mark
  72 10 dup 4 + -5 -34 dup
  16 64 16 2 dup 1 - -37
  -34 73 7 dup 9 + -80 73
  18 -26 -71
;


\ do-stuff
\ Given a number, do ... whatever operations we are supposed to do.
\ (Pretty mysterious, eh?)
: do-stuff { n -- }
  push-data
  begin
    dup end-mark <> while
    n swap - 1
    dup + dup + swap + dup emit to n
  repeat
  drop
;


\ Now do it
cr
." Secret message #3:" cr cr
10 do-stuff cr
cr

