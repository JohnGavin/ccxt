
# https://mlabonne.github.io/blog/constraintprogramming/


from ortools.sat.python import cp_model

# Instantiate model and solver
model = cp_model.CpModel()
solver = cp_model.CpSolver()

army = model.NewIntVar(1, 10000, 'army')

# variable % mod = target → (target, variable, mod)
model.AddModuloEquality(0, army, 13)
model.AddModuloEquality(0, army, 19)
model.AddModuloEquality(0, army, 37)

status = solver.Solve(model)

# If a solution has been found, print results
if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
    print('================= Solution =================')
    print(f'Solved in {solver.WallTime():.2f} milliseconds')
    print()
    print(f'🪖 Army = {solver.Value(army)}')
    print()
    print('Check solution:')
    print(f' - Constraint 1: {solver.Value(army)} % 13 = {solver.Value(army) % 13}')
    print(f' - Constraint 2: {solver.Value(army)} % 19 = {solver.Value(army) % 19}')
    print(f' - Constraint 3: {solver.Value(army)} % 37 = {solver.Value(army) % 37}')

else:
    print('The solver could not find a solution.')




model = cp_model.CpModel()
solver = cp_model.CpSolver()

# 1. Variable
army = model.NewIntVar(1, 100000, 'army')

# 2. Constraints
model.AddModuloEquality(0, army, 13)
model.AddModuloEquality(0, army, 19)
model.AddModuloEquality(0, army, 37)


class PrintSolutions(cp_model.CpSolverSolutionCallback):
    """Callback to print every solution."""

    def __init__(self, variable):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self.__variable = variable

    def on_solution_callback(self):
        print(self.Value(self.__variable))

# Solve with callback
solution_printer = PrintSolutions(army)
solver.parameters.enumerate_all_solutions = True
status = solver.Solve(model, solution_printer)

model = cp_model.CpModel()
solver = cp_model.CpSolver()

# 1. Variables
capacity = 19
bread = model.NewIntVar(0, capacity, 'bread')
meat  = model.NewIntVar(0, capacity, 'meat')
beer  = model.NewIntVar(0, capacity, 'beer')

model.Add(1 * bread
        + 3 * meat 
        + 7 * beer <= capacity)

model.Maximize(3  * bread
             + 10 * meat
             + 26 * beer)

status = solver.Solve(model)

# If an optimal solution has been found, print results
if status == cp_model.OPTIMAL:
    print('================= Solution =================')
    print(f'Solved in {solver.WallTime():.2f} milliseconds')
    print()
    print(f'Optimal value = {3*solver.Value(bread)+10*solver.Value(meat)+26*solver.Value(beer)} popularity')
    print('Food:')
    print(f' - 🥖Bread = {solver.Value(bread)}')
    print(f' - 🥩Meat  = {solver.Value(meat)}')
    print(f' - 🍺Beer  = {solver.Value(beer)}')
else:
    print('The solver could not find an optimal solution.')



class CountSolutions(cp_model.CpSolverSolutionCallback):
    """Count the number of solutions."""

    def __init__(self):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self.__solution_count = 0

    def on_solution_callback(self):
        self.__solution_count += 1

    def solution_count(self):
        return self.__solution_count

solution_printer = CountSolutions()

# Instantiate model and solver
model = cp_model.CpModel()
solver = cp_model.CpSolver()

# 1. Variables
capacity = 19

bread = model.NewIntVar(0, capacity, 'Bread')
meat  = model.NewIntVar(0, capacity, 'Meat')
beer  = model.NewIntVar(0, capacity, 'Beer')

# 2. Constraints
model.Add(1 * bread
        + 3 * meat 
        + 7 * beer <= capacity)

# Print results
solver.parameters.enumerate_all_solutions = True
status = solver.Solve(model, solution_printer)
print(solution_printer.solution_count())
