delete(X, [X|T], T).
delete(X, [H|T], [H|T2]) :-
   delete(X, T, T2).

member(H, [H|_]).
member(X, [_|T]) :-
   member(X, T).

append([], L, L).
append([H|T], X, [H|X1]) :-
   append(T, X, X1).

last([X], X) :- !.
last([_|T], X) :-
   last(T, X).

len([], 0).
len([_|T], L) :-
   len(T, L2),
   L is L2 + 1.

flatten2([], []) :- !.
flatten2([L|Ls], FlatL) :-
    !,
    flatten2(L, NewL),
    flatten2(Ls, NewLs),
    append(NewL, NewLs, FlatL).
flatten2(L, [L]).



resolution(Inputfile) :-
   !,
   open(Inputfile, read, Str), 
   read_file(Str, Lines),
   close(Str),
   %% writeln('Read from file:'),
   last(Lines, Last),
   ProcessQuery(Last, Last1),
   delete(Last, Lines, Lines0),
   append(Lines0, Last1, Lines2),
   %% writeln(Lines2),
   len(Lines2, InitialCount),
   InitialCount1 is InitialCount + 1,
   resolve(Lines2, _, InitialCount1, Last1).
   

ProcessQuery((N, C), [(N, [H1])|L]) :- 
   flatten2(C, C1),
   C1 = [H|T],
   finalize([H],H1),
   N1 is N + 1,
   ProcessQuery((N1, T), L).

ProcessQuery((_,[]), []).


resolve([H|T], L2, NextRuleIndex, QueryIndices) :-
   CheckIfResolutionNeeded(QueryIndices, [H|T], FlagRes),

   (
      FlagRes = false
      ->
         writeln('resolution(success)'),
         true

      ;


      member(A, [H|T]),
      member(B, [H|T]),
      not(A = B),
      len([H|T], Total),

      resolution1(A, B, [H|T], X, Flag, Total, NextRuleIndex),
      %Resolution of A and B done, now remove duplicates [a,a] -> [a]
      

      (
      (X = [], Flag)
         ->
         writeln('resolution(success)'),
         true;
         Flag
         ->
         NextRuleIndex1 is NextRuleIndex + 1,
         resolve(X, L2, NextRuleIndex1, QueryIndices);
         writeln('resolution(fail)'),
         true
      )


   ).



resolution1((N1,X), (N2,Y), Original, Z, Flag, Total, Current) :-
   member(A, X),
   member(B, Y),
   
   %search for a, not a format
   A = not(B),
   %Remove A and B from X and Y as they resolve
   delete(A, X, X1),
   delete(B, Y, Y1),
   len(X1, LenX1),
   (
      LenX1 =\= 0
      ->
      append(X1, Y1, Z1),
      removeduplicates(Z1, Z2),
      write('resolution('),
      write(N2), write(', '),write(N1),write(', '),write(Z2),write(', '),write(Current),
      write(')'),nl,
      delete((N1, X), Original, Original1),
      delete((N2, Y), Original1, Original2),
      append([(Current, Z2)], Original2, Z),
      Flag = true
      ;
      LenX1 =:= 0
      ->
      Flag = true,
      append(X1, Y1, Z1),
      removeduplicates(Z1, Z2),

      %if Z2 empty, then empty, else append Z2 to Original2
      (
         Z2 = []
         ->
            write('resolution('),
            write(N1), write(', '),write(N2),write(', '),write('empty'),write(', '),write(Current),
            write(')'),nl,
            delete((N1, X), Original, Original1),
            delete((N2, Y), Original1, Original2),
            append([], Original2, Z)
         ;
            write('resolution('),
            write(N1), write(', '),write(N2),write(', '),write(Z2),write(', '),write(Current),
            write(')'),nl,
            delete((N1, X), Original, Original1),
            delete((N2, Y), Original1, Original2),
            append([(Current, Z2)], Original2, Z)
   
      )
      
   ).


resolution1((N1,X), (N2,Y), Original, Z, Flag, Total, Current) :-
   member(A, X),
   member(B, Y),
   %search for not a, a format
   B = not(A),
   delete(A, X, X1),
   delete(B, Y, Y1),
   len(X1, LenX1),
   (
      LenX1 =\= 0
      ->

      append(X1, Y1, Z1),
      removeduplicates(Z1, Z2),
      write('resolution('),
      write(N1), write(', '),write(N2),write(', '),write(Z2),write(', '),write(Current),
      write(')'),nl,
      delete((N1, X), Original, Original1),
      delete((N2, Y), Original1, Original2),
      append([(Current, Z2)], Original2, Z),
      Flag = true
      ;
      LenX1 =:= 0
      ->
      Flag = true,
      append(X1, Y1, Z1),
      removeduplicates(Z1, Z2),
      %if Z2 empty, then empty, else append Z2 to Original2
      (
         Z2 = []
         ->
            write('resolution('),
            write(N1), write(', '),write(N2),write(', '),write('empty'),write(', '),write(Current),
            write(')'),nl,
            delete((N1, X), Original, Original1),
            delete((N2, Y), Original1, Original2),
            append([], Original2, Z)
         ;
            writeln('X1=0, Z2 not empty (2)'),
            write('resolution('),
            write(N1), write(', '),write(N2),write(', '),write(Z2),write(', '),write(Current),
            write(')'),nl,
            delete((N1, X), Original, Original1),
            delete((N2, Y), Original1, Original2),
            append([(Current, Z2)], Original2, Z)
   
      )
   ).
   
resolution1(X, Y, Original, Z, Flag, Total, Current) :-
   last(Original, Last),
   X = Last,
   Flag = false,
   true.

resolution1(X, Y, Original, Original, Flag, Total, Current) :-
   Flag = true,
   fail.

CheckIfResolutionNeeded(QueryIndices, Clauses, FlagRes) :-
   QueryIndices = [H|T],
   member(H, Clauses),
   CheckIfResolutionNeeded(T, Clauses, FlagRes).


CheckIfResolutionNeeded(QueryIndices, Clauses, FlagRes) :-
   QueryIndices = [H|T],
   FlagRes = false.


CheckIfResolutionNeeded([], _, FlagRes) :- FlagRes = true.

%Reading from the file
read_file(Stream, []):- 
   at_end_of_stream(Stream). 
 
read_file(Stream, [Res|L]):- 
   \+  at_end_of_stream(Stream), 
   read(Stream, X),
   match(X, Res),
   read_file(Stream, L).


%Convert input txt to proper format
match(myClause(N, C), (N, Res)) :-
   parse(C, Res).

match(myQuery(N, C), (N, [Res])) :-
   parse2(C, Res).

%Convert or(X, Y) to [X, Y]
parse(or(X, Y), Z) :- !,
  parse(X, X1),
  parse(Y, Y1),
  append(X1, Y1, Z).

parse(neg(neg(X)), Res) :-
   !,
   parse(X, Res).

parse(neg(X), [not(X)]).
parse(X, [X]).

%Query parser
parse2(or(X, Y), [[X1],[Y1]]) :- !,
writeln('parse2'),
  parse2(X, X1),
  parse2(Y, Y1).

parse2(neg(neg(X)), Res) :-
   !,
   parse2(X, Res).

parse2(neg(X), not(X)).
parse2(X, X).

finalize([not X], X).
finalize([X], not(X)).

%After resolution of 2 clauses, remove duplicates
removeduplicates([], []).
removeduplicates([H], [H]).
removeduplicates([H,H|T], X) :-
   removeduplicates([H|T],X).
removeduplicates([H|T], [H|X]) :-
   removeduplicates(T, X).
