include("Layers.jl")

function displayPredictive(lyr::LYR)
    display = zeros(length(lyr.mncs), length(lyr.mncs[1].nrns))
    for i in poolPredictiveNeurons(lyr)
        display[i[1], i[2]] = 1
    end
    println(display)
end

