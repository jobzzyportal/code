# -------------------------------
# TWO PASS ASSEMBLER (FINAL FIXED)
# -------------------------------

MOT = {
    "STOP": ("IS", 0),
    "ADD": ("IS", 1),
    "SUB": ("IS", 2),
    "MULT": ("IS", 3),
    "MOVER": ("IS", 4),
    "MOVEM": ("IS", 5),
    "COMP": ("IS", 6),
    "BC": ("IS", 7),
    "DIV": ("IS", 8),
    "READ": ("IS", 9),
    "PRINT": ("IS", 10),
    "LOAD": ("IS", 11),

    "START": ("AD", 1),
    "END": ("AD", 2),
    "ORIGIN": ("AD", 3),
    "EQU": ("AD", 4),
    "LTORG": ("AD", 5),

    "DS": ("DL", 1),
    "DC": ("DL", 2)
}

REGISTERS = {
    "AREG": 1,
    "BREG": 2,
    "CREG": 3,
    "DREG": 4
}

# -------------------------------
# DATA STRUCTURES
# -------------------------------
SYMTAB = {}
LITTAB = []
POOLTAB = [0]
INTERMEDIATE_CODE = []
symbol_used = {}

LC = 0
errors = set()


# -------------------------------
# FUNCTIONS
# -------------------------------
def is_literal(word):
    return word.startswith("='")


def get_literal_index(lit):
    for i, (l, _) in enumerate(LITTAB):
        if l == lit:
            return i + 1
    LITTAB.append((lit, None))
    return len(LITTAB)


def process_literals():
    global LC
    start = POOLTAB[-1]

    for i in range(start, len(LITTAB)):
        lit, addr = LITTAB[i]
        if addr is None:
            LITTAB[i] = (lit, LC)
            LC += 1

    # Only append if new pool formed
    if POOLTAB[-1] != len(LITTAB):
        POOLTAB.append(len(LITTAB))


# -------------------------------
# READ FILE
# -------------------------------
with open("ass1.asm", "r") as file:
    lines = file.readlines()


# -------------------------------
# PASS 1
# -------------------------------
for line in lines:
    tokens = line.strip().split()

    if not tokens:
        continue

    label = None

    # LABEL
    if tokens[0] not in MOT:
        label = tokens[0]

        if label in SYMTAB and SYMTAB[label] is not None:
            errors.add(f"Duplicate symbol: {label}")
        else:
            SYMTAB[label] = LC
            symbol_used[label] = symbol_used.get(label, 0)

        tokens = tokens[1:]

    if not tokens:
        continue

    mnemonic = tokens[0]

    if mnemonic not in MOT:
        errors.add(f"Invalid mnemonic: {mnemonic}")
        continue

    cls, opcode = MOT[mnemonic]

    # -------------------------------
    # INSTRUCTION HANDLING
    # -------------------------------

    if mnemonic == "START":
        LC = int(tokens[1])
        INTERMEDIATE_CODE.append((LC, f"(AD,{opcode}) (C,{tokens[1]})"))

    elif mnemonic == "END":
        process_literals()
        INTERMEDIATE_CODE.append((LC, f"(AD,{opcode})"))

    elif mnemonic == "LTORG":
        process_literals()
        INTERMEDIATE_CODE.append((LC, f"(AD,{opcode})"))

    elif mnemonic == "DC":
        INTERMEDIATE_CODE.append((LC, f"(DL,{opcode}) (C,{tokens[1]})"))
        LC += 1

    elif mnemonic == "DS":
        INTERMEDIATE_CODE.append((LC, f"(DL,{opcode}) (C,{tokens[1]})"))
        LC += int(tokens[1])

    elif mnemonic == "EQU":
        if tokens[1] in SYMTAB and SYMTAB[tokens[1]] is not None:
            SYMTAB[label] = SYMTAB[tokens[1]]
        else:
            errors.add(f"Symbol not declared: {tokens[1]}")

    else:
        IC_line = f"(IS,{opcode})"

        for operand in tokens[1:]:

            # REGISTER
            if operand in REGISTERS:
                IC_line += f" (R,{REGISTERS[operand]})"

            # LITERAL
            elif is_literal(operand):
                lit_index = get_literal_index(operand)
                IC_line += f" (L,{lit_index})"

            # SYMBOL
            else:
                if operand not in SYMTAB:
                    SYMTAB[operand] = None
                    symbol_used[operand] = 0

                symbol_used[operand] += 1

                sym_index = list(SYMTAB.keys()).index(operand) + 1
                IC_line += f" (S,{sym_index})"

        INTERMEDIATE_CODE.append((LC, IC_line))
        LC += 1


# -------------------------------
# FINAL ERROR CHECKS
# -------------------------------
for sym, addr in SYMTAB.items():
    if addr is None:
        errors.add(f"Symbol not declared: {sym}")

for sym in SYMTAB:
    if symbol_used.get(sym, 0) == 0:
        errors.add(f"Warning: Symbol declared but not used: {sym}")


# -------------------------------
# OUTPUT
# -------------------------------
print("\n--- INTERMEDIATE CODE ---")
for line in INTERMEDIATE_CODE:
    print(line)

print("\n--- SYMBOL TABLE ---")
for i, (sym, addr) in enumerate(SYMTAB.items(), start=1):
    print(i, sym, addr)

print("\n--- LITERAL TABLE ---")
for i, (lit, addr) in enumerate(LITTAB, start=1):
    print(i, lit, addr)

print("\n--- POOL TABLE ---")
for i, val in enumerate(POOLTAB):
    print(i + 1, val)

print("\n--- ERRORS / WARNINGS ---")
for e in sorted(errors):
    print(e)