import hashlib

# TODO: Modifique o hash alvo abaixo para testar com valores do dicionário
target_hash = "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
print(f"[+] Hash alvo: {target_hash}")

dictionary = [
    "password",
    "123456",
    "admin",
    "qwerty",
    "letmein",
    "dragon",
    "hello",
    "iloveyou",
    "welcome",
    "monkey",
    "secret",
]

for word in dictionary:
    hash_attempt = hashlib.sha256(word.encode()).hexdigest()
    if hash_attempt == target_hash:
        print(f"[+] Hash encontrado: {hash_attempt}")
        print(f"[+] Palavra descoberta: '{word}'")
        break
else:
    print("[-] Nenhuma palavra do dicionário gerou o hash.")
