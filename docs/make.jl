using maxBESS
using Documenter

makedocs(;
    modules=[maxBESS],
    authors="Abraham Alvarez Bustos",
    repo="https://github.com/AbrahamAlvarezB/maxBESS.jl.git/blob/{commit}{path}#{line}",
    sitename="maxBESS.jl",
    format=Documenter.HTML(; prettyurls=false),
    pages=[
        "Home" => "index.md",
        "API" => map(
            p -> first(p) => joinpath("api", last(p)),
            [
                "Formulation Templates" => "templates.md",
                "Modelling" => "modelling.md",
            ]
        ),
    ],
    strict=true,
    checkdocs=:exports
)
