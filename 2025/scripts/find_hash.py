import hashlib
import time


def calcular_hash(dados, nonce):
    texto = dados + str(nonce)
    return hashlib.sha256(texto.encode()).hexdigest()


def minerar_bloco(dados, dificuldade):
    prefixo = "0" * dificuldade
    nonce = 0
    inicio = time.time()

    while True:
        hash_resultado = calcular_hash(dados, nonce)
        if hash_resultado.startswith(prefixo):
            duracao = time.time() - inicio
            print("Bloco minerado!")
            print(f"Nonce encontrado: {nonce}")
            print(f"Hash: {hash_resultado}")
            print(f"Tempo: {duracao:.2f} segundos")
            break
        nonce += 1


dados_do_bloco = "Transacoes do bloco anterior + timestamp + Merkle root"
dificuldade = 7

minerar_bloco(dados_do_bloco, dificuldade)
