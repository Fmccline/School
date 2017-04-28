% take.pro
% Frank Cline
% 27 Apr 2017
%
% CS 331 
% Assignment 7 exercise D

% N is zero and E is empty
take(0, _, []). 
% Both X and E are empty
take(_, [], []).

% First index of X and E are the same:
%	N = N-1, X = X w/out H, E = E w/out H. Then call take(N, X, E)
take(N, [H|X], [H|E]):- M is N-1, take(M, X, E). 
