module LearningModule

export init_q_table, load_q_table, save_q_table
  
# Training function
using Serialization

# File path for saving Q-table
const Q_TABLE_FILE = "snake_q_table.jls"

# Initialize Q-table
function init_q_table()
    return Dict{String, Vector{Float64}}()
end

# Function to save Q-table
function save_q_table(q_table::Dict{String, Vector{Float64}})
    open(Q_TABLE_FILE, "w") do io
        serialize(io, q_table)
    end
    println("Q-table saved to $Q_TABLE_FILE")
end

# Function to load Q-table
function load_q_table()
    if isfile(Q_TABLE_FILE)
        q_table = open(deserialize, Q_TABLE_FILE)
        println("Loaded existing Q-table from $Q_TABLE_FILE")
        return q_table
    else
        println("No existing Q-table found. Starting fresh.")
        return init_q_table()
    end
end

end
