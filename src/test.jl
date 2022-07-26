
include("dnf_count.jl")

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


@testset "numberOfVars" begin
    @test get_n(F₁) == 3
    @test get_n(F₂) == 4
    @test get_n(F₃) == 2
end


@testset "eval" begin
    @test eval(F₁, a₁) == false
    @test eval(F₁, a₂) == true
    @test eval(F₁, a₃) == false
    @test eval(F₁, a₄) == false
    @test eval(F₁, a₅) == true
end


@testset "exhaustiveEnumeration" begin
    @test exhaustiveEnumeration(F₁) == 4
    @test exhaustiveEnumeration(F₂) == 7
    @test exhaustiveEnumeration(F₃) == 3
end