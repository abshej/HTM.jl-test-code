#=
This file contains the constants and other parameters
=#

# default synaptic permanence value
DefaultPerm = Nullable{Float16}(0.2)

# threshold permanence value for connection
ConnectedPerm = Nullable{Float16}(0.4)

# default synaptic activation threshold for distal segment
MinActiveDistalSynapses = Nullable{Int}()

# default synaptic activation threshold for apical segment
MinActiveApicalSynapses = Nullable{Int}()

# sparsity of network
SparsityCount = Nullable{Int}(200)

# no. of neurons per minicolumn
NeuronsPerMinicolumn = Nullable{Int}(32)

# width of minicolumn layer
WidthOfLayer = Nullable{Int}(45)

# breadth of minicolumn layer
BreadthOfLayer = Nullable{Int}(45)

# no. of minicolumns in layer
NoOfMinicolumns = Nullable{Int}((WidthOfLayer.value * BreadthOfLayer.value))

# default dimension of minicolumn layer (1 OR 2)
DefaultLayerDim = 1

# topology toggle for connections map
TopographicMaps = false
