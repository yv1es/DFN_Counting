using Test
using Random: bitrand

"""
Given a DNF Formula F = C₁ ∨ C₂ ∨ … ∨ Cₘ where m is the number of clauses
and Cᵢ = L₁ ∧ L₂ ∧ … ∧ Lᵣ where r is the number of literals in clause Cᵢ
and each Literal Lⱼ is equal to a boolen vairable Xₖ or its negation ̄Xₖ

This program will approximate the number of different satisfying assignments #F for the Formula F 

The Approximation A(F) will meet following guarante:

P[ (1-ϵ)#F ≤ A(F) ≤ (1+ϵ)#F ] ≥ 1 - δ


The relative tolerance ϵ and 
the max. error probability δ 
are parameters of the algorithm. 

The formula is represented as a 2d array of integeres. 
A subarray represents a clause. 
The literal Xₖ is represented by k and its negation ̄Xₖ by -k
We assume that the indexing of the literals/variables begins at 1 and uses successife integers. 

An assignment a is represented by a bit array. 

Below are listed some examples that can be used for testing 
"""

# F₁ = (X₁ ∧ X₂ ∧ X₃) ∨ (X₁ ∧ ̄X₂) ∨ (X₂ ∧ X₃)
F₁ = [[1, 2, 3], [1, -2], [2, 3]] 

# F₂ = (̄X₁ ∧ X₂ ∧ ̄X₃) ∨ (̄X₄ ∧ X₂ ∧ X₁) ∨ (X₂ ∧ X₃)
F₂ = [[-1, 2, -3], [-4, 2, 1], [2, 3]] 

# F₃ = (X₁ ∧ X₂) ∨ (̄X₂)
F₃ = [[1, 2], [-2]] 


# example assignments
a₁ = [0, 0, 0, 0]
a₂ = [1, 0, 1, 0]
a₃ = [1, 1, 0, 0]
a₄ = [0, 0, 1, 1]
a₅ = [1, 1, 1, 1]


"""
The number of variables in the Formula F 
"""
get_n(F) = maximum((x -> maximum(abs, x)), F)

"""
The number of clauses in F 
"""
get_m(F) = length(F)

"""
Evaluate F(a) in linear time 
"""
function eval(F, a)
    for C in F      # try to find a satisfied clause
        if evalClause(C, a) 
            return true
        end
    end
    return false    
end

"""
Evaluate C(a)
"""
function evalClause(C, a)
    violated_C = false
    for L in C
        if a[abs(L)] != 1 - (L < 0)
            return false # literal L violated hence the clause C is not satisfied
        end
    end  
    return true
end


"""
Compute the number of satisfying assignment by exhaustive enumeration. (Exponential Runtime) 
"""
function exhaustiveEnumeration(F)
    n = get_n(F)
    sat_F = 0
    for i in 0:2^n-1 
        a = digits(i, base=2, pad=n)
        if eval(F, a)
            sat_F += 1
        end
    end
    return sat_F
end


"""
Run the Monte Carlo Approximation algorithm
"""
function approx(F, ϵ, δ)
    N = ceil(4 / ϵ^2 * log(2/δ) * get_m(F))
    n = get_n(F)
    m = get_m(F)
    clause_length = map(length, F) # comptue the length of each clause 
    
    clause_sat_assignments = map(x -> 2^(n-x), clause_length) 
    p = clause_sat_assignments / sum(clause_sat_assignments)  # comptue the probability for each clause to be drawn 
    p_sum = p           # p_sum makes it easyer to draw a clause according to the probabilities 
    for i in 2:m
        p_sum[i] += p_sum[i-1]
    end 

    # Monte Carlo
    S = 0
    U = sum(clause_sat_assignments)

    for i in 1:N
        
        # draw a clause with probabilities proportional to the number of satisfying assignments 
        random = rand()
        j = 1       
        while random > p_sum[j]
            j += 1
        end
        
        # generate uniformly at random a satisfying assignment for the j-th clause
        a = bitrand(n)
        for l in F[j]
            a[abs(l)] = 1 - (l < 0)
        end 

        # check if there is earlyer clause also satisfied by a 
        canonical = true    
        for k in 1:(j-1)
            if evalClause(F[k], a)
                canonical = false   
                break
            end
        end
        if canonical
            S += 1
        end
    end
    sat = (S/N) * U
    return sat
end



"""
Generate a random DNF formula
"""
function randomF(n, m)
    rand(1:n)
    F = Array[]
    for i in 1:m
        C = Int64[]
        for j in 1:rand(1:n)
            x = rand(-n:n)
            if !(x in C || -x in C) && x != 0
                append!(C, x)
            end 
        end
        if length(C) != 0
            append!(F, [C])
        end
    end
    return F
end




# Demo 
F = randomF(20, 10)

println("Running exhaustiveEnumeration")
determinitic = exhaustiveEnumeration(F)

ϵ = 0.01
δ = 0.01
println("Running approx")
approximation = approx(F, ϵ, δ)

Δₐ= abs(determinitic - approximation)
Δᵣ = Δₐ / determinitic

println("Determinitic: $determinitic   Approximation: $approximation   Δₐ=$Δₐ  Δᵣ=$Δᵣ")