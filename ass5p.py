temp_count = 1

def new_temp():
    global temp_count
    t = f"t{temp_count}"
    temp_count += 1
    return t

def generate_tac(expr):
    expr = list(expr)

    # Handle * and /
    i = 0
    while i < len(expr):
        if expr[i] in ['*', '/']:
            op = expr[i]
            t = new_temp()
            print(f"{t} = {expr[i-1]} {op} {expr[i+1]}")
            expr[i-1:i+2] = [t]
            i = 0
        else:
            i += 1

    # Handle + and -
    i = 0
    while i < len(expr):
        if expr[i] in ['+', '-']:
            op = expr[i]
            t = new_temp()
            print(f"{t} = {expr[i-1]} {op} {expr[i+1]}")
            expr[i-1:i+2] = [t]
            i = 0
        else:
            i += 1

expr = input("Enter expression: ")
generate_tac(expr)
