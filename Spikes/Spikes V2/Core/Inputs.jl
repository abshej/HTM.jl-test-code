include("Units.jl")

function randProximalSyns!(layer::LYR, inpLen::Int, N::Int=1)
    if inpLen < (length(layer.mncs) * length(layer.mncs[1].nrns))
        allInds = collect(1:inpLen)
        append!(allInds, rand(1:inpLen, (length(layer.mncs) * length(layer.mncs[1].nrns))-inpLen))
    else
        allInds = collect(1:inpLen)
    end
    totalInds = copy(allInds)
    for col in eachindex(layer.mncs)
        for nrn in eachindex(layer.mncs[col].nrns)
            if length(layer.mncs[col].nrns[nrn].proximal) == 0
                push!(layer.mncs[col].nrns[nrn].proximal, DEN([]))
            end
            indHolder = rand(allInds)
            push!(layer.mncs[col].nrns[nrn].proximal[end].syns, SYN((indHolder,), Float16(0.5)))
            for i in 1:N-1
                push!(layer.mncs[col].nrns[nrn].proximal[end].syns, SYN((rand(totalInds),), Float16(0.5)))
            end
            splice!(allInds, findin(allInds, indHolder)[1])
        end
    end
end

function randProximalSynsCommon!(layer::LYR, inpLen::Int, N::Int=1)
    if inpLen < length(layer.mncs)
        allInds = collect(1:inpLen)
        append!(allInds, rand(1:inpLen, length(layer.mncs)-inpLen))
    else
        allInds = collect(1:inpLen)
    end
    totalInds = copy(allInds)
    for col in eachindex(layer.mncs)
        indHolder = rand(allInds)
        for nrn in eachindex(layer.mncs[col].nrns)
            if length(layer.mncs[col].nrns[nrn].proximal) == 0
                push!(layer.mncs[col].nrns[nrn].proximal, DEN([]))
            end
            push!(layer.mncs[col].nrns[nrn].proximal[end].syns, SYN((indHolder,), Float16(1.0)))
            for i in 1:N-1
                push!(layer.mncs[col].nrns[nrn].proximal[end].syns, SYN((rand(totalInds),), Float16(0.5)))
            end
        end
        splice!(allInds, findin(allInds, indHolder)[1])
    end
end
