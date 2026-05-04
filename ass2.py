# # -------------------------------
# # TWO PASS MACRO PROCESSOR (FINAL WORKING)
# # -------------------------------

# MNT = {}
# MDT = []

# intermediate_code = []
# expanded_code = []


# # -------------------------------
# # READ FILE
# # -------------------------------
# with open("ass2.asm", "r") as f:
#     lines = [line.strip() for line in f if line.strip()]


# # -------------------------------
# # PASS 1 → STORE MACROS
# # -------------------------------
# i = 0
# while i < len(lines):

#     if lines[i] == "MACRO":
#         i += 1
#         header = lines[i].split()

#         macro_name = header[0]

#         params = []
#         if len(header) > 1:
#             params = [p.strip() for p in " ".join(header[1:]).split(",")]

#         # Store in MNT
#         MNT[macro_name] = (len(MDT), len(params))

#         # ALA (formal → positional)
#         ala = {params[j]: f"#{j+1}" for j in range(len(params))}

#         i += 1

#         # Store macro body
#         while lines[i] != "MEND":
#             tokens = lines[i].split()
#             new_tokens = [tokens[0]]

#             for t in tokens[1:]:
#                 if t in ala:
#                     new_tokens.append(ala[t])
#                 else:
#                     new_tokens.append(t)

#             MDT.append(" ".join(new_tokens))
#             i += 1

#         MDT.append("MEND")

#     else:
#         intermediate_code.append(lines[i])

#     i += 1


# # -------------------------------
# # FUNCTION: EXPAND MACRO (FIXED)
# # -------------------------------
# def expand_macro(name, actual_params):
#     result = []

#     # Create mapping (#1 → actual)
#     ala = {f"#{i+1}": actual_params[i] for i in range(len(actual_params))}

#     idx = MNT[name][0]

#     while MDT[idx] != "MEND":
#         parts = MDT[idx].split()
#         op = parts[0]

#         # Replace parameters FIRST
#         replaced = []
#         for token in parts[1:]:
#             if token.startswith("#") and token in ala:
#                 replaced.append(ala[token])
#             else:
#                 replaced.append(token)

#         # If nested macro → pass FULL replaced params
#         if op in MNT:
#             result.extend(expand_macro(op, replaced))
#         else:
#             if replaced:
#                 result.append(op + " " + " ".join(replaced))
#             else:
#                 result.append(op)

#         idx += 1

#     return result


# # -------------------------------
# # PASS 2 → EXPANSION
# # -------------------------------
# for line in intermediate_code:
#     tokens = line.split()

#     if tokens[0] in MNT:
#         macro = tokens[0]

#         actual_params = []
#         if len(tokens) > 1:
#             actual_params = [x.strip() for x in tokens[1].split(",")]

#         expanded_code.extend(expand_macro(macro, actual_params))
#     else:
#         expanded_code.append(line)


# # -------------------------------
# # OUTPUT
# # -------------------------------
# print("\n--- MNT ---")
# for k, v in MNT.items():
#     print(k, "->", v)

# print("\n--- MDT ---")
# for i, line in enumerate(MDT):
#     print(i, line)

# print("\n--- INTERMEDIATE CODE ---")
# for line in intermediate_code:
#     print(line)

# print("\n--- EXPANDED CODE ---")
# for line in expanded_code:
#     print(line)

# -------------------------------
# TWO PASS MACRO PROCESSOR (FIXED)
# -------------------------------

MNT = {}
MDT = []

intermediate_code = []
expanded_code = []

# -------------------------------
# READ FILE
# -------------------------------
with open("ass2.asm", "r") as f:
    lines = [line.strip() for line in f if line.strip()]

# -------------------------------
# PASS 1 → STORE MACROS
# -------------------------------
i = 0
while i < len(lines):

    if lines[i] == "MACRO":
        i += 1
        header = lines[i].split()

        macro_name = header[0]

        params = []
        if len(header) > 1:
            params = [p.strip() for p in " ".join(header[1:]).split(",")]

        # Store in MNT: (MDT start index, param count)
        MNT[macro_name] = (len(MDT), len(params))

        # ALA (formal → positional): &ARG → #1, &A1 → #1, etc.
        ala = {params[j]: f"#{j+1}" for j in range(len(params))}

        i += 1

        # Store macro body with positional placeholders
        while lines[i] != "MEND":
            tokens = lines[i].split()
            new_tokens = [tokens[0]]

            for t in tokens[1:]:
                # Handle comma-separated params on same token
                parts = [x.strip() for x in t.split(",")]
                replaced = []
                for p in parts:
                    if p in ala:
                        replaced.append(ala[p])
                    else:
                        replaced.append(p)
                new_tokens.append(",".join(replaced))

            MDT.append(" ".join(new_tokens))
            i += 1

        MDT.append("MEND")

    else:
        intermediate_code.append(lines[i])

    i += 1


# -------------------------------
# FUNCTION: EXPAND MACRO (FIXED)
# -------------------------------
def expand_macro(name, actual_params):
    result = []

    # Build mapping: #1 → actual[0], #2 → actual[1], ...
    ala = {f"#{i+1}": actual_params[i] for i in range(len(actual_params))}

    idx = MNT[name][0]

    while MDT[idx] != "MEND":
        parts = MDT[idx].split()
        op = parts[0]

        # Replace positional params in each token
        replaced = []
        for token in parts[1:]:
            # Replace #N with actual value
            if token in ala:
                replaced.append(ala[token])
            else:
                replaced.append(token)

        # If nested macro call → expand it recursively
        if op in MNT:
            # Pass already-substituted actual params to nested macro
            result.extend(expand_macro(op, replaced))
        else:
            if replaced:
                result.append(op + " " + " ".join(replaced))
            else:
                result.append(op)

        idx += 1

    return result


# -------------------------------
# PASS 2 → EXPANSION
# -------------------------------
for line in intermediate_code:
    tokens = line.split()

    if tokens[0] in MNT:
        macro = tokens[0]

        actual_params = []
        if len(tokens) > 1:
            actual_params = [x.strip() for x in " ".join(tokens[1:]).split(",")]

        expanded_code.extend(expand_macro(macro, actual_params))
    else:
        expanded_code.append(line)


# -------------------------------
# OUTPUT
# -------------------------------
print("\n--- MNT (Macro Name Table) ---")
print(f"{'Name':<10} {'MDT Index':<12} {'Param Count'}")
for k, v in MNT.items():
    print(f"{k:<10} {v[0]:<12} {v[1]}")

print("\n--- MDT (Macro Definition Table) ---")
print(f"{'Index':<8} {'Line'}")
for i, line in enumerate(MDT):
    print(f"{i:<8} {line}")

print("\n--- INTERMEDIATE CODE ---")
for line in intermediate_code:
    print(line)

print("\n--- EXPANDED CODE ---")
for line in expanded_code:
    print(line)