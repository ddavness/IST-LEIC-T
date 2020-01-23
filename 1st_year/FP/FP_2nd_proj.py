# IST @ UL | UC de Fundamentos de Programacao - LEIC-T | Segundo Projeto | 2018/2019

##################################
# INTERFACE E ABSTRACAO DE DADOS #
##################################

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# * TAD Celula (representada por um dicionario cuja unica chave e "valor")
# * Representacao: celula = {"valor": a}, a --> (-1, 0, 1)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


def cria_celula(cv):
    """
    cria_celula: {-1, 0, 1} >>> celula
        - Cria uma celula a partir de um valor numerico que representa o seu estado
    """
    if cv not in (-1, 0, 1):
        raise ValueError("cria_celula: argumento invalido.")
    return {"valor": cv}


def eh_celula(cell):
    """
    eh_celula: universal >>> logico
        - Determina se o valor dado e do tipo celula ou nao
    """
    if not isinstance(cell, dict):
        return False
    elif "valor" not in cell or len(cell.keys()) != 1:
        return False
    return cell["valor"] in (-1, 0, 1)


def obter_valor(cell):
    """
    obter_valor: celula >>> {1, 0, -1}
        - Obtem o valor numerico associado ao estado da celula
    """
    if not eh_celula(cell):
        raise ValueError("obter_valor: argumentos invalidos.")
    return cell["valor"]


def inverte_estado(cell):
    """
    inverte_estado: celula >>> celula
        - Inverte o estado da celula. Celulas no estado incerto continuam no estado incerto.
    """
    if not eh_celula(cell):
        raise ValueError("inverte_estado: argumentos invalidos.")
    if obter_valor(cell) != -1:
        cell["valor"] = 1 - obter_valor(cell)  # (1 - 0 = 1; 1 - 1 = 0)
    return cell


def celulas_iguais(c1, c2):
    """
    celulas_iguais: celula x celula >>> logico
        - Determina se duas coordenadas apresentam o mesmo estado (ativo/inativo/incerto)
    """
    if not (eh_celula(c1) and eh_celula(c2)):
        return False
    return obter_valor(c1) == obter_valor(c2)


def celula_para_str(cell):
    """
    celula_para_str: celula >>> cad. caracteres
        - Devolve uma representacao do estado da celula passivel de ser apresentada em consola de maneira facil para o jogador.
    """
    if not eh_celula(cell):
        raise ValueError("celula_para_str: argumento invalido.")
    return "x" if obter_valor(cell) == -1 else str(obter_valor(cell))


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# * TAD Coordenada (representada por um tuplo binario (de dois elementos))
# * Representacao: coordenada = (x, y), x, y --> (0, 1, 2)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


def cria_coordenada(x, y):
    """
    cria_coordenada: {0, 1, 2} x {0, 1, 2} >>> coordenada
        - Cria um valor do tipo "coordenada" a partir de dois valores, linha e coluna, coordenadas X e Y
    """
    if x not in (0, 1, 2) or y not in (0, 1, 2):
        raise ValueError("cria_coordenada: argumentos invalidos.")
    return (x, y)


def eh_coordenada(coord):
    """
    eh_coordenada: universal >>> logico
        - Determina se o valor dado e do tipo coordenada
    """
    if not isinstance(coord, tuple) or len(coord) != 2:
        return False
    return (coord[0] in (0, 1, 2)) and (coord[1] in (0, 1, 2))


def coordenada_linha(coord):
    """
    coordenada_linha: coordenada >>> {0, 1, 2}
        - Extrai o valor da linha da coordenada (posicao X)
    """
    if not eh_coordenada(coord):
        raise ValueError("coordenada_linha: argumento invalido.")
    return coord[0]


def coordenada_coluna(coord):
    """
    coordenada_coluna: coordenada >>> {0, 1, 2}
        - Extrai o valor da coluna da coordenada (posicao Y)
    """
    if not eh_coordenada(coord):
        raise ValueError("coordenada_coluna: argumento invalido.")
    return coord[1]


def coordenadas_iguais(c1, c2):
    """
    coordenadas_iguais: coordenada x coordenada >>> logico
        - Determina se duas coordenadas apontam para a mesma posicao no tabuleiro.
    """
    if not (eh_coordenada(c1) and eh_coordenada(c2)):
        return False
    return coordenada_linha(c1) == coordenada_linha(c2) and coordenada_coluna(c1) == coordenada_coluna(c2)


def coordenada_para_str(coord):
    """
    coordenada_para_str: coordenada >>> cad. caracteres
        - Escreve a coordenada numa forma que possa ser apresentada na consola.
    """
    if not eh_coordenada(coord):
        raise ValueError("coordenada_para_str: argumento invalido.")
    return str(coord)  # A representacao da coordenada em string ja e a representacao pedida, tudo a fazer e uma conversao


def str_para_coordenada(rep_coord):
    """
    str_para_coordenada: cad. caracteres >>> coordenada
        - Funcao auxiliar inversa da funcao coordenada_para_str. Aceita e valida uma cadeia de caracteres do tipo (x, y)
    e devolve uma coordenada a partir da representacao dada. Devolve None se o argumento estiver num formato invalido.
    """
    conjunto = None
    try:
        conjunto = eval(rep_coord)
    except Exception:
        return None  # Devolve None caso nao consigamos transformar a cadeia

    if not isinstance(conjunto, tuple) or len(conjunto) != 2:
        return None

    try:  # Tenta criar a coordenada. Se nao conseguir devolve None.
        return cria_coordenada(conjunto[0], conjunto[1])
    except ValueError:
        return None


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# * TAD Tabuleiro (representada por um dicionario de chaves-coordenada e valores-celula)
# * Representacao: tabuleiro = {coordenada1: celula1, coordenada2: celula2, ...}. As chaves-coordenada sao apresentadas
# em string (com a funcao coordenada_para_str()
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


def str_para_tabuleiro(string):
    """
    str_para_tabuleiro: cad. caracteres >>> tabuleiro
        - Cria um tabuleiro a partir de uma codificacao de um tuplo de tuplos (semelhante ao primeiro projeto).
        - Devolve erro se a codificacao for invalida.
    """
    valor = None
    try:
        valor = eval(string)
    except Exception:
        raise ValueError("str_para_tabuleiro: argumento invalido.")
    # Perceber se a string se encontra no formato correto para ser convertida (parsing). Devolve um erro se nao estiver
    if type(valor) != tuple or len(valor) != 3:
        raise ValueError("str_para_tabuleiro: argumento invalido.")
    reg = 0
    for t in valor:
        reg += 1
        if type(t) != tuple or len(t) != (3 if reg != 3 else 2):
            raise ValueError("str_para_tabuleiro: argumento invalido.")
        for n in t:
            if n not in (-1, 0, 1):
                raise ValueError("str_para_tabuleiro: argumento invalido.")
    # Converter o formato num tabuleiro
    tabuleiro = dict()
    for i in range(2):  # Criar o tabuleiro
        for j in range(3):
            tabuleiro[coordenada_para_str(cria_coordenada(i, j))] = cria_celula(valor[i][j])

    for j in range(2):  # Para a linha 2, a coordenada (2, 0) nao existe, por isso adicionamos 1 a "coordenada-destino"
        tabuleiro[coordenada_para_str(cria_coordenada(2, j + 1))] = cria_celula(valor[2][j])
    return tabuleiro


def tabuleiro_inicial():
    """
    tabuleiro_inicial: {} >>> tabuleiro
        - Um "mirror" para a funcao "str_para_tabuleiro" com um valor especifico. Devolve sempre o mesmo tabuleiro.
    """
    return str_para_tabuleiro("((-1, -1, -1), (0, 0, -1), (0, -1))")


def eh_tabuleiro(tab):
    """
    eh_tabuleiro: universal >>> logico
        - Determina se o valor dado e um tabuleiro
    """
    if not isinstance(tab, dict) or len(tab.keys()) != 8:  # Um tabuleiro e um dicionario de 8 coordenadas-chave
        return False
    for chave, valor in tab.items():
        coord = str_para_coordenada(chave)  # Tenta converter a representacao para coordenada
        if coord is None:  # a representacao nao e uma coordenada
            return False

        if not eh_celula(valor) or (coordenada_linha(coord) == 2 and coordenada_coluna(coord) == 0):
            # Nao e tabuleiro se houver um valor nao celula ou se a coord. for (2, 0) - que nao existe
            return False
    return True


def tabuleiro_dimensao(t):
    """
    tabuleiro_dimensao: tabuleiro >>> |N
        - Devolve o numero de linhas/colunas do tabuleiro (baseando-se na coordenada de maior valor possivel). Em
    condicoes normais em que o valor e um tabuleiro, a funcao devera devolver sempre o mesmo valor: 3
    """
    if not eh_tabuleiro(t):
        raise ValueError("tabuleiro_dimensao: argumento invalido.")
    n = 0
    for k in t.keys():
        coord = str_para_coordenada(k)
        n = coordenada_linha(coord) if coordenada_linha(coord) > n else n
    return n + 1


def tabuleiro_celula(tab, coord):
    """
    tabuleiro_celula: tabuleiro x coordenada >>> celula
        - Localiza uma celula numa dada coordenada e devolve essa celula do tabuleiro
    """
    if not (eh_tabuleiro(tab) and eh_coordenada(coord)):
        raise ValueError("tabuleiro_celula: argumentos invalidos.")
    return tab[coordenada_para_str(coord)]


def tabuleiro_substitui_celula(tab, ncell, coord):
    """
    tabuleiro_substitui_celula: tabuleiro x celula x coordenada >>> tabuleiro
        - Localiza uma celula numa dada coordenada e substitui essa cekula por outra, devolvendo o tabuleiro modificado.
    """
    if not (eh_tabuleiro(tab) and eh_celula(ncell) and eh_coordenada(coord)):
        raise ValueError("tabuleiro_substitui_celula: argumentos invalidos.")
    tab[coordenada_para_str(coord)] = ncell
    return tab


def tabuleiro_inverte_estado(tab, coord):
    """
    tabuleiro_inverte_estado: tabuleiro x coordenada >>> tabuleiro
        - Inverte o estado de uma celula contida na coordenada do tabuleiro dado. Devolve o tabuleiro modificado.
    """
    if not (eh_tabuleiro(tab) and eh_coordenada(coord)):
        raise ValueError("tabuleiro_inverte_estado: argumentos invalidos.")
    return tabuleiro_substitui_celula(tab, inverte_estado(tabuleiro_celula(tab, coord)), coord)


def tabuleiros_iguais(t1, t2):
    """
    tabuleiros_iguais: tabuleiro x tabuleiro >>> logico
        - Determina se dois tabuleiros sao iguais, isto e, para a mesma coordenada, as respetivas celulas apresentam
    o mesmo estado.
    """
    if not (eh_tabuleiro(t1) and eh_tabuleiro(t2)):
        return False
    for k in t1.keys():
        coord = str_para_coordenada(k)
        if tabuleiro_celula(t1, coord) != tabuleiro_celula(t2, coord):
            return False
    return True


def tabuleiro_para_str(tab):
    """
    tabuleiro_para_str: tabuleiro >>> cad. caracteres
        - Aceita um tabuleiro e devolve uma representacao do tabuleiro inteligivel para um jogador humano
    """
    if not eh_tabuleiro(tab):
        raise ValueError("tabuleiro_para_str: argumentos invalidos.")
    encode = "+-------+\n|...{2}...|\n|..{1}.{5}..|\n|.{0}.{4}.{7}.|\n|..{3}.{6}..|\n+-------+"

    def _coordenada_prioridade(c):
        """
        _coordenada_prioridade: coordenada >>> inteiro
            - Transforma uma coordenada num valor numerico que pode ser usado para garantir que a lista de coordenadas e ordenada
            - Esta funcao e auxiliar e serve para ser conjugada com a funcao sort() para efeitos de comparacao
        """
        return int(str(coordenada_linha(c)) + str(coordenada_coluna(c)))  # (0, 0) > 00; (1, 0) > 10

    coords = [str_para_coordenada(x) for x in tab.keys()]  # cria uma lista com todas as coordenadas do tabuleiro
    coords.sort(key=_coordenada_prioridade)

    return encode.format(*[celula_para_str(tabuleiro_celula(tab, coord)) for coord in coords])


##################################
# INTEFACE DE JOGO DE ALTO NIVEL #
##################################


def porta_x(tab, lado):
    """
    porta_X: tabuleiro x {'E', 'D'} >>> tabuleiro
        - Funcao que recebe um tabuleiro e um lado (esquerda ou direita) e executa a porta X nesse tabuleiro.
    """
    if not (eh_tabuleiro(tab) and lado in ("E", "D")):
        raise ValueError("porta_x: argumentos invalidos.")
    # Lado esq.: linha 1; Lado dir.: coluna 1
    result = None
    if lado == "E":
        for i in range(3):
            result = tabuleiro_inverte_estado(tab, cria_coordenada(1, i))
    else:
        for i in range(3):
            result = tabuleiro_inverte_estado(tab, cria_coordenada(i, 1))
    return result


def porta_z(tab, lado):
    """
    porta_z: tabuleiro x {'E', 'D'} >>> tabuleiro
        - Funcao que recebe um tabuleiro e um lado (esquerda ou direita) e executa a porta Z nesse tabuleiro.
    """
    if not (eh_tabuleiro(tab) and lado in ("E", "D")):
        raise ValueError("porta_z: argumentos invalidos.")
    # Lado esq.: linha 0; Lado dir.: coluna 2
    result = None
    if lado == "E":
        for i in range(3):
            result = tabuleiro_inverte_estado(tab, cria_coordenada(0, i))
    else:
        for i in range(3):
            result = tabuleiro_inverte_estado(tab, cria_coordenada(i, 2))
    return result


def porta_h(tab, lado):
    """
    porta_h: tabuleiro x {'E', 'D'} >>> tabuleiro
        - Funcao que recebe um tabuleiro e um lado (esquerda ou direita) e executa a porta H nesse tabuleiro.
    """
    if not (eh_tabuleiro(tab) and lado in ("E", "D")):
        raise ValueError("porta_h: argumentos invalidos.")
    # Lado esq.: linhas 0 e 1; Lado dir.: colunas 1 e 2
    if lado == "E":
        for i in range(3):
            temp = tabuleiro_celula(tab, cria_coordenada(0, i))
            tabuleiro_substitui_celula(tab, tabuleiro_celula(tab, cria_coordenada(1, i)), cria_coordenada(0, i))
            tabuleiro_substitui_celula(tab, temp, cria_coordenada(1, i))
    else:
        for i in range(3):
            temp = tabuleiro_celula(tab, cria_coordenada(i, 1))
            tabuleiro_substitui_celula(tab, tabuleiro_celula(tab, cria_coordenada(i, 2)), cria_coordenada(i, 1))
            tabuleiro_substitui_celula(tab, temp, cria_coordenada(i, 2))
    return tab


####################
# OPERACAO DO JOGO #
####################
def hello_quantum(string_execucao):
    """
    hello_quantum: cad. caracteres >>> logico
        - Executa um jogo de Hello Quantum! em consola, usando a interface de abstracao de dados acima.
        - O jogo para quando o jogador constroi o tabuleiro-alvo dentro do limite de jogadas dado, ou quando o jogador usa
     todos as jogadas sem conseguir construir o tabuleiro-alvo
    """
    tab_str, max_jogadas = string_execucao.split(":")
    tabuleiro_alvo = str_para_tabuleiro(tab_str)
    max_jogadas = int(max_jogadas)
    tabuleiro_atual = tabuleiro_inicial()

    print("Bem-vindo ao Hello Quantum!\nO seu objetivo e chegar ao tabuleiro:")
    print(tabuleiro_para_str(tabuleiro_alvo))
    print("Comecando com o tabuleiro que se segue:")
    print(tabuleiro_para_str(tabuleiro_atual))

    for n in range(1, max_jogadas + 1):
        porta = str(input("Escolha uma porta para aplicar (X, Z ou H): "))
        lado = input("Escolha um qubit para analisar (E ou D): ")
        if porta == "X":
            porta_x(tabuleiro_atual, lado)
        elif porta == "Z":
            porta_z(tabuleiro_atual, lado)
        elif porta == "H":
            porta_h(tabuleiro_atual, lado)

        print(tabuleiro_para_str(tabuleiro_atual))
        if tabuleiros_iguais(tabuleiro_atual, tabuleiro_alvo):
            print("Parabens, conseguiu converter o tabuleiro em " + str(n) + " jogadas!")
            return True

    return False
