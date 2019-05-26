include("Creation.jl")
include("Core.jl")

function test1()
    sparsemaker = [false, false, false, false, false, false, false, false, false, false, false, false, false, true]
    l = layer(2048, 10);
    @time addProximalDendrites!(l, 20480)
    @time randProximalSynapses!(l, 20480)
    i1 = rand(sparsemaker, 20480)
    i2 = rand(sparsemaker, 20480)
    i3 = rand(sparsemaker, 20480)
    print_with_color(:green, "Three random inputs created: ")
    println(sum.((i1, i2, i3)))
    @time p1 = proximalActivation(l, i1)
    @time p2 = proximalActivation(l, i2)
    @time p3 = proximalActivation(l, i3)

    for i in 1:10
        @time d1 = distalActivation(l, p1)
        println("Prediction accuracy: ", length(sum(intersect(d1, p2)))/length(p2.nzind))
        @time distalUpdate!(l, p1, d1, p2)
        @time d2 = distalActivation(l, p2)
        println("Prediction accuracy: ", length(sum(intersect(d2, p3)))/length(p3.nzind))
        @time distalUpdate!(l, p2, d2, p3)
        @time d3 = distalActivation(l, p3)
        println("Prediction accuracy: ", length(sum(intersect(d3, p1)))/length(p1.nzind))
        @time distalUpdate!(l, p3, d3, p1)
    end
    
    nothing
end

test1()
