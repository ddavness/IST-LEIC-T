; ===========================================================================================================
; ============================================================================================================
; =============================================================================================================
; ?????  ?????  ?????     ???????    ?   ?  ?                                                       ============
;   ?    ?        ?      ??  ????    ?   ?  ?                                                        ============
;   ?    ?????    ?      ?  ??  ?    ?   ?  ?                                                         ============
;   ?        ?    ?      ?  ?????    ?   ?  ?                                                          ===========
; ?????  ?????    ?      ?????????   ?????  ?????                                                       ==========
;                                                                                                        =========
; ?????  ?????  ?????  ?   ?  ?????  ?????  ?????  ?????  ?  ?                                           =========
;   ?    ?   ?  ?      ?   ?  ?      ?   ?  ?   ?  ?   ?  ? ?                                            =========
;   ?    ?????  ?  ??  ?   ?  ?????  ?????  ?????  ????   ???                                            =========
;   ?    ?   ?  ?   ?  ?   ?      ?  ?      ?   ?  ?  ?   ?  ?                                           =========
;   ?    ?   ?  ?????  ?????  ?????  ?      ?   ?  ?   ?  ?   ?                                          =========
;                                                                                                        =========
;                                                                                                        =========
;  UC de Introducao a Arquitetura de Computadores (IAC) - Fase Final do Projeto                          =========
;  David Ferreira de Sousa Duque     || 93698                                                            =========
;  Eduardo Filipe Custodio de Jesus  || 93707                                                            =========
;  Joao Francisco Pereira Costa      || 94237                                                            =========
;                                                                                                       ==========
;                                                                                                      ===========
;                                                                                                     ============
; Ano Letivo 2018/2019                                                                               ============
;                                                                                                   ============
; =============================================================================================================
; ============================================================================================================
; ===========================================================================================================

; Nota: Ao contrário daquilo que foi feito na versão intermédia, foi feito um esforço para gerir os registos de uma maneira mais eficiente (menos registos "ocupados" ao mesmo tempo)

; POWERED BY PEPE(TM)

INPUT_SCORE EQU 0A000H							; Endereco de input do score
INPUT_LINE EQU 0C000H							; Endereco de input da linha
OUTPUT_COL EQU 0E000H							; Endereco de output da coluna

PIX_SCREEN EQU 08000H							; Endereco-base do ecra

; Definições

ASTEROIDE_DELAY EQU 7							; Tempo mínimo entre dois asteroides aparecerem no mapa (conta-se de 0.3 em 0.3 segundos) ; Máximo 4 asteroides
INTRO_DELAY EQU 3								; Compasso de espera artificial

SPEED_THRESHOLD_0 EQU 04H
SPEED_THRESHOLD_1 EQU 0CH
SPEED_THRESHOLD_2 EQU 16H

SIZE_THRESHOLD_2 EQU 5
SIZE_THRESHOLD_3 EQU 9
SIZE_THRESHOLD_4 EQU 13
SIZE_THRESHOLD_5 EQU 17
SIZE_THRESHOLD_6 EQU 23

; =================================================================================================================================================================
;                 ====================================================== Declaracao de Dados ======================================================                
; =================================================================================================================================================================

PLACE 1000H									; Variáveis Diversas
scr_file:									; Dados que compoem o ecra inicial (PRESS C TO PLAY)
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
	STRING 0FFH, 00H						; 0FFH atua como EOF ("end of file")
	
score:	WORD 0								; Pontuação (tentar extrair a pontuação do input dos displays só nos dá um número ao calhas)
game:	WORD 0								; Estado do Jogo (0 = Por Começar; -1 - Em Pausa; 1 - A correr

missil:
		WORD -1								; Posição do míssil, definida por interrupcao (XXYY). Por defeito igual a -1 = 0FFFFH, fora dos limites do ecra
missil_render:
		WORD -1								; Posição do míssil, confirmada via processo (XXYY)
missil_range:
		WORD 0								; Distância percorrida pelo míssil

mascaras:
	STRING 80H, 40H, 20H, 10H				; Biblioteca de mascaras de bit unico (ex. 00010000b), para serem usadas na rotina exe_pixel
	STRING 08H, 04H, 02H, 01H				; Isto consome algum espaço em memoria mas alivia poder de processamento (com SHR's e SHL's), que no PEPE, é (muito) escasso
atnd_itrpc:									; Atendimento de interrupções (para a BTE)
	WORD int_prim
	WORD int_sec
wheel:										; Os dois bits de menor peso não servem para nada, exceto para "enganar" o PEPE e não ativar a flag ZERO
	STRING 00110011b						; -1 >>> Viragem à esquerda
	STRING 01001011b						;  0 >>> Volante estabilizado
	STRING 10000111b						; +1 >>> Viragem à direita
	
PLACE 1100H
asteroide:
	; Asteroide 1
	WORD -1									; Define coordenadas (semelhante ao que já vimos em relação ao missil) - (XXYY)
	WORD 0									; Definem várias informações acerca do asteróide (ao nível do nibble): Tipo (0 é mau, 1 é bom, 2 refere-se que o asteroide foi abatido)
	;--------								; Velocidade Lateral (0 = -1, 1 = 0, 2 = +1), Tamanho (em píxeis, de 0 a F): 0LTS, L = Direcao Lateral, T = Tipo, S = Tamanho
	WORD -1
	WORD 0									; Valores iguais para o mesmo asteroide mas só para serem usados pelo processo principal (mostra com que dados o asteroide foi desenhado)
PLACE 1200H
asteroide2:
	WORD -1
	WORD 0
	WORD -1
	WORD 0
PLACE 1300H
asteroide3:
	WORD -1
	WORD 0
	WORD -1
	WORD 0
PLACE 1400H
asteroide4:
	WORD -1
	WORD 0
	WORD -1
	WORD 0
	; À semelhança do que temos no míssil, se o valor das coordenadas for -1 (= 0FFFFH) então o asteroide não existe
PLACE 1500H
ast_clock:
	WORD ASTEROIDE_DELAY					; Variável de controlo

PLACE 2000H
stack:
	TABLE 1000H								; reserva espaco para a pilha
SP_init: WORD 0
	
; =================================================================================================================================================================
;                 ================================================== Corpo Principal do Programa ==================================================                
; =================================================================================================================================================================
	
PLACE 0000H									; Execução Primária

;; INICIALIZAÇÃO ANTES DE TUDO!!! ;;
mem_init:
	MOV R0, score							; Obtém o endereço onde a pontuação é guardada
	MOV R1, 0								; Prepara o valor 
	MOV [R0], R1							; Garante que a pontuação e limpa
	
	MOV SP, SP_init							; Inicializa o stack pointer
	MOV BTE, atnd_itrpc						; Liga as interrupções às rotinas desenhadas para as atender
	MOV R0, asteroide
	EI0										; Ativar interrupção primaria
	EI1										; Ativar interrupção secundaria
	EI										; Disjuntor principal de interrupções
	

;; ECRÃ INICIAL ;;
reset:										; Re-inicializacao dos registos
	MOV R0, scr_file						
	SUB R0, 1								; Indexador de memória imediatamente antes do início dos dados do ecra inicial
	MOV R1, PIX_SCREEN
	SUB R1, 1								; Um segundo indexador imediatamente antes do início do endereco do periferico PixelScreen
	MOV R3, 00FFH							; Registo temporario da mascara 11111111b (Saltamos o R2 de proposito, fica para o conteudo do ecra)
render_init:
	ADD R0, 1								; Passa ao proximo byte a editar
	ADD R1, 1								; Proximo endereco a aceder
	MOVB R2, [R0]							; Obtem o conteudo em memoria
	CMP R2, R3								; se o valor obtido em memoria for FF (nao existem bytes completos neste ecra inicial, por isso FF atua como o "EOF"), termina o ciclo
	JZ teclado_prep
	MOVB [R1], R2							; Injeta o byte no ecra, e volta ao princípio
	JMP render_init

; Neste momento, nehuma da informacao presente nos registos e importante para manter

teclado_prep:								; Prepara o teclado
	MOV R0, INPUT_LINE						
	MOV R1, 8
	MOVB [R0], R1							; 8 = 1000b. Vai dizer ao teclado para procurar apenas na ultima linha
	MOV R2, OUTPUT_COL						; Obtém o endereco de onde extrair a coluna
	MOV R10, 0FFFH							; Ativa a flag para o "blink" dos displays - alterna entre a pontuacao obtida e o código "CC"
esperaC:
	MOVB R3, [R2]							; Extrai a tecla seleccionada
	CMP R3, 1								; 1 = 0001b. Na ultima linha corresponde a tecla C.
	JNZ esperaC								; Repete o processo se a tecla C nao tiver sido carregada. Caso contrário continua

	CALL render_chess						; Cria um padrao xadrez no ecra. Ver "Subrotinas a executar"
	
	MOV RL, INTRO_DELAY						; Atua como flag para a interrupção primaria (3 = duas interrupções)
compasso_espera:							; Para nao ser tudo demasiado rápido, vamos esperar por tres interrupções secundarias (entre 0.4 e 0.6 segundos).
	CMP RL, 0								; Não passamos daqui enquanto a flag não tiver sido reposta a zero (cada interrupcao decrementa a flag em 1)
	JNZ compasso_espera
	CALL render_empty						; Limpa o ecra, e passamos à proxima parte
	
;; COCKPIT DA NAVE ;;
load_init:				
	MOV R0, 8080H							; Endereco do 1o byte a escrever (mais a primeira subtracao, como temos tido feito nestas situacoes)
	MOV R1, 80H								; Payload a injetar (tem em conta a primeira alteracao) = 1000 0000b
	MOV R2, 0								; Altura em pixeis, registo de controle (indice de um ciclo for)
	
load1:										; Primeira escada de linhas - ascendente
	SUB R0, 4								; Na primeira subtracao, R0 = 807CH
	SHR R1, 1								; Desloca o pixel a injetar
	ADD R2, 1								; Aumenta a altura no ecra
	MOVB [R0], R1							; Injeta o byte no ecra
	CMP R2, 5								; Se a altura nao tiver chegado a altura definida (6 pixeis, so foi colocado 5 porque o 6o e executado de maneira diferente)
	JNZ load1								; Repete o processo
	
load2:										; Caso contrario, passamos a 2a fase
											
	SUB R0, 4								; Aumenta a altura de novo (onde o byte vai ser colocado), desta vez com um proposito ligeiramente diferente
	MOV R1, 3H								; Define os pixeis a injetar (0000 0011b)
	MOV R2, 6								; Aumenta a altura no ecra para 6, vamos usar isto já a seguir
	MOVB [R0], R1							; Injeta o payload
	
	MOV R1, 0FFH							; Muda o payload para um byte inteiro - estamos a fazer a borda de cima do cockpit
	ADD R0, 1								; Byte a direita
	MOVB [R0], R1
	; Como não temos que repetir isto muitas vezes, fizemos a operacao sequencialmente
	ADD R0, 1								; Byte a direita
	MOVB [R0], R1							; Injeta novamente um byte inteiro
	ADD R0, 1								; Byte a direita
	
	MOV R1, 0C0H							; Muda o payload de novo, a preparar a fase 1 ao contrario! (1100 0000b)
	MOVB [R0], R1							; Injeta no ecra
	MOV R1, 40H								; Payload default de novo (desta vez para os bits vao ser deslocados à direita)

load3:										; Segunda escada de linhas - descendente
	ADD R0, 4								; Na primeira adicao, RL = 6FH, na ultima, 7FH
	SHR R1, 1								; Desloca o pixel a injetar
	SUB R2, 1								; Diminui a altura no ecra
	MOVB [R0], R1							; Injeta o byte no ecra
	CMP R2, 1								; Se a altura nao tiver chegado "ao chao" (altura = 1)
	JNZ load3								; Repete o processo
	
	; Criacao do volante. Apenas para efeitos de demonstracao vamos usar a rotina exe_pixel
	MOV R0, 1								; Indicacao que o pixel estara ativo
	MOV R1, 12								; Coordenada X	
	MOV R2, 29								; Coordenada Y
	MOV R3, 18								; Limite
	
load4:
	ADD R1, 1
	CALL exe_pixel
	CMP R1, R3								; O ultimo pixel do volante tem coordenadas (18, 29)
	JNZ load4

;; INICIO DE JOGO ;;	
	
game_begin:									; Inicializacao dos comandos de steer (esquerda, direita)
; COMENTARIO SOBRE AS TECLAS A USAR: 
; 0 - VIRAR A ESQUERDA
; 1 - DISPARAR MÍSSIL
; 2 - EMP?
; 3 - VIRAR A DIREITA
; C - Comecar o jogo
; D - Pausa
; F - Reinicia o jogo

	MOV R10, 0								; Desativa a flag R10 do score_blink. R10 passa a ser o registo temporário da tecla carregada
	
	MOV R2, 0								; Última Tecla Selecionada na primeira linha 
	MOV R3, 0								; Última tecla selecionada na ultima linha
	MOV R4, 1								; Registo de linha 1
	MOV R5, 8								; Registo da linha 4 (e comparacao)
	
	MOV R0, score
	MOV [R0], R10							; Inicializacao mesmo a zeros! Aproveitamos o facto de o registo R10 já estar a zeros
	MOV R0, INPUT_SCORE
	MOV [R0], R10							; Score a zero nos displays
	MOV R0, game
	MOV [R0], R4							; O jogo passa ao estado 1 (a correr)
	MOV R0, INPUT_LINE						; Input da Linha
	MOV R1, OUTPUT_COL						; Output da Coluna
	
	; RL passa a ser o registo de direção da nave (-1 = Esquerda; 0 = Estabilizado; 1 = Direita)

;; DETEÇÃO DE TECLAS! ;;
	
detect_l1:
	EI0										; Algumas operações acabam por desligar os disjuntores das interrupções, por isso é mais seguro ativares
	EI1
	EI
	
	MOVB [R0], R4							; Input da linha (1a linha = 0000 0001b)
	
	MOVB R10, [R1]							; Obtem a coluna a ser carregada
	CMP R10, R2								; A tecla era igual à ultima registada?
	JZ detect_l4							; Se sim, então ou ainda não largámos essa tecla ou não estamos a usar uma tecla sequer. Passa à proxima linha!
	MOV R2, R10								; Caso contrário, a última tecla passa a ser esta, e continuamos!
	
	CMP R10, 1								; Foi a primeira coluna? (0001b, tecla 0)
	JZ det_1								; Se sim, processa viragem à esquerda
	CMP R10, 2								; Foi a segunda coluna? (0010b, tecla 1)
	JZ det_2								; Se sim, processa possibilidade de mandar um míssil
	CMP R10, R5								; Foi a quarta coluna? (1000b, tecla 3)
	JZ det_8								; Se sim, processa viragem à direita
	JMP det_def								; Se não, processa como default (volante estabilizado)
	
	det_1:									; Tecla 0/Viragem esquerda
		MOV RL, -1							; Reg. Dir = -1
		JMP det_up							; Atualizar
	det_2:									; Tecla 1/Disparar míssil
		MOV R6, missil						; Obter o endereço do míssil
		MOV R7, [R6]						; Obter coordenadas do míssil
		CMP R7, -1							; Se a coordenada é default, então criamos um míssil, senão este já existe e ignoramos
		JNZ det_up							; Senão atualizamos o volante e continuamos
		
		PUSH R0								; Evitemos destruír os registos preciosos mas vamos precisar deles por enquanto
		PUSH R1
		PUSH R2
		MOV R0, 1F29H						; Define coordenadas do novo míssil. A notação XXYY tem um offset de 10H píxeis das coordenadas reais para permitir alguma folga no tratamento de coordenadas negativas.
		CALL xxyy_decode					; Separa o R0 nas coordenadas X(R1) e Y(R2)
		PUSH R0
		CALL exe_pixel						; R0 é diferente de zero, por isso o píxel vai ser ativado
		POP R0
		MOV [R6], R0						; Injeta na memória, ficando acessível às interrupções
		MOV R6, missil_render
		MOV [R6], R0						; Declara que o míssil ja foi desenhado para a coordenada pretendida
		POP R2
		POP R1
		POP R0								; Já usámos estes registos, vamos restaurá-los agora
		JMP det_up
	det_8:									; Tecla 3/Viragem direita
		MOV RL, 1							; Reg. Dir = +1
		JMP det_up							; Atualizar
	det_def: 								; Volante Estabilizado
		MOV RL, 0							; Reg. Dir =  0
	det_up:
		CALL update_handle					; Atualiza o volante
		
detect_l4:									; Deteta tecla D para incrementar score em 3 pontos
	MOVB [R0], R5							; Input na última linha (8 = 0000 1000b)
	MOVB R10, [R1]							; Obtem a coluna a ser carregada
	CMP R10, R3								; A tecla ja estava carregada?
	JZ missil_move							; Se sim volta ao inicio
	MOV R3, R10								; Senao guarda essa tecla
	CMP R10, 2								; Segunda coluna (Tecla D na ultima linha?)
	JZ pause_game							; Se sim põe o jogo em pausa
	CMP R10, R5								; Quarta coluna (Tecla F na ultima linha?)
	JZ fim

;; MOVIMENTO DO MÍSSIL ;;
	
missil_move:
	PUSH R0									; Ao contrário daquilo que se pensa, isto não é uma rotina.
	PUSH R1
	PUSH R2
	MOV R0, missil							; Endereço das coordenadas do míssil
	MOV R1, [R0]							; Obter coordenadas do míssil
	MOV R0, missil_render					; Obter coordenadas do míssil desenhado
	MOV R2, [R0]
	CMP R1, R2								; Se as coordenadas são iguais, não vamos desperdiçar tempo, voltamos ao início
	JZ missil_clear							; Limpar a pilha e voltar ao início
	PUSH R1									; Caso contrário, guardamos novas cópias das coordenadas dos mísseis
	PUSH R2
	MOV R0, R1								; Colocar a coordenada nova para ser separada
	CALL xxyy_decode						; Separa o conteúdo de R0 em coordenadas X(R1) e Y(R2) para a rotina exe_pixel
	MOV R0, 1								; Confirmar que a rotina está programada para acender o píxel
	CALL exe_pixel							; Acender o novo píxel
	POP R2
	POP R1									; Restaurar os valores antigos
	MOV R0, missil_render					; Buscar o endereço onde a localização efetiva do míssil é escrita
	MOV [R0], R1							; Declarar que o píxel já foi escrito
	MOV R0, R2								; Preparar a posição antiga para ser separada
	CALL xxyy_decode						; Separar a coordenada antiga em duas
	MOV R0, 0								; Confirmar que a coordenada antiga será desativada
	CALL exe_pixel							; Desligar o píxel antigo
missil_clear:
	POP R2									; Restaurar os valores antigos e continuar os processos
	POP R1
	POP R0
	
;; MOVIMENTO DOS ASTEROIDES ;;
asteroide_materializa:						; Materializa os asteroides!
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R8
	PUSH R9

	MOV R0, asteroide						; Obter o endereco-base dos asteroides
	MOV R1, 0								; Registo de offset
	MOV R3, 300H							; Limite do offset
	MOV R4, 100H
	asteroide_lookup:
	 
		MOV R2, [R0 + R1]					; Obtém o conteúdo (coordenada) do slot (R1 = 0, 100H, 200H, 300H ==> 1, 2, 3, 4 (a ==> (a/100H) + 1)
		JMP desenha_asteroide				; Tenta gerar o asteroide
		analisa_slot_main:
			CMP R1, R3						; Se já tivermos analisado o quarto slot
			JZ asteroide_clear				; Passamos a proxima fase
			ADD R1, R4						; Passa ao próximo slot
			JMP asteroide_lookup			; Recomeca o processo
		
		desenha_asteroide:
			PUSH R0
			PUSH R1
			; Apenas fazer isto se as coordenadas novas e as antigas forem diferentes!!!!
			ADD R0, R1						; Tornar o offset "permanente"
			PUSH R2
			PUSH R3
			
			MOV R2, [R0]					; Coordenadas novas
			MOV R3, [R0 + 4]				; Coordenadas desenhadas
			CMP R2, R3						; Se forem diferentes, atualiza
			JNZ erase_old
			MOV R2, [R0 + 2]				; Caracteristicas novas
			MOV R3, [R0 + 6]				; Caracteristicas desenhadas
			CMP R2, R3						; Se forem diferentes, atualiza
			JNZ erase_old
			; Caso contrario, o asteroide nao mudou, e podemos ignorá-lo
			POP R3
			POP R2
			POP R1
			POP R0							; Anula o empilhamento e "devolve" a carta ao remetente
			JMP analisa_slot_main
			; Apagar o conteudo antigo
			erase_old:
				POP R3						; Se mandaram para aqui, então ainda não "recuperaram" da pilha...
				POP R2
				MOV R8, R0					; O R0 vai ser preciso para outra coisa, e o R8 é argumento da rotina exe_asteroide
				ADD R8, 4					; Colocar o indexador no endereco processado pelo processo principal (referente ao desenho)
				MOV R9, 0					; Ordem de apagar
				MOV R1, [R8]				; Obter o conteudo
				CMP R1, -1					; Se o asteroide nao existir, ignora
				JZ draw_new
				CALL exe_asteroide			; Senão, continua com a ordem de "apagamento"!
				
			; Desenhar o asteroide novo
			draw_new:
				PUSH R0
				MOV R0, [R0]				; Extrai o valor de coordenadas novo
				CMP R0, -1					; Se o asteroide novo nao existir, ignora
				JZ clear
				MOV [R8], R0				; Senao coloca o valor novo no sítio do desenho
				MOV R0, [SP]				; Buscar o valor de R0 à pilha mantendo-a como está
				MOV R0, [R0 + 2]			; Buscar as características do asteroide novo à memoria
				MOV [R8 + 2], R0			; Colocar no endereco respetivo do desenho
				MOV R9, 1					; Ordem de desenhar
				CALL exe_asteroide			; Executar a ordem.
				
			clear:
				POP R0
				POP R1
				POP R0
				JMP analisa_slot_main
			
	asteroide_clear:
		POP R9
		POP R8
		POP R4
		POP R2
		POP R1
		POP R0
;; COLISAO ;;
	JMP detect_l1

;; CONDIÇÃO DE JOGO EM PAUSA! ;;	
	
pause_game:
	MOV R6, game							
	MOV R7, -1
	MOV [R6], R7							; Colocar o estado de jogo a -1 (em pausa)
	CALL negative							; Inverter o ecrã de jogo. Porque não?
	espera_retira_D:
		MOVB R10, [R1]						; Obtem a coluna a ser carregada
		CMP R10, R3							; A tecla ainda está carregada?
		JZ espera_retira_D					; Se sim continuamos à espera
	esperaD:
		MOV R3, 0
		MOVB R10, [R1]						; Obtem a coluna a ser carregada
		CMP R10, 2							; A tecla foi carregada?
		JNZ esperaD							; Se não continuamos à espera
	resume_game:							; Caso contrário continuamos o jogo
		CALL negative						; Voltamos a inverter o ecra de jogo para voltar ao normal
		MOV R7, 1
		MOV [R6], R7						; Colocamos o valor do estado de jogo novamente a 1 (a decorrer)
		JMP detect_l1						; Voltamos a correr o programa como normalmente

;; FIM DE JOGO E REINÍCIO ;;
		
fim:										; Epilogo: O jogo nesta fase intermedia e um ciclo. Neste caso, chegamos a este ponto quando a pontuacao chegar a 100 ou mais.
	MOV R6, game																					
	MOV R7, 0
	MOV [R6], R7							; Atualiza o estado de jogo de volta a 0 (idle)
	MOV R6, score
	MOV R6, [R6]
	CALL render_chess						; Padrao xadrez
	MOV RL, 4								; Compasso de espera
	compasso_espera_2:
		CMP RL, 0
		JNZ compasso_espera_2
		JMP reset							; E voltamos ao inicio do jogo!!
	
; ==========================================================================================================================================================
;     ==================================================================================================================================================
;                      ================================================== Atendimento de Interrupções ==================================================                
;     ==================================================================================================================================================
; ==========================================================================================================================================================

int_prim:									; Atende a interrupção primária (INT0)
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	MOV R0, game							; Endereco do estado do jogo
	MOV R0, [R0]							; Obtém o estado do jogo
	
	CMP R0, 0								; Se o jogo estiver parado (R0 = 0)
	JZ score_blink							; Funcionalidade que pisca os displays.
	CMP R0, 1								; Se o jogo estiver a decorrer (R0 = 1)
	JZ asteroide_clock
	JMP rfe_0								; Caso contrário devolvemos a interrupcao
		; ESTADO DE JOGO IDLE ===========================================
		score_blink:						; Efeito de piscar a pontuacao (balanca entre C e a pontuacao do ultimo jogo)
			MOV R0, 0FFFH					; Comparação
			CMP R10, R0						; R10 atua como flag. Se R10 = 0FFFH (usamos estes valores porque geralmente não usamos o byte de maior peso), entao passamos do estado score -> CC
			JZ case_1
			NOT R0							; NOT 0FFFH = 0F000H
			CMP R10, R0						; Se R10 = F000H (), passamos do estado CC -> score
			JZ case_2
			JMP	rfe_0						; Caso contrário terminamos o atendimento
			case_1:
				MOV R0, INPUT_SCORE			; Obtém o endereço dos displays
				MOV R1, 0CCH				; Prepara o payload
				MOVB [R0], R1				; Injeta o valor "CC" nos displays
				NOT R10						; Invertemos o valor da chave para fazermos o procedimento inverso na proxima interrupcao
				JMP rfe_0					; Termina o atendimento e devolve
			case_2:
				MOV R0, INPUT_SCORE			; Endereço dos displays
				MOV R1, score				; Endereco onde esta guardada a pontuaçao
				MOV R1, [R1]				; Obtém a pontuação
				MOVB [R0], R1				; Injeta o valor do score nos displays
				NOT R10						; Invertemos o valor da chave para fazermos o procedimento inverso na proxima interrupcao
				JMP rfe_0					; Termina o atendimento e devolve
		; ESTADO DE JOGO RUNNING ========================================
		asteroide_clock:
			MOV R0, ast_clock
			MOV R1, [R0]					; Extrai o delay atual
			CMP R1, 0						; Se o delay já for zero, então podemos gerar um novo asteroide (e nao precisamos de mudar o estado do clock)
			JZ asteroide_handler
			SUB R1, 1						; Senão diminui o delay em 1 unidade e volta a por no sitio
			MOV [R0], R1
		asteroide_handler:
			; Só se conseguirmos gerar um novo asteroide é que resetamos o clock
			MOV R0, asteroide				; Obtém o endereco dos asteroides
			MOV R1, 0						; Registo de offset
			MOV R4, 100H
			MOV R3, 300H
			; Registo-limite
			asteroide_update:				; Mover os asteroides já no mapa
				MOV R2, [R0 + R1]			; Obtém o conteúdo (coordenada) do slot (R1 = 0, 8, 16, 24 ==> 1, 2, 3, 4 (a ==> (a/8) + 1)
				CMP R2, -1					; Se o slot não estiver vazio
				JNZ asteroide_main			; Podemos atualizar o asteroide
			analisa_slot:
				CMP R1, R3					; Se já tivermos analisado o quarto slot
				JZ asteroide_empty_lookup	; Passamos a proxima fase
				ADD R1, R4					; Passa ao próximo slot (o equivalente a ADD R1, 8 - a questao aqui e que a notacao de complemento para dois nos obriga a esta abordagem)
				JMP asteroide_update		; Recomeca o processo
				asteroide_main:
					PUSH R3
					PUSH R4
					PUSH R5
					PUSH R6					; Precisamos de registos auxiliares
					PUSH R7
					
					PUSH R0					; Guardar o endereco original
					PUSH R1
					ADD R0, R1				; Passamos a procurar o conteúdo miscelâneo do asteroide
					MOV R3, [R0 + 2]		; Extraímos esse conteúdo (Velocidade Lateral, tipo, tamanho)
					MOV R4, R3
					MOV R5, R3				; Copiamos essas informações para serem separadas
					SHR R3, 8				; 0LTS > 000L (R3 é a velocidade lateral)
					SUB R3, 1				; A velocidade lateral tem um offset de 1 para evitar manipular valores negativos (se L = 0, na realidade seria -1, e assim por diante)
					SHL R4, 8				; 0LTS > TS00
					SHR R4, 12				; TS00 > 000T (R4 é o tipo do asteroide)
					SHL R5, 12				; 0LTS > S000
					SHR R5, 12				; S000 > 000S (R5 é o tamanho do asteroide)
					; Cálculo da coordenada Y
					MOV R0, R2				; Coloca o registo da posicao (formato xxyy) no registo R0, de onde a rotina xxyy_decode lê como argumento
					CALL xxyy_decode		; Separa as coordenadas		
					ADD R2, 1				; Desce o asteroide em 1 pixel
					; Cálculo da coordenada X
					MOV R6, 0				; Registo que vai contabilizar o total de movimento lateral a aplicar
					CMP RL, 0				; Se o registo de direção estiver estabilizado
					JZ add_linear			; Salta para adicionar a direcao linear natural do asteroide
					MOV R7, SPEED_THRESHOLD_0
					CMP R2, R7
					JLE add_linear			; Se o asteroide estiver muito afastado, o RL nao fara diferenca
					MOV R6, RL				; Caso contrário, fará. R6 será o simétrico.
					NEG R6
					MOV R7, SPEED_THRESHOLD_1
					CMP R2, R7
					JLE add_linear			; Se o asteroide estiver menos afastado, o RL fara alguma diferenca, mas nao mais do que aquilo que ja faz (1 pixel)
					MOV R7, SPEED_THRESHOLD_2
					CMP R2, R7
					JLE case_rl_2			; O asteroide esta perto
					JMP case_rl_3			; O asteroide esta perigosamente perto
					
					case_rl_2:
						MOV R7, 2
						MUL R6, R7
						JMP add_linear
					case_rl_3:
						MOV R7, 3
						MUL R6, R7
						
					add_linear:
						ADD R6, R3			; Adiciona a velocidade lateral natural do asteroides
						ADD R1, R6			; Adiciona a velocidade total à coordenada XX
					
					CALL xxyy_encode		; Codifica as coordenadas em xxyy
					MOV R7, R0				; Transferir o resultado para R7
					POP R1					; Vamos buscar o conteudo de R1 que guardamos.
					POP R0					; Vamos precisar do R0 que guardamos antes
					MOV [R0 + R1], R7		; Injetar na memória
					
					; Averiguar se há aumento de tamanho. R2 ainda retem a coordenada YY
					MOV R5, 1
					MOV R7, SIZE_THRESHOLD_2
					CMP R2, R7
					JLT finish
					MOV R7, SIZE_THRESHOLD_3 
					CMP R2, R7
					JLT case_sz_2
					MOV R7, SIZE_THRESHOLD_4
					CMP R2, R7 
					JLT case_sz_3
					MOV R7, SIZE_THRESHOLD_5
					CMP R2, R7
					JLT case_sz_4
					MOV R7, SIZE_THRESHOLD_6
					CMP R2, R7
					JLT case_sz_5
					JMP case_sz_6
					case_sz_2:
						MOV R5, 2
						JMP finish
					case_sz_3:
						MOV R5, 3
						JMP finish
					case_sz_4:
						MOV R5, 4
						JMP finish
					case_sz_5:
						MOV R5, 5
						JMP finish
					case_sz_6:
						MOV R5, 6
					
					finish:					; Juntar os componentes e terminar
						;MOV R1, R6			; Colocar o valor de R1 original no seu lugar
						SHL R4, 4			; 000T > 00T0
						ADD R3, 1			; Como anulamos o offset atrás, temos que o por no sítio de novo (LIFO)
						SHL R3, 8			; 000L > 0L00
						OR R5, R4
						OR R5, R3			; Juntar os componentes de novo
						ADD R0, 2			; Passar a indexar a word onde esta este tipo de dados para este asteroide
						MOV [R0 + R1], R5	; Colocar a word nesse endereco
						SUB R0, 2			; Para não estragar os acessos à memória, voltamos a por o index como estava! ^-^
					
					POP R7
					POP R6
					POP R5
					POP R4
					POP R3
					JMP analisa_slot		; Restaurar registos e terminar
			asteroide_empty_lookup:
				MOV R4, ast_clock
				MOV R5, [R4]			; Extrai o delay atual
				CMP R5, 0				; Se o delay ainda não for zero, então nao vale a pena, continuamos
				JNZ missil_slide
				
				MOV R1, 0
				empty_lookup:
					MOV R2, [R0 + R1]			; Obtém o conteúdo do slot (R1 = 0, 8, 16, 24 ==> 1, 2, 3, 4 (a ==> (a/8) + 1)
					CMP R2, -1					; Se o slot estiver vazio
					JZ asteroide_gen			; Podemos gerar o asteroide
					CMP R1, R3					; Se já tivermos analisado o quarto slot
					JZ missil_slide				; Então não podemos continuar, está tudo cheio. Passemos à próxima fase...
					SUB R1, -8					; Passa ao próximo slot (4 words = 8 bytes = 8 endereços)
					JMP empty_lookup			; Recomeca o processo
			asteroide_gen:
				ADD R0, R1					; Torna o offset "permanente"
				MOV R1, 2011H				; Coordenadas iniciais do nosso asteroide
				MOV [R0], R1				; Injeta as coordenadas na memória para depois o processo principal tratar do resto
				MOV R2, INPUT_SCORE			; Uma das maneiras de obter um número pseudo-aleatório é tentar ler de um periférico só de escrita
				MOV R1, [R2]				; Obtém o nosso valor pseudo-random
				MOV R2, R1					; Copiar o valor para outro registo
				MOV R3, 2
				MOD R1, R3					; Obtém o tipo de asteroide (0 = mau; 1 = bom)
				MOV R3, 3
				MOD R2, R3					; Obtém a direção (0 = esquerda, 1 = em frente, 2 = direita) do asteroide
				MOV R3, 1					; Definição de um asteróide com 1 píxel de tamanho
				SHL R1, 4					; Colocar o nibble da direção o sítio (2o nibble de menor peso)
				SHL R2, 8					; Colocar o nibble do tipo no sítio (3o nibble de menor peso)
				OR R3, R2
				OR R3, R1					; Juntar os três nibbles para obter o nosso asteroide
				MOV [R0 + 2], R3			; Colocar as especificações do asteroide no sítio
				
				MOV R0, ast_clock
				MOV R1, ASTEROIDE_DELAY
				MOV [R0], R1				; Recomeca o temporizador
		missil_slide:
			CMP RL, 0						; Se a barra de direçao estiver estabilizada, devolve
			JZ rfe_0
			MOV R0, 100H					; o movimento é aplicado no eixo dos XX
			MOV R1, missil					; Obtém a localização do míssi
			MOV R3, [R1]					; Extrai as coordenadas do míssil
			CMP R3, -1						; Se o míssil não existir, terminamos a interrupcao
			JZ rfe_0
			
			PUSH RL							; Já que vamos usar este registo, usemos da precaução :^)
			ADD R1, 1
			MOVB R2, [R1]					; Extrai apenas a compnente YY do míssil
			SUB R1, 1
			PUSH R3
			MOV R3, SPEED_THRESHOLD_2
			CMP R2, R3						; Se o míssil estiver dentro do threshold 3, três píxeis de deslocamento. Caso contrário, dois.
			JGE mlspeed_3
			mlspeed_2:
				MOV R2, 2
				JMP apply_missil_slide
			mlspeed_3:
				MOV R2, 3
			apply_missil_slide:
			POP R3
			MUL RL, R0						; Prepara o registo para ser aplicdo
			MUL RL, R2
			SUB R3, RL						; Aplica a velocidade lateral
			MOV [R1], R3
			POP RL
	rfe_0:
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0
		RFE									; Devolve a interrupção
;========================================================================================================================================================================
int_sec:									; Atende a interrupção secundária (INT1)
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, game							; Endereco do estado do jogo
	MOV R0, [R0]							; Obtém o estado do jogo
	
	CMP R0, 0								; Se o jogo estiver parado (R0 = 0)
	JZ flag_manip							; Manipulação da flag RL
	CMP R0, 1								; Se o jogo estiver a decorrer (R0 = 1)
	JZ missil_handler						; Trata do míssil
	JNZ rfe_1
	flag_manip:								; Manipula a flag (RL) - usado para criar compassos de espera artificiais
		CMP RL, 0							; Se já estiver a zeros, termina
		JZ rfe_1
		SUB RL, 1							; Decrementa o valor em 1
		JMP rfe_1
	missil_handler:
		MOV R0, missil
		MOV R1, [R0]
		CMP R1, -1							; Se o míssil estiver na coordenada "default", termina
		JZ rfe_1
		MOV R0, missil_range
		MOV R1, [R0]						; Senão vemos se o míssil já está no fim do seu alcance (missil_range = 12)
		MOV R2, 12
		CMP R1, R2							; Se o míssil já estiver no fim do seu alcance
		JNZ missil_update
	missil_reset:
		MOV R2, 0
		MOV [R0], R2						; Colocamos estes valores de volta ao seu estado inicial
		MOV R2, -1
		MOV [R0 - 4], R2					; Coloca a coordenada do míssil de volta ao default!
		JMP rfe_1
	missil_update:
		ADD R1, 1							
		MOV [R0], R1						; Define o novo alance percorrido em memória.
		MOV R0, missil
		MOV R1, [R0]
		SUB R1, 1
		MOV [R0], R1
		
	rfe_1:
		POP R2
		POP R1
		POP R0
		RFE									; Devolve a interrupção

; ==========================================================================================================================================================
;     ========================================================================================================================================================
;                      ===================================================== Subrotinas a executar ==============================================================           
;     ========================================================================================================================================================
; ==========================================================================================================================================================

; =============================================================================================
; === render_chess: Desenha um padrao xadrez no ecra.                          =====================
; === INPUTS: N/A									                                    =================
; === OUTPUTS: N/A                                                             =====================
; =============================================================================================
render_chess:
	; Envia os registos que vamos usar para a pilha por precaucao
	PUSH R0						
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	
	MOV R0, 55H								; Este valor e a "unidade base" para o padrao
	MOV R1, 0								; Contador local. Volta a zero a cada quatro bytes.
	MOV R2, 0								; Contador global. Para o ciclo no ultimo byte do ecra.
	MOV R3, 4								; Limite do contador local
	MOV R4, 81H								; Limite do contador global
	MOV R5, PIX_SCREEN
	SUB R5, 1								; Prepara o indexador da memoria do ecra
	
	exe_render_chess:
		NOT R0								; Inverte o padrao
		line:
			ADD R1, 1						; Atualiza contadores
			ADD R2, 1
			ADD RL, 1
			ADD R5, 1
			
			CMP R2, R4						; Confirma se nao varremos ja o ecra todo
			JZ return_render_chess			; Caso sim, termina o ciclo e restaura os registos
			
			MOVB [R5], R0					; Caso nao, injetamos o padrao no ecra
			MOD R1, R3						; Se estivermos no n-esimo byte, vai voltar a zero devido a mudanca de linha
			JZ exe_render_chess				; volta ao inicio e inverte o padrao se mudarmos de linha
			JMP line						; caso contrario, volta ao inicio sem mudar o padrao
		
	; Restaura o valor original dos registos e continua o programa
	return_render_chess:
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0
		RET
		
; =============================================================================================
; === render_empty: Limpa o ecra                                               =====================
; === INPUTS: N/A                                                                       =================
; === OUTPUTS: N/A                                                             =====================
; =============================================================================================

render_empty:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, 0								; Padrao a injetar
	MOV R1, PIX_SCREEN						; Endereco do primeiro byte do ecra
	SUB R1, 1
	MOV R2, 807FH							; Limite global
	
	exe_render_empty:
		ADD R1, 1 							; Atualiza o endereco a editar (passa ao proximo byte)
		MOVB [R1], R0						; Injeta o byte no ecra
		CMP R1, R2							; Se o endereco for o ultimo:
		JZ return_render_empty				; Para o ciclo e retoma a execucao prinicpal
		JMP exe_render_empty				; Caso contrario volta ao inicio
		
	; Restaura o valor original dos registos e continua o programa	
	return_render_empty:
		POP R2
		POP R1
		POP R0
		RET
		
; =============================================================================================
; === xxyy_decode: Separa uma word hexadecimal nas suas coordenadas X e Y      ================
; === INPUTS: R0 - Valor Hexadecimal a separar                                          =======
; === OUTPUTS: R1 - Coord. X; R2 - Coord. Y                                    ================
; =============================================================================================

xxyy_decode:
	; Esta rotina está desenhada para trabalhar em conjunção com a rotina exe_pixel. É da responsabilidade do programa principal/interrupcao gerir a pilha.
	PUSH R0
	MOV R1, R0								; Cada registo recebe uma cópia do input
	MOV R2, R0
	SHR R1, 8								; Para a coordenada X, passamos de XXYY a 00XX
	SHL R2, 8
	SHR R2, 8								; Para a coordenada Y, passamos de XXYY a YY00 e depois a 00YY
	MOV R0, 10H
	SUB R1, R0
	SUB R2, R0								; Como a notação XXYY tem um offset de 10H, temos que anular esse offset.
	POP R0
	RET										; Devolve e continua a execução do scope superior
	
; =============================================================================================
; === xxyy_encode: Junta duas coordenadas X e Y numa única word                ================
; === INPUTS: R1 - Coord. X; R2 - Coord. Y                                              =======
; === OUTPUTS: R0 - Word em formato XXYY                                       ================
; =============================================================================================

xxyy_encode:
	PUSH R1
	PUSH R2
	MOV R0, 10H								; O formato XXYY tem um offset de 10H para poder gerir as coordenadas negativas até um certo ponto
	ADD R1, R0
	ADD R2, R0								; Aplicamos o offset
	SHL R1, 8								; Colocamos o byte dos XX em maior peso
	OR R1, R2								; Juntamos os bytes
	MOV R0, R1								; Colocamos em R0
	POP R2
	POP R1
	RET										; Devolve e continua a execução do scope superior
		
; =============================================================================================
; === exe_pixel: Escreve num pixel especifico                                  ================
; === INPUTS: R0 - Valor; R1 - Coord. X; R2 - Coord. Y                                  =======
; === OUTPUTS: R0 - Se o píxel estava dentro do ecrã. 1 Se sim, 0 se não       ================
; =============================================================================================

exe_pixel:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R1									; Coordenada X (0 - 1FH)
	PUSH R2									; Coordenada Y (0 - 1FH)								
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R0									; Valor do pixel - Desligado se for 0, caso contrario ligado
	
	; Verifica se as coordenadas estao dentro dos limites
	; Se um número está entre 0 e 1FH (0000 0000b e 0001 1111b), entao os registos depois de um SHR de 5 bits são obrigatóriamente 0
	MOV R4, R1								; Cópia da coordenada X
	MOV R5, R2								; Cópia da coordenada Y
	SHR R4, 5
	JNZ skip_exe_pixel						; Se o valor depois do shift nao for zero entao a coordenada está out of bounds. Proceder à devolução da rotina
	SHR R5, 5
	JNZ skip_exe_pixel						; Se o valor depois do shift nao for zero entao a coordenada está out of bounds. Proceder à devolução da rotina
	
	; Se os valores testados forem zero, continuamos
	MOV R5, PIX_SCREEN						; Obter o endereco-base do ecra
	MOV R3, R1								; Uma copia da coordenada X
	MOV R4, 8								; Um byte tem oito bits
	DIV R1, R4                              ; Obtem o byte relativamente a linha (0 - 3)
	MOV R4, 8
	MOD R3, R4								; Obtem o bit em relacao ao inicio do byte (0 - 7)
	MOV R4, 4
	MUL R2, R4								; Obtem a linha (a partir da coordenada Y)
	ADD R2, R1								; Obtem o byte a aceder (0 - 7F)
	
	ADD R2, R5								; Obtem o endereco do byte a editar
	MOV R1, mascaras						; Obter endereco onde esta a mascara
	ADD R1, R3
	MOVB R1, [R1]							; Obter a mascara
		
	pix:
	MOVB R4, [R2]							; Obter o byte original
		CMP R0,0							; Se o valor-argumento for igual a zero, desligar
		JNZ on								; Caso contrario, ligar
	off:
		NOT R1								; Inverter a mascara (0010 0000b passa a 1101 1111b)
		AND R4, R1							; A operacao AND com a mascara invertida garante que apenas o bit especificado e desligado
		JMP inject_pixel					; Re-injetar o pixel e terminar
	on:
		OR R4, R1							; A operacao OR com a mascara garante que apenas o bit especificado e ligado 
	inject_pixel:
		MOVB [R2], R4						; Injeta o bit modificado
		MOV R5, 1							; Indicação de que a rotina foi executada com sucesso
		JMP return_exe_pixel				; Restaura o valor original dos registos e continua o programa
	skip_exe_pixel:
		MOV R5, 0							; Indicação que a rotina NÃO foi executada
	return_exe_pixel:
		POP R0
		MOV R0, R5							; Colocar o valor final da execução em R0
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		RET
		
; =============================================================================================
; === negative: Inverte todas as cores do ecra                                 ================
; === INPUTS: N/A                                                                       =======
; === OUTPUTS: N/A                                                             ================
; =============================================================================================

negative:									; Deve ser usado apenas com o jogo em pausa! ^.^
	; Envia os registos a usar para a pilha por precaucao
	PUSH R0
	PUSH R1
	PUSH R2							

	MOV R0, PIX_SCREEN						; Obter o endereco-base do ecra
	MOV R2, 807FH							; Limite global
	
	neg_byte:
		MOVB R1, [R0]						; Pegamos no endereco e extraimos o byte dai
		NOT R1								; Inverte o padrão
		MOVB [R0], R1						; Volta a injetar o padrao invertido no ecra
		CMP R0, R2							; Já chegámos ao último byte do ecrã?
		JZ return_negative					; Se sim, terminamos
		ADD R0, 1							; Passa ao proximo byte
		JMP neg_byte						; Repete!
		
	return_negative:
		POP R2
		POP R1
		POP R0
		RET
		
; =============================================================================================
; === update_handle: Atualiza a posicao do volante                             ================
; === INPUTS: RL - Direcao (-1 = Esq.; 0 = Est.; 1 = Dir.)                              =======
; === OUTPUTS: N/A                                                             ================
; =============================================================================================

update_handle:
	; Envia os registos a usar para a pilha por precaucao
	PUSH R0									; ====
	PUSH R1									; Argumentos utilizados pela rotina exe_pixel
	PUSH R2									; ====
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH RL
	; "Mover" pixeis
	
	MOV R3, wheel							; Inicializacao do endereco de memoria
	ADD RL, 1								; Adiciona 1 ao registo de direcao, para efeitos de acesso a memoria
	ADD R3, RL								; Obtem o endereco a partir do qual vamos comecar a aceder. (wheel para D = -1; wheel + 1 para D = 0; wheel + 2 para D = 1)
	MOVB R3, [R3]							; Obtem um byte que nos vai indicar como é que vamos manipular o volante
	SHL R3, 8								; Põe o byte em maior peso
	MOV R1, 13
	MOV R2, 28								; Varrimento dos pontos (13, 28), (13, 29), (13, 30), (18, 28), (18, 29), (18, 30), com valores de acordo com a memoria
	MOV R4, 31								; Limite (exclusive o 31)
	MOV R5, 18								; Limite X (inclusive o 18)
	MOV RE, 0								; Desativa todas as flags
	
	vertical_exe:							
		CMP R2, R4
		JZ update_X
		SHL R3, 1							; Afasta o bit à esquerda
		SHR RE, 2
		MOV R0, RE							; Se o bit "eliminado" tiver sido 1, a flag CARRY ter-se-à ativado
		CALL exe_pixel
		ADD R3, 1
		ADD R2, 1
		JMP vertical_exe
	
	update_X:
		CMP R1, R5
		JZ return_update_handle
		MOV R1, R5
		MOV R2, 28
		JMP vertical_exe
	
	return_update_handle:
	; Restaura o valor original dos registos e continua o programa
		POP RL
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0
		RET
		
; =============================================================================================
; === score_up: Aumenta a pontuação do jogador                                 ================
; === INPUTS: R10 - A quantidade de pontos a aumentar. Injeta nos displays              =======
; === OUTPUTS: [score] - A nova pontuação do jogador                           ================
; =============================================================================================
	
score_up:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	
	MOV R0, score							; Memoria nao-periferica da pontuacao
	MOV R1, [R0]							; Carrega a pontuacao anterior
	
	ADD R1, R10								; Aumenta a pontuacao em 3 pontos
	MOV R2, R1								; R2 = Dezenas; R1 = Unidades
	SHR R2, 4	   							; Elimina o nibble das unidades (ficamos so com as dezenas)
	SHL R1, 12
	SHR R1, 12								; Elimina o nibble das dezenas (ficamos so com as unidades)
	
	MOV R3, 0AH
	CMP R1, R3								; Se o nibble das unidades for < 10
	JLT inject_score						; Injeta os nibbles
	SUB R1, R3								; Senão subtrai 10 ao nibble das unidades
	ADD R2, 1								; Adiciona 1 as dezenas
		
	inject_score:
		SHL R2, 4								; Poe o nibble das dezenas em posicao
		OR R1, R2								; Junta os nibbles
		MOV [R0], R1							; Injeta a pontuacao nova na memoria
		MOV R0, INPUT_SCORE
		MOVB [R0], R1							; Atualiza os desplays
		
	return_score_up:
		POP R3
		POP R2
		POP R1
		POP R0
		RET
		
; ==============================================================================================================================
; === exe_asteroide: Desenha ou apaga um asteroide no ecra                                                      ================
; === INPUTS: R8 - Endrecos do desenho (proc. principal) onde se encontram o asteroide e respetiva posição; R9 - On/Off  =======
; === OUTPUTS: N/A                                                                                              ================
; ==============================================================================================================================
	
exe_asteroide:
	PUSH R0									; Vamos precisar destes registos para a rotina exe_píxel
	PUSH R1
	PUSH R2
	PUSH R3									; Registos auxiliares: R3 = Tamanho
	PUSH R4									; R4 = Tipo/ CRX
	PUSH R5									; R5 = CRY
	PUSH R6									; R6 = Flag de retorno
	PUSH R7									; R7&R8 = Pontos de permissão/Enderecos
	PUSH R9									; R9 = Ordem (On/Off)	
	PUSH R10								; Registo para perceber se o asteroide se encontra inteiramente dentro do ecra
	
	; O esquema do asteroide é dado por 0LTS - Velocidade Lateral, Tipo, Tamanho
	MOV R10, 0								; Vai-nos indicar se havia pelo menos uma parte do asteroide dentro do ecra
	MOV R0, [R8]
	CALL xxyy_decode						; Separa as coordenadas X e Y e coloca-as em R1 e R2, respetivamente
	PUSH R8									; Vamos estragar estes registos e vamos precisar dele mais tarde, provavelmente.
	MOV R0, R9								; Indica que vamos ligar ou desligar o conjunto de píxeis selecionados
	; O anchor point do asteróide (onde se encontra o píxel que as coordenadas na memória apontam) encontra-se no canto inferior esquerdo.
	; Isto quer dizer que os pixeis sao processados para a direita (XX positivo) e para cima (YY negativo)
	MOV R3, [R8 + 2]						; Obtém o registo referente a características miscelaneas
	MOV R4, R3								; Cópia dos registos
	SHL R3, 12								; 0LTS > S000
	SHR R3, 12								; S000 > 000S (R3 é o tamanho do asteroide)
	SHL R4, 8								; 0LTS > TS00
	SHR R4, 12								; TS00 > 000T (R4 é o tipo de asteroide)
	
	CMP R4, 2								; Se o tipo for 2, então foi abatido
	JZ exe_rekt
	CMP R4, 1								; Se o tipo for 1, então é bom
	JZ exe_good
	; Caso contário, o tipo é 0, e é mau.
	; R4 e R5 passam a ser as coordenadas relativas de X e Y, respetivamente
	exe_evil:								; O asteroide é mau
		MOV R4, 1								; Coordenada X relativa ao referencial do asteroide
		MOV R5, 1								; Coordenada Y relativa ao referencial do asteroide
		CMP R3, 1
		JZ case_1_pixel						; Se o tamanho do asteroide for 1 ou 2, o algoritmo "normal" nao vai funcionar
		CMP R3, 2
		JZ case_2_pixel
		JMP case_default_pixel
		case_1_pixel:
			MOV R0, R9
			CALL exe_pixel
			MOV R10, R0
			JMP return_exe_asteroide
		case_2_pixel:						; Como o numero de pixeis é pequeno podemos fazer isto sequencialmente
			MOV R0, R9
			CALL exe_pixel					; Coordenadas (1,1)
			OR R10, R0
			MOV R0, R9
			ADD R1, 1						; Coordenadas (2,1)
			CALL exe_pixel
			OR R10, R0
			MOV R0, R9
			SUB R2, 1						; Coordenadas (2,2)
			CALL exe_pixel
			OR R10, R0
			MOV R0, R9
			SUB R1, 1						; Coordenadas (1,2)
			CALL exe_pixel
			OR R10, R0
			JMP return_exe_asteroide		; É sempre importante manter o registo R0 atualizado porque a rotina exe_pixel devolve o estado de execucao
		case_default_pixel:
			CMP R5, 1							; Se a coordenada relativa Y for 1 ou igual ao tamanho, vamos fazer uma linha nao completa
			JZ semi_line
			CMP R5, R3
			JZ semi_line
			JMP full_line						; Senão fazemos uma linha completa
			semi_line:							; Mini-rotinas que só devem ser usadas dentro deste scope!
				MOV R0, R9						; Garantir que a ordem a dar e a definida
				CMP R4, 1						; Se o pixel for o primeiro ou ultimo da linha, saltamos
				JZ pixel_skip_evil
				CMP R4, R3
				JZ pixel_skip_evil
				CALL exe_pixel					; Senão desenha
				OR R10, R0						; O píxel foi desenhado?
				;------------------------------
				pixel_skip_evil:			
					ADD R4, 1					; Avança no píxel horizontal
					CMP R4, R3					; Se relativamente ao referencial, for maior que o tamanho
					JGT check_step_evil			; Muda de linha
					ADD R1, 1					; Senão aumenta a coordenada X real
					JMP semi_line				; Repete o processo
				
			full_line:
				MOV R0, R9						; Garantir que a ordem a dar e a definida (on sempre on, off sempre off)
				CALL exe_pixel					; Desenha o píxel
				OR R10, R0						; O píxel foi desenhado?
				;------------------------------
				ADD R4, 1						; Avança no píxel horizontal
				CMP R4, R3						; Se relativamente ao referencial, for maior que o tamanho
				JGT check_step_evil				; Muda de linha
				ADD R1, 1						; Aumenta a coordenada X real
				JMP full_line					; Repete o processo
				
			check_step_evil:
				CALL step_Y						; Atualiza a coordenada Y
				CMP R6, 1						
				JZ return_exe_asteroide
				JMP case_default_pixel
			
	exe_good:								; O asteroide é bom
		MOV R4, 1							; Coordenada X relativa ao referencial do asteroide
		MOV R5, 1							; Coordenada Y relativa ao referencial do asteroide
		MOV R7, 1							; Definem os pontos na linha onde é permitido pintar o píxel
		MOV R8, R3							
		exe_good_main:						; Ciclo principal
			CMP R4, R7						; Se o pixel for um dos permitidos, pintamos
			JZ paint
			CMP R4, R8
			JZ paint
			JMP pixel_skip_good				; Senão ignora e salta este píxel
			paint:
				MOV R0, R9					; Garantir que a ordem a dar e a definida
				CALL exe_pixel				; Pinta e continua
				OR R10, R0					; O píxel foi desenhado?
			;------------------------------
			pixel_skip_good:			
				ADD R4, 1					; Avança no píxel horizontal
				CMP R4, R3					; Se relativamente ao referencial, for maior que o tamanho
				JGT check_step_good			; Muda de linha
				ADD R1, 1					; Senão aumenta a coordenada X real
				JMP exe_good_main			; Repete o processo
				
		check_step_good:
			CALL step_Y						; Atualiza a coordenada Y
			CMP R6, 1						; Se a flag de retorno estiver ativa
			JZ return_exe_asteroide			; Terminamos
			ADD R7, 1						; Ajustamos as permissões de pintura de modo a originar uma cruz
			SUB R8, 1
			JMP exe_good_main				; Voltamos ao início
			
	exe_rekt:								; O asteroide foi abatido por um missil
		JMP return_exe_asteroide
		
	step_Y:
		ADD R5, 1							; Aumenta a coordenada relativa de Y em 1
		CMP R5, R3							; Se a coordenada relativa já for maior que o tamanho
		JGT return_flag						; Já está pronto, podemos terminar! ^.^
		; Senão continuamos a atualizar variáveis.
		SUB R2, 1							; Diminui a coordenada real de Y (o referencial do asteroide é diferente do do ecrã!)
		MOV R4, 1							; Coordenada relativa de X a 1 de novo
		SUB R1, R3							; R1 ficaria agora a 1 = (Sx + 1) - XX
		ADD R1, 1
		MOV R6, 0							; A flag de retorno é desativada
		RET
		return_flag:
			MOV R6, 1						; Ativa a flag, para indicar que já chegámos ao fim
			RET
	
	return_exe_asteroide:					; Restaurar os valores e devolver.
		POP R8								; Restauramos o nosso valor de R8
		CMP R10, 0							; O asteroide estava inteiramente ou parcialmente dentro do ecrã?
		JNZ pop_exe_asteroide				; Entao devolvemos
		MOV R0, -1							; Senao apagamos o asteroide. Puff!
		MOV [R8 - 4], R0					; Posicao definido via interrupcao
		MOV [R8], R0						; Posicao do desenho
		MOV R0, 0
		MOV [R8 - 2], R0					; Caracteristicas do asteroide
		MOV [R8 + 2], R0					; Caracteristicas do desenho
		pop_exe_asteroide:
			POP R10
			POP R9
			POP R7
			POP R6
			POP R5
			POP R4
			POP R3
			POP R2
			POP R1
			POP R0
			RET
			
; Btw bun is cool