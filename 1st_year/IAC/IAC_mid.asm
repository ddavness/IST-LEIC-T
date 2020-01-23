; ==================================================================================
; ?????  ?????  ?????     ???????    ?   ?  ?
;   ?    ?        ?      ??  ????    ?   ?  ?
;   ?    ?????    ?      ?  ??  ?    ?   ?  ?
;   ?        ?    ?      ?  ?????    ?   ?  ?
; ?????  ?????    ?      ?????????   ?????  ?????

; ?????  ?????  ?????  ?   ?  ?????  ?????  ?????  ?????  ?  ?
;   ?    ?   ?  ?      ?   ?  ?      ?   ?  ?   ?  ?   ?  ? ?
;   ?    ?????  ?  ??  ?   ?  ?????  ?????  ?????  ????   ???
;   ?    ?   ?  ?   ?  ?   ?      ?  ?      ?   ?  ?  ?   ?  ?
;   ?    ?   ?  ?????  ?????  ?????  ?      ?   ?  ?   ?  ?   ?


;  UC de Introducao a Arquitetura de Computadores (IAC) - Fase Intermedia do Projeto

; Ano Letivo 2018/2019
; ==================================================================================

IN_SC EQU 0A000H							; Endereco de input do score
IN_LI EQU 0C000H							; Endereco de input da linha
OU_CO EQU 0E000H							; Endereco de output da coluna

PX_SC EQU 08000H							; Endereco-base do ecra

; =================================================================================================================================================================
;                 ====================================================== Declaracao de Dados ======================================================                
; =================================================================================================================================================================
PLACE 1000H
scr_file:
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 00FH, 7BH, 0DEH, 0F0H
	STRING 009H, 4AH, 010H, 080H
	STRING 009H, 4BH, 09EH, 0F0H
	STRING 00EH, 72H, 002H, 010H
	STRING 008H, 4AH, 002H, 010H
	STRING 008H, 4BH, 0DEH, 0F0H
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 0FH, 0F0H, 000H
	STRING 000H, 0FH, 0E0H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0CH, 000H, 000H
	STRING 000H, 0FH, 0E0H, 000H
	STRING 000H, 0FH, 0F0H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 0F7H, 87H, 0A1H, 0E9H
	STRING 044H, 84H, 0A1H, 029H
	STRING 044H, 84H, 0A1H, 0EFH
	STRING 044H, 87H, 021H, 022H
	STRING 044H, 84H, 021H, 022H
	STRING 047H, 84H, 03DH, 022H
	STRING 000H, 00H, 000H, 000H
	STRING 000H, 00H, 000H, 000H
	STRING 0FFH								; 0FFH atua como EOF ("end of file")
	
PLACE 1100H
wheel:
	STRING 0, 0, 1, 1, 0, 0, 0, 0			; POS -1 (Esquerda)
	STRING 0, 1, 0, 0, 1, 0, 0, 0			; POS  0 (Estabilizado)
	STRING 1, 0, 0, 0, 0, 1, 0, 0			; POS +1 (Direita)

PLACE 1400H	
stack:
	TABLE 1000H								; reserva espaco para a pilha
SP_init:

PLACE 2500H
score:
	STRING 0								; Pontuacao
	
PLACE 2800H
maska:
	STRING 80H, 40H, 20H, 10H
	STRING 08H, 04H, 02H, 01H				; Mascaras de bit unico

; =================================================================================================================================================================
;                 ================================================== Corpo Principal do Programa ==================================================                
; =================================================================================================================================================================
	
PLACE 0000H
		
; Escrita do ecra inicial
mem_init:									; Iniializacao de dados em memoria
	MOV R0, IN_SC
	MOV R1, IN_LI
	MOV R2, OU_CO
	MOV R3, PX_SC
	
	MOV R4, score
	MOV R5, 0
	MOV [R4], R5
	
	MOV SP, SP_init							; Inicializacao do Stack Pointer
	MOV RL, scr_file
	SUB RL, 1
	MOV R10, PX_SC							; Preparar o registo para acessos
	SUB R10, 1
	MOV R6, 00CCH
	MOVB [R0], R6
	MOV R6, 00FFH							; Registo temporario da mascara 11111111b
render_init:
	ADD R10, 1								; Passa ao proximo byte a editar
	ADD RL, 1								; Proximo endereco a aceder
	MOVB R4, [RL]							; Obtem o conteudo em memoria
	CMP R4, R6								; se o valor obtido em memoria for FF (nao existem bytes completos neste ecra inicial, por isso FF atua como o "EOF"), termina o ciclo
	JZ wait_init
	MOVB [R10], R4							; Injeta o byte no ecra
	JMP render_init

; Neste momento, nehuma da informacao presente nos registos e importante para manter (a excecao dos registos R0 - R3)

wait_init:
	MOV R10, R3
	MOV RL, 8
	MOVB [R1], RL							; 8 = 1000b. Vai dizer ao teclado para procurar apenas na ultima linha
esperaC:
	MOVB R4, [R2]							; Extrai a tecla seleccionada
	CMP R4, 1								; 1 = 0001b. Na ultima linha corresponde a tecla C.
	JNZ esperaC								; Repete o processo se a tecla C nao tiver sido carregada.

	MOV R7, 4								; Define o argumento para a rotina render_chess
	CALL render_chess						; Cria um padrao xadrez no ecra. Ver "Subrotinas a executar"
	MOV R6, 0								; Reinicia o registo R6 utilizado
	CALL render_empty						; Limpa o ecra
	
; Criar o cockpit da nave

load_init:				
	MOV RL, 8080H							; Endereco do 1||| byte a escrever (mais a primeira subtracao, como temos tido feito sempre nestas situacoes)
	MOV R4, 80H								; Payload a injetar (tem em conta a primeira alteracao) = 1000 0000b
	MOV R5, 0								; Altura em pixeis, registo de controle (indice de um ciclo for)
	
load1:										; Primeira escada de linhas - ascendente
	SUB RL, 4								; Na primeira subtracao, RL = 7CH
	SHR R4, 1								; Desloca o pixel a injetar
	ADD R5, 1								; Aumenta a altura no ecra
	MOVB [RL], R4							; Injeta o byte no ecra
	CMP R5, 5								; Se a altura nao tiver chegado a altura definida (6 pixeis, so foi colocado 5 porque o 6||| e executado de maneira diferente)
	JNZ load1								; Repete o processo
	JMP load2
	
load2:										; Caso contrario, passamos a 2||| fase
											
	SUB RL, 4								; Na primeira subtracao, RL = 7CH
	MOV R4, 3H								; Define os pixeis a injetar
	MOV R5, 6								; Aumenta a altura no ecra para 6
	MOVB [RL], R4							; Injeta o payload
	
	MOV R4, 0FFH							; Muda o payload para um byte inteiro - estamos a fazer a borda de cima do cockpit
	ADD RL, 1								; Byte a direita
	MOVB [RL], R4
	ADD RL, 1
	MOVB [RL], R4
	ADD RL, 1
	
	MOV R4, 0C0H							; Muda o payload de novo, a preparar a fase 1 ao contrario!
	MOVB [RL], R4							; Injeta no ecra
	MOV R4, 40H								; Payload default

	
load3:										; Segunda escada de linhas - descendente
	ADD RL, 4								; Na primeira adicao, RL = 6FH, na ultima, 7FH
	SHR R4, 1								; Desloca o pixel a injetar
	SUB R5, 1								; Diminui a altura no ecra
	MOVB [RL], R4							; Injeta o byte no ecra
	CMP R5, 1								; Se a altura nao tiver chegado "ao chao" (altura = 1)
	JNZ load3								; Repete o processo
	
											; Criacao do volante. Apenas para efeitos de demonstracao vamos usar a rotina exe_pixel
	MOV R6, 1								; Indicacao que o pixel estara ativo										
	MOV R5, 29								; Coordenada Y
	MOV R4, 12								; Coordenada X
	MOV R7, 18								; Limite
	
load4:
	ADD R4, 1
	CALL exe_pixel
	CMP R4, R7								; O ultimo pixel do volante tem coordenadas (18, 29)
	JNZ load4

steer:										; Inicializacao dos comandos de steer (esquerda, direita)
; COMENTARIO SOBRE AS TECLAS A USAR: 
; 0 - VIRAR A ESQUERDA
; 3 - VIRAR A DIREITA
; D - INCREMENTO DE PONTUACAO

	MOV R10, 0
	MOV R5, 0
	MOV R9, 8
	
	MOV [R0], R10							; Inicializacao mesmo a zeros!
	MOV R0, IN_SC
detect:
	MOV R4, 1								; Primeira linha (0000 1001b)
	MOVB [R1], R4							; Input da linha
	
	MOVB RL, [R2]							; Obtem a coluna a ser carregada
	CMP RL, 1								; Foi a primeira coluna? (0001b, tecla 0)
	JZ det_1								; Se sim, processa como tal
	CMP RL, R9
	JZ det_8
	JMP det_def
	
	det_1:
		MOV RL, -1
		JMP det_up
	det_8:
		MOV RL, 1
		JMP det_up
	det_def: 
		MOV RL, 0
	det_up:
		CMP RL, R10
		JZ detect_score
		MOV R10, RL
		CALL update_handle					; Atualiza o volante
		
detect_score:								; Deteta tecla D para incrementar score em 3 pontos
	MOV R4, 8								; Ultima linha
	MOVB [R1], R4							; Input da linha
	
	MOVB RL, [R2]							; Obtem a coluna a ser carregada
	CMP RL, R5								; A tecla ja estava carregada?
	JZ detect								; Se sim volta ao inicio
	MOV R5, RL								; Senao guarda essa tecla
	CMP RL, 2								; Segunda coluna (Tecla D na ultima linha?)
	JNZ detect								; Senao volta ao inicio
	
	MOV R0, score							; Memoria nao-periferica da pontuacao
	MOV R7, [R0]							; Carrega a pontuacao anterior
	
	ADD R7, 3								; Aumenta a pontuacao em 3 pontos
	MOV R8, R7								; R8 = Dezenas; RL = Unidades
	SHR R8, 4	   							; Elimina o nibble das unidades (ficamos so com as dezenas)
	SHL R7, 12
	SHR R7, 12								; Elimina o nibble das dezenas (ficamos so com as unidades)
	
	MOV R6, 0AH
	CMP R7, R6								; Se o nibble das unidades for < 10
	JLT inject_score						; Injeta os nibbles
	SUB R7, R6								; Subtrai 10 ao nibble das unidades
	ADD R8, 1								; Adiciona 1 as dezenas
		
inject_score:
	SHL R8, 4								; Poe o nibble das dezenas em posicao
	OR R7, R8								; Junta os nibbles
	MOV R8, 99H								; Os valores decimais nao deixam de ser hexadecimais
	CMP R7, R8								; A pontuacao e maior que 99?
	JGT	fim									; Se sim, chegamos ao fim do "jogo"
	MOV [R0], R7							; Injeta a pontuacao nova na memoria
	MOV R0, IN_SC
	MOVB [R0], R7							; Atualiza os desplays
	JMP detect								; Repete o processo
		
fim:										; Epilogo: O jogo nesta fase intermedia e um ciclo. Neste caso, chegamos a este ponto quando a pontuacao chegar a 100 ou mais.
	MOV R7, 0FFH							; Podemos usar as letras para indicar estados de jogo - F = Game Over
	MOVB [R0], R7
	CALL render_chess						; Padrao xadrez
	JMP mem_init							; E voltamos ao inicio do programa

; ==========================================================================================================================================================
;     ==================================================================================================================================================
;                      ===================================================== Subrotinas a executar =====================================================                
;     ==================================================================================================================================================
; ==========================================================================================================================================================

; =============================================================================================
; === render_chess: Desenha um padrao xadrez no ecra.                          ================
; === INPUTS: R7 - Inverter o padrao a cada x bytes.                                    =======
; === OUTPUTS: N/A                                                                      =======
; === REG. DESTR.: N/A                                                         ================
; =============================================================================================
render_chess:
	; Envia os registos que vamos usar para a pilha por precaucao
	PUSH R4						
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	
	MOV R4, 55H								; Este valor e a "unidade base" para o padrao
	MOV R5, 0								; Contador local. Volta a zero a cada quatro bytes.
	MOV R6, 0								; Contador global. Para o ciclo no ultimo byte do ecra.
	MOV R8, 81H								; Limite do contador global
	MOV RL, R3
	SUB RL, 1								; Prepara o indexador da memoria do ecra
	
	exe_render_chess:
		NOT R4								; Inverte o padrao
		line:
			ADD R5, 1						; Atualiza contadores
			ADD R6, 1
			ADD RL, 1
			
			CMP R6, R8						; Confirma se nao varremos ja o ecra todo
			JZ return_render_chess			; Caso sim, termina o ciclo e restaura os registos
			
			MOVB [RL], R4					; Caso nao, injetamos o padrao no ecra
			MOD R5, R7						; Se estivermos no n-esimo byte, vai voltar a zero devido a mudanca de linha
			JZ exe_render_chess				; volta ao inicio e inverte o padrao se mudarmos de linha
			JMP line						; caso contrario, volta ao inicio sem mudar o padrao
		
	; Restaura o valor original dos registos e continua o programa
	return_render_chess:
		POP R8
		POP R7
		POP R6
		POP R5
		POP R4
		RET
		
; =============================================================================================
; === render_empty: Limpa o ecra                                               ================
; === INPUTS: N/A                                                                       =======
; === OUTPUTS: N/A                                                                      =======
; === REG. ALTER.: N/A                                                         ================
; =============================================================================================

render_empty:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R4
	PUSH R5
	PUSH R6
	
	MOV R4, 0								; Padrao a injetar
	MOV R5, R3								; Endereco do primeiro byte do ecra
	SUB R5, 1
	MOV R6, 807FH							; Limite global
	
	exe_render_empty:
		ADD R5, 1 							; Atualiza o endereco a editar (passa ao proximo byte)
		MOVB [R5], R4						; Injeta o byte no ecra
		CMP R5, R6							; Se o endereco for o ultimo:
		JZ return_render_empty				; Para o ciclo e retoma a execucao prinicpal
		JMP exe_render_empty				; Caso contrario volta ao inicio
		
	; Restaura o valor original dos registos e continua o programa	
	return_render_empty:
		POP R6
		POP R5
		POP R4
		RET
		
; =============================================================================================
; === exe_pixel: Escreve num pixel especifico                                  ================
; === INPUTS: R4 - Coord. X; R5 - Coord. Y; R6 - Valor                                  =======
; === OUTPUTS: N/A                                                                      =======
; === REG. ALTER.: N/A                                                         ================
; =============================================================================================

exe_pixel:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R4									; Coordenada X (0 - 1FH)
	PUSH R5									; Coordenada Y (0 - 1FH)
	PUSH R6									; Valor do pixel - Desligado se for 0, caso contrario ligado
	PUSH R7
	PUSH R8

	MOV R7, R4								; Uma copia da coordenada X
	MOV R8, 8								; Um byte tem oito bits
	DIV R4, R8                               ; Obtem o byte relativamente a linha (0 - 3)
	MOV R8, 8
	MOD R7, R8								; Obtem o bit em relacao ao inicio do byte (0 - 7)
	MOV R8, 4
	MUL R5, R8								; Obtem a linha (a partir da coordenada Y)
	ADD R5, R4								; Obtem o byte a aceder (0 - 7F)
	ADD R5, R3								; Obtem o endereco do byte a editar
	MOV R4, maska							; Obter endereco onde esta a mascara
	ADD R4, R7
	MOVB R4, [R4]							; Obter a mascara
		
	pix:
		MOVB R8, [R5]						; Obter o byte original
		CMP R6,0							; Se o valor-argumento for igual a zero, desligar
		JNZ on								; Caso contrario, ligar
	off:
		NOT R4								; Inverter a mascara (0010 0000b passa a 1101 1111b)
		AND R8, R4							; A operacao AND com a mascara invertida garante que apenas o bit especificado e desligado
		JMP return_exe_pixel				; Re-injetar o pixel e terminar
	on:
		OR R8, R4							; A operacao OR com a mascara garante que apenas o bit especificado e ligado 
	return_exe_pixel:
		MOVB [R5], R8						; Injeta o bit modificado
		; Restaura o valor original dos registos e continua o programa
		POP R8
		POP R7
		POP R6
		POP R5
		POP R4
		RET
		
; =============================================================================================
; === update_handle: Atualiza a posicao do volante                             ================
; === INPUTS: RL - Direcao (-1 = Esq.; 0 = Est.; 1 = Dir.)                              =======
; === OUTPUTS: N/A                                                                      =======
; === REG. ALTER.: N/A                                                         ================
; =============================================================================================

update_handle:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R4									; ====
	PUSH R5									; Argumentos utilizados pela rotina exe_pixel
	PUSH R6									; ====
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH RL
	; "Mover" pixeis
	
	MOV R7, wheel							; Inicializacao do endereco de memoria
	ADD RL, 1								; Adiciona 1 ao registo de direcao, para efeitos de acesso a memoria
	SHL RL, 3								; O equivalente a multiplicar RL por 8
	ADD R7, RL								; Obtem o endereco a partir do qual vamos comecar a aceder. (1000H para D = -1; 1008H para D = 0; 1010H para D = 1)
	MOV R4, 13
	MOV R5, 28								; Varrimento dos pontos (13, 28), (13, 29), (13, 30), (18, 28), (18, 29), (18, 30), com valores de acordo com a memoria
	MOV R8, 31								; Limite (exclusive o 31)
	MOV R9, 18								; Limite X (inclusive o 18)
	
	vertical_exe:
		CMP R5, R8
		JZ update_X
		MOVB R6, [R7]
		CALL exe_pixel
		ADD R7, 1
		ADD R5, 1
		JMP vertical_exe
	
	update_X:
		CMP R4, R9
		JZ return_update_handle
		MOV R4, R9
		MOV R5, 28
		JMP vertical_exe
	
	return_update_handle:
	; Restaura o valor original dos registos e continua o programa
		POP RL
		POP R9
		POP R8
		POP R7
		POP R6
		POP R5
		POP R4
		RET
