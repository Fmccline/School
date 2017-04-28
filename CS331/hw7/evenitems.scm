#lang scheme
; evenitems.scm
; Frank Cline
; 27 April 2017
;
; CS 331 Assignment 7 Exercise C
; Find even indexed items in a list

; evenitems
; returns a list of all the even idexed items in the list items
(define (evenitems items)
  (cond
    [(null? items) null]
    [else (getevenitems (list (car items)) items 2)]
  )
)

; getevenitems
; recursively appends the next even indexed item to a list to be returned
(define (getevenitems evenlist items index)
  (cond
    [(>= index (length items)) evenlist]
    [else
     (getevenitems (append evenlist (list (list-ref items index))) items (+ 2 index))
    ]
  )
)

