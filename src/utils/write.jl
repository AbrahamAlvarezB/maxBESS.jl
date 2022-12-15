@doc raw"""
    FullNetworkModels.latex(::Function) -> String

An internal function which returns the mathematical formation for the given function in
valid [LaTeX](https://en.wikipedia.org/wiki/LaTeX).

Should be consistent with the [notation](@ref) used throughout the package.

Mostly used to generate docstrings.
"""
function latex end

function _write_formulation(; objectives, constraints, variables)
    obj = _write_objective(objectives)
    exprs = join(vcat(constraints, variables), "\n")
    formulation = obj * "\n\nsubject to:\n\n" * exprs * "\n"
    return formulation
end

function _write_objective(exprs)
    # Open math mode and add minimization symbol
    obj = "``\\max"
    is_first = true
    for expr in exprs
        str = _extract_expression(expr)
        # If it's not the first expression and it doesn't start with a plus/minus sign,
        # add a plus sign
        if !is_first && !startswith(str, "+") && !startswith(str, "-")
            str = " + " * str
        else
            str = " " * str
        end
        obj = obj * str
        is_first = false
    end
    # Close math mode
    obj = obj * "``"
    return obj
end

function _extract_expression(expr)
    return string(first(split(expr, '`'; keepempty=false)))
end
