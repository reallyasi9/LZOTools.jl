using LZOTools
using Documenter

DocMeta.setdocmeta!(LZOTools, :DocTestSetup, :(using LZOTools); recursive=true)

makedocs(;
    modules=[LZOTools],
    authors="Phil Killewald <reallyasi9@users.noreply.github.com> and contributors",
    sitename="LZOTools.jl",
    format=Documenter.HTML(;
        canonical="https://reallyasi9.github.io/LZOTools.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reallyasi9/LZOTools.jl",
    devbranch="main",
)
