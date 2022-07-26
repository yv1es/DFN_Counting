using Test

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


# parameters
ϵ = 0.01
δ = 0.01



"""
The number of variables in the Formula F 
"""
get_n(F) = maximum((x -> maximum(abs, x)), F)



"""
Evaluate F(a) in linear time 
"""
function eval(F, a)
    for C in F      # try to find a satisfied clause
        violated_C = false
        for L in C
            if a[abs(L)] != 1 - (L < 0)
                violated_C = true 
                break  # literal L violated hence the clause C is not satisfied
            end
        end  
        if !violated_C 
            return true  # no violatoin in clause C hence F is satisfied
        end
    end
    return false    
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



