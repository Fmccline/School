% check_prolog.pro
% Glenn G. Chappell
% 30 Mar 2017
%
% For CS F331 / CSCE A331 Spring 2017
% A Prolog Program to Run
% Used in Assignment 6, Exercise A


% foo/2
% A mysterious predicate.
foo(_, []) :- fail.
foo(N, [D|DS]) :- A is D+N, char_code(C, A), write(C), foo(A, DS).


% main/0
% Another mysterious predicate.
main :-
    nl,
    write('Secret message #5:'), nl, nl,
    X1 = [87,17,-7,19,-84,68,11,-79],
    X2 = [89,-10,6,-85,67,-2,11,0],
    X3 = [-76,65,-65,70,-5,11,0,-7],
    X4 = [9,-78,84,-2,-13,0,-69,84],
    X5 = [-12,-7,19,-84,72,-7,18,-83],
    X6 = [76,3,4,1,-84,73,11,-1],
    X7 = [-83,65,12,-12,19,-15,16,-3],
    X8 = [-82,83,1,-19,19,1,-2,-52],
    append(X1, X2, Y1),
    append(X3, X4, Y2),
    append(X5, X6, Y3),
    append(X7, X8, Y4),
    append(Y1, Y2, Z1),
    append(Y3, Y4, Z2),
    append(Z1, Z2, DS),
    foo(0, DS), nl.

