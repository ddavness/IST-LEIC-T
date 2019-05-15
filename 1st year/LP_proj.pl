/*
    File: main.pl (Prolog) - FINAL VERSION
    Author: David Duque, student number 93698.
    Description: LP project (2018/19), binary puzzle solver.

    Date began: 15/04/2019; Sent: 04/05/2019, 18:30
*/

:- consult(codigo_comum).

% ============================================ %
% --> --> --> AUXILIARY PREDICATES <-- <-- <-- %
% ============================================ %

% var_count/2: retrieves the number of variables in a list.
var_count(LIST, NUM) :-
    include(var, LIST, TRIMMED),
    length(TRIMMED, NUM).

% var_count/3: retrieves the number of occurrences of a given value in a list.
var_count(LIST, LOOK_FOR, NUM) :-
    include(==(LOOK_FOR), LIST, TRIMMED),
    length(TRIMMED, NUM).

% negate_value/2: gets a constant (0 or 1), and flips it (1 or 0).
negate_value(1, 0).
negate_value(0, 1).

% var_unify/2: unifies two terms if and only if they are both variables.
var_unify(G1, G2) :-
    var(G1), var(G2), G1 = G2, !.

var_unify([], []) :- !.
var_unify([H | T], [H1 | T1]) :-
    var_unify(H, H1), var_unify(T, T1),!.

var_unify(_, _).

% copy/2: copies the value of the source to the target. Variables do not unify.
copy(SRC, TARGET) :-
    nonvar(SRC), TARGET = SRC, !; true.

% copy_list/2: creates a list that is a copy of the original one, except with different variables.
copy_list(SRC, TARGET) :-
    findall(X, member(X, SRC), TARGET).

% fill/2: replaces all variables of a list with the given value.
fill([], _).
fill([X | TAIL], VAL) :-
    var(X), X = VAL, fill(TAIL, VAL), !;
    fill(TAIL, VAL).

% ======================================= %
% --> --> --> MAIN PREDICATES <-- <-- <-- %
% ======================================= %

% aplica_R1_triplo/2: Applies R1 once to a set of three values - CAN'T HAVE THE SAME VALUE THREE TIMES IN A ROW.
aplica_R1_triplo([X1, X2, X3], _) :-
	X1 == X2, X2 == X3, !, fail. % If we have three same values in a row, then the predicate trivially fails
aplica_R1_triplo([X, Y, Z], R) :-
    var_count([X, Y, Z], 1), (
        X == Y, !, negate_value(X, NEWVAL), R = [X, Y, NEWVAL];
        X == Z, !, negate_value(X, NEWVAL), R = [X, NEWVAL, Z];
        Y == Z, !, negate_value(Y, NEWVAL), R = [NEWVAL, Y, Z]
    ).
aplica_R1_triplo([X,Y,Z], [X1, Y1, Z1]) :-
    copy(X, X1), copy(Y, Y1), copy(Z, Z1).

%%%AUX%%% aplica_R1_fila_aux/3: Applies R1 once to each triple in a row.
aplica_R1_fila_aux([A1, A2, A3], ROW, _) :-
    aplica_R1_triplo([A1, A2, A3], ROW), !.
aplica_R1_fila_aux([A1, A2, A3 | TAIL], ROW, _) :- 
    TRIPLE = [B1, B2, B3],
    aplica_R1_triplo([A1, A2, A3], TRIPLE),
    aplica_R1_fila_aux([A2, A3 | TAIL], [C2, C3, C4 | NTAIL], _),
    C2 = B2, C3 = B3,
    ROW = [B1, C2, C3, C4 | NTAIL].

% aplica_R1_fila_aux/2: Applies R1 to a row while unifying common variables.
aplica_R1_fila_aux(ROW, NROW) :-
    aplica_R1_fila_aux(ROW, NROW, _),
    var_unify(ROW, NROW).

% aplica_R1_fila/2: Keep applying R1 to a row (once or more) until it has no effect on it.
aplica_R1_fila(ROW, RET_ROW) :-
    var_count(ROW, 0), !,
    aplica_R1_fila_aux(ROW, RET_ROW). % Make sure we did not input something that violates R1
aplica_R1_fila(ROW, RET_ROW) :-
    aplica_R1_fila_aux(ROW, AUX_ROW), (
        ROW == AUX_ROW, !, RET_ROW = AUX_ROW, !;
        aplica_R1_fila(AUX_ROW, RET_ROW)
    ).

% aplica_R2_fila/2: Applies R2 to a whole row - MUST TO HAVE SAME NUMBER OF 0s AND 1s.
aplica_R2_fila(ROW, RET_ROW) :-
    var_count(ROW, 1, ONES),
    var_count(ROW, 0, ZEROES),
    length(ROW, SIZE),
    copy_list(ROW, RET_ROW),
    THRESHOLD is div(SIZE, 2), (
        ONES > THRESHOLD, !, fail; ZEROES > THRESHOLD, !, fail;
        ONES == THRESHOLD, !, fill(RET_ROW, 0), var_unify(ROW, RET_ROW);
        ZEROES == THRESHOLD, !,fill(RET_ROW, 1), var_unify(ROW, RET_ROW);
        var_unify(ROW, RET_ROW)
    ).

% aplica_R1_R2_fila/2: Applies R1 and then R2 to the row.
aplica_R1_R2_fila(ROW, RET_ROW) :-
    aplica_R1_fila(ROW, OUT_AUX),
    aplica_R2_fila(OUT_AUX, RET_ROW).

%%%AUX%%% aplica_R1_R2_puz_aux/2: Applies R1 and R2 sequentially to all rows of a puzzle.
aplica_R1_R2_puz_aux([], []) :- !.
aplica_R1_R2_puz_aux([LINE | REST], OUTPUT) :-
    aplica_R1_R2_fila(LINE, LINE_OUT), aplica_R1_R2_puz_aux(REST, REST_OUT),
    OUTPUT = [LINE_OUT | REST_OUT].

% aplica_R1_R2_puzzle/2: Applies R1 and R2 sequentially to all rows and columns of a puzzle.
aplica_R1_R2_puzzle(PUZZLE, OUTPUT) :-
    aplica_R1_R2_puz_aux(PUZZLE, ROW_OUT), mat_transposta(ROW_OUT, COLUMNS),
    aplica_R1_R2_puz_aux(COLUMNS, COLUMNS_OUT), mat_transposta(COLUMNS_OUT, OUTPUT).

% inicializa/2: Inits a puzzle by applying R1 and R2 until it remains unchanged.
inicializa(PUZZLE, OUTPUT) :-
    aplica_R1_R2_puzzle(PUZZLE, OUT_AUX), (
        not(PUZZLE == OUT_AUX), !, inicializa(OUT_AUX, OUTPUT);
        OUTPUT = OUT_AUX
    ).

%%%AUX%%% different_rows/2: Checks if a row is different from every each other row in a row set.
different_rows(_, []) :- !.
different_rows(ROW, [ROW1 | ROWSET]) :-
    not(ROW == ROW1),
    different_rows(ROW, ROWSET).

%%%AUX%%% verifica_R3_aux/1: Applies R3 to all rows in the puzzle - THERE CANNOT BE TWO EQUAL ROWS OR COLUMNS.
verifica_R3_aux([_]) :- !.
verifica_R3_aux([ROW1 | ROWSET]) :-
    different_rows(ROW1, ROWSET),
    verifica_R3_aux(ROWSET).

% verifica_R3/1: Applies R3 to all rows and columns of a puzzle.
verifica_R3(PUZZLE) :-
    verifica_R3_aux(PUZZLE),
    mat_transposta(PUZZLE, PUZZLE_AUX),
    verifica_R3_aux(PUZZLE_AUX).

%%%AUX%%% get_dif_positions_aux/4: Grabs two lists (original and transformed) and computes a list that describes the positions where they differ.
get_dif_positions_aux([], [], _, _) :- !.
get_dif_positions_aux([O | ORIGINAL], [T | TRANSFORMED], [C | CARRY], VAL) :-
    V #= VAL + 1, (
        var(O), nonvar(T), !, C = VAL,
        get_dif_positions_aux(ORIGINAL, TRANSFORMED, CARRY, V);
        get_dif_positions_aux(ORIGINAL, TRANSFORMED, CARRY, V)
    ).

%%%AUX%%% get_dif_positions/5: Computes a list that describes the positions where ORIGINAL and TRANSFORMED differ, in the (FR, FC) format.
get_dif_positions(ORIGINAL, TRANSFORMED, (FR, FC), OUT) :-
    get_dif_positions_aux(ORIGINAL, TRANSFORMED, OUT_AUX, 1),
    include(nonvar, OUT_AUX, OUT_TRIM),
    findall((FR, FC), (member(FR, OUT_TRIM), nonvar(FC); member(FC, OUT_TRIM), nonvar(FR)), OUT), !.

% propaga_posicoes/3: Applies R1 and R2 to the row and column of the given positions and propagates the changes recursively.
propaga_posicoes([], PUZZLE, PUZZLE) :- !.
propaga_posicoes([(R, C) | POSITIONS], PUZZLE, OUTPUT) :-
    % Apply to row
    nth1(R, PUZZLE, ROW), copy_list(ROW, ROW_AUX),
    aplica_R1_R2_fila(ROW_AUX, ROW_RULED),
    get_dif_positions(ROW, ROW_RULED, (R, _), ROW_MOD),
    ROW = ROW_RULED,
    mat_transposta(PUZZLE, PUZZLE_OTHER),

    % Apply to column
    nth1(C, PUZZLE_OTHER, COLUMN), copy_list(COLUMN, COLUMN_AUX),
    aplica_R1_R2_fila(COLUMN_AUX, COLUMN_RULED),
    get_dif_positions(COLUMN, COLUMN_RULED, (_, C), COLUMN_MOD),
    COLUMN = COLUMN_RULED,
    mat_transposta(PUZZLE_OTHER, PUZZLE_OUT),

    % Verify misc rules and propagate to all changed positions.
    verifica_R3(PUZZLE_OUT),
    union(ROW_MOD, COLUMN_MOD, MODIFIED),
    propaga_posicoes(MODIFIED, PUZZLE_OUT, OUTPUT_A),
    propaga_posicoes(POSITIONS, OUTPUT_A, OUTPUT), !;

    not(POSITIONS == []), propaga_posicoes(POSITIONS, PUZZLE, OUTPUT).

%%%AUX%%% first_var_aux/3: Determines the lowest index of a list whose value is a variable.
first_var_aux([], 0, _) :- !.
first_var_aux([FST | TAIL], POS, START) :-
    var(FST), POS = START, !;
    X #= START + 1, first_var_aux(TAIL, POS, X).

%%%AUX%%% first_var_mat/4: Determines the first coordinate of the puzzle that contains a variable.
first_var_mat([], (0, 0), _) :- !.
first_var_mat([ROW1 | MATRIX], (ROW, COLUMN), START) :-
    first_var_aux(ROW1, COLUMN_AUX, 1), (
        COLUMN_AUX =\= 0, ROW = START, COLUMN = COLUMN_AUX, !;
        COLUMN_AUX == 0, X #= START + 1, first_var_mat(MATRIX, (ROW, COLUMN), X)
    ).

% resolve/2: Solves the given puzzle if such a solution exists.
resolve(PUZZLE, PUZZLE) :-
    first_var_mat(PUZZLE, (0,0), 1),
    aplica_R1_R2_puzzle(PUZZLE, _),
    verifica_R3(PUZZLE), !.
resolve(PUZZLE, SOLVED) :-
    first_var_mat(PUZZLE, COORD, 1),
    mat_ref(PUZZLE, COORD, REF), (
        REF = 0, propaga_posicoes([COORD], PUZZLE, OUTPUT);
        REF = 1, propaga_posicoes([COORD], PUZZLE, OUTPUT)
    ),
    resolve(OUTPUT, SOLVED), !.