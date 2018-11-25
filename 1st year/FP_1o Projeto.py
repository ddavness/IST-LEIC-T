# IST @ UL | UC de Fundamentos de Programacao - LEIC-T | Primeiro Projeto | 2018/2019

# eh_tabuleiro:	universal >>> booleano
def eh_tabuleiro(valor):
    if type(valor) != tuple or len(valor) != 3: # Se nao for um tuplo, a segunda condicao nao e avaliada.
        return False
    reg = 0 # Variavel de contagem
    for t in valor:
        reg += 1
        if type(t) != tuple or len(t) != (3 if reg != 3 else 2): # O sistema pede tres elementos para os dois primeiros tuplos, e dois para o terceiro
            return False

        for n in t:
            if n != -1 and n != 0 and n != 1: # Nao corresponde a nenhum dos valores validos
                return False

    return True # se nao tiver sido possivel despistar o valor-argumento, entao o valor pode ser tratado como tabuleiro

# tabuleiro_str: tabuleiro >>> cad. caracteres
def tabuleiro_str(tab):
    if not eh_tabuleiro(tab):
        raise ValueError ('tabuleiro_str: argumento invalido')

    clib = ("x", "0", "1") # uma pequena biblioteca de caracteres para evitar ciclos condicionais
    indexlist = ((0,2),(0,1),(1,2),(0,0),(1,1),(2,1),(1,0),(2,0))
    form = list()

    repstr = "+-------+\n" # repstr = Representacao por string
    repstr = repstr + "|...{0}...|\n" # A linha de cima e o terceiro elemento do 1o tuplo
    repstr = repstr + "|..{1}.{2}..|\n" # A linha intermedia e composta pelo 2o elemento do 1o tuplo e pelo 3o do 2o tuplo
    repstr = repstr + "|.{3}.{4}.{5}.|\n" # Composicao da linha maior
    repstr = repstr + "|..{6}.{7}..|\n" # Composicao da ultima linha
    repstr = repstr + "+-------+"

    for i in indexlist:
        form.append(clib[tab[i[0]][i[1]] + 1]) # Ex: clib[0] = "x" >>> 0 = -1 + 1

    repstr = repstr.format(*form) # Desdobra a lista e coloca os valores nos respetivos lugares
    return repstr

# tabuleiros_iguais: tabuleiro x tabuleiro >>> booleano
def tabuleiros_iguais(a, b):
    if not eh_tabuleiro(a) or not eh_tabuleiro(b):
        raise ValueError('tabuleiros_iguais: um dos argumentos nao e tabuleiro')

    # Dois tabuleiros sao iguais se e so se a == b (p.ex. em Lua teriamos que comparar as rep. graficas)
    return (a == b)

# iv: {-1, 0, 1} >>> {-1, 1, 0}
def iv(v):
    return (-1 if v == -1 else (-v + 1))# -0 + 1 = 1; -1 + 1 = 0

# getvars: tabuleiro >>> tuplo x tuplo x tuplo
def getvars(tb):
    return tb[0], tb[1], tb[2] # separa o tabuleiro nos seus componentes

# porta_x: tabuleiro x {"E", "D"} >>> tabuleiro
def porta_x(t, lado):
    if not eh_tabuleiro(t) or (lado != "D" and lado != "E"):
        raise ValueError('porta_x: um dos argumentos e invalido')
    # variaveis para simplificar o processo e encurtar linhas
    a,b,c = getvars(t)

    if lado == "E":
        # a esquerda temos que inverter todos os elementos do 2o tuplo
        return(a, (iv(b[0]), iv(b[1]), iv(b[2])), c)
    else:   # Ja validamos o argumento "lado" pelo que se nao for E, so pode ser D
        # a direita, temos que inverter os valores do meio de cada tuplo (o primeiro do terceiro)
        return((a[0], iv(a[1]), a[2]), (b[0], iv(b[1]), b[2]), (iv(c[0]), c[1]))

# porta_z: tabuleiro x {"E", "D"} >>> tabuleiro
def porta_z(t, lado):
    if not eh_tabuleiro(t) or (lado != "D" and lado != "E"):
        raise ValueError('porta_z: um dos argumentos e invalido')
    a,b,c = getvars(t)

    if lado == "E":
        # a esquerda temos que inverter todos os elementos do 1o tuplo
        return((iv(a[0]), iv(a[1]), iv(a[2])), b, c)
    else:
        # a direita, temos que inverter os valores do ultimo membro de cada tuplo
        return((a[0], a[1], iv(a[2])), (b[0], b[1], iv(b[2])), (c[0], iv(c[1])))

# porta_h: tabuleiro x {"E", "D"} >>> tabuleiro
def porta_h(t, lado):
    if not eh_tabuleiro(t) or (lado != "D" and lado != "E"):
        raise ValueError('porta_h: um dos argumentos e invalido')
    a,b,c = getvars(t)

    if lado == "E":
        # a esquerda temos que trocar os 1o e 2o tuplos entre si
        return(b, a, c)
    else:
        # a direita, temos que trocar os dois ultimos membros de cada tuplo entre si
        return((a[0], a[2], a[1]), (b[0], b[2], b[1]), (c[1], c[0]))
