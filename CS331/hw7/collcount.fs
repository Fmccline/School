\ collcount.fs
\ Frank Cline
\ 26 April 2017
\
\ CS 331 Homework 7 Exercise B
\ Counts the iterations for collatz to take a number to 1


\ collcount_go
\ Determines if n is even or odd
\   if n is even, n = n / 2
\   if n is odd,  n = 3n + 1
\ Increases c by 1 and adds a flag for if x==1
\ Note: for the stack comments, x = n/2 or 3n+1
: collcount_go ( c n -- c+1 x x==1)
  dup                                   \ Stack c n n
  1 2                                   \ Stack: c n n 1 2
  */MOD drop                            \ Stack: c n (remainder of n/2)
  0 = if 2 / else 3 * 1 + then          \ Stack: c x
  swap 1 + swap                         \ Stack: c+1 x
  dup 1 =                               \ Stack: c+1 x (x==1)
;

\ collcount
\ Counts the iterations of collatz needed for n to become 1
: collcount ( n -- c )
  0 swap                                \ Stack: 0 n
  dup                                   \ Stack: 0 n n
  1 <> if                               \ Stack: 0 n
    begin
      collcount_go                      \ Stack: c n
    until                               \ Stack: c 1
  then drop                             \ Stack: c       
;