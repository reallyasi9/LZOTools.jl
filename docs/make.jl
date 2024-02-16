using LibLZO
using Documenter

DocMeta.setdocmeta!(LibLZO, :DocTestSetup, :(using LibLZO); recursive=true)

makedocs(;
    modules=[LibLZO],
    authors="Phil Killewald <reallyasi9@users.noreply.github.com> and contributors",
    sitename="LibLZO.jl",
    format=Documenter.HTML(;
        canonical="https://reallyasi9.github.io/LibLZO.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reallyasi9/LibLZO.jl",
    devbranch="main",
)
