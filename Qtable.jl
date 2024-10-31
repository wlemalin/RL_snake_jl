module Qtable

include("HyperParameters.jl")
using .HyperParameters: FILENAME

using Serialization 

export save_q_table, load_q_table

const FILE = join(["q_tables", FILENAME], "/") * ".jls"

# Function to save Q-table
function save_q_table(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, file=FILE) 
    open(file, "w") do io
        serialize(io, q_table)
    end
    println("Q-table saved to $FILE")
end

# Function to load Q-table
function load_q_table()
    if isfile(FILE)
        q_table = open(deserialize, FILE)
        println("Loaded existing Q-table from $FILE")
        return q_table
    else
        println("No existing Q-table found. Starting fresh.")
        return Dict{String, Tuple{Vector{Float64}, Vector{Int}}}()
    end
end

end