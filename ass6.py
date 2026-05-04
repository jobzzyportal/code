def optimize(code):
    optimized = []

    for line in code:
        parts = line.split()

        # Format: t1 = a + 0
        if len(parts) == 5:
            lhs = parts[0]
            op1 = parts[2]
            operator = parts[3]
            op2 = parts[4]

            # 🔹 Constant Folding
            if op1.isdigit() and op2.isdigit():
                result = eval(op1 + operator + op2)
                optimized.append(f"{lhs} = {result}")

            # 🔹 Algebraic Simplification
            elif operator == '+' and op2 == '0':
                optimized.append(f"{lhs} = {op1}")

            elif operator == '+' and op1 == '0':
                optimized.append(f"{lhs} = {op2}")

            elif operator == '*' and op2 == '1':
                optimized.append(f"{lhs} = {op1}")

            elif operator == '*' and op1 == '1':
                optimized.append(f"{lhs} = {op2}")

            elif operator == '*' and (op1 == '0' or op2 == '0'):
                optimized.append(f"{lhs} = 0")

            else:
                optimized.append(line)

        else:
            optimized.append(line)

    return optimized


# -------------------------------
# MAIN
# -------------------------------
n = int(input("Enter number of TAC lines: "))
code = []

print("Enter TAC:")
for _ in range(n):
    code.append(input())

print("\n--- OPTIMIZED CODE ---")
result = optimize(code)

for line in result:
    print(line)
