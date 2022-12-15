function obj_raw_profits! end

function latex(::typeof(obj_raw_profits!))
    return """
    ``\\sum_{t \\in \\mathcal{T}} [ \\sum_{m \\in \\mathcal{M}} [ \\Lambda_{m, t} ( pd_{m, t} - pc_{m, t} )] \\tau]``
    """
end

"""
    obj_raw_profits!(model::Model, expr)

Adds the expression `expr` to the current objective of `model`.
"""
function obj_raw_profits!(model::Model, price, datetimes, markets)
    # Get variables
    pd = model[:pd]
    pc = model[:pc]
    ex = @expression(
        model,
        raw_profits,
        sum(price[m, t] * (pd[m, t] - pc[m, t]) for (m, t) in (markets, datetimes))
    )
    @objective(model, Max, ex)
    objective_function(model)
    return model
end
