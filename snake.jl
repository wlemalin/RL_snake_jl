include("LearningModule.jl")
include("InitialiseModule.jl")
include("Constantes.jl")
include("PlayModule.jl")
include("CommandModule.jl")

using .LearningModule
using .InitialiseModule
using ..InitialiseModule: GameState
using .Constantes
using .CommandModule
using .PlayModule
using Random
using Statistics

function update!(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, current_key::String, action::Int, q_update::Float64)

    q_table[current_key][1][action] = q_update
    q_table[current_key][2][action] += 1

end 

function egreedy_bandit(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, 
    state::GameState)   

    current_key = state_to_key(state)

    if !haskey(q_table, current_key)
    q_table[current_key] = (zeros(Float64, 4), zeros(Int, 4))  
    end

    action = choose_action(q_table, state)
    current_q = q_table[current_key][1][action] 

    q_update! = (reward) -> begin 
        q_update_value = current_q + ALPHA * (reward - current_q)  
        update!(q_table, current_key, action, q_update_value)        
    end

    return action, q_update!
end

function upperbound(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, 
    state::GameState)

    current_key = state_to_key(state)

    if !haskey(q_table, current_key)
    q_table[current_key] = (zeros(Float64, 4), zeros(Int, 4))  
    end

   action = argmax(q_table[current_key][1] .+ ALPHA * sqrt.(log.(q_table[current_key][2] .+ 1) ./ (q_table[current_key][2] .+ 1)))
    current_q = q_table[current_key][1][action] 
    
    q_update! = (reward) -> begin 
        q_update_value = current_q + ALPHA * (reward - current_q)  
        update!(q_table, current_key, action, q_update_value)           
    end

    return action, q_update!
end


function train_q_learning(episodes::Int; max_steps=1000, algorithm::Function=upperbound)
    q_table = load_q_table()
    episode_rewards = zeros(episodes)
    episode_lengths = zeros(Int, episodes)
    
    for episode in 1:episodes
        world, head_pos, body_positions, apple_pos = init_game()
        total_reward = 0
        steps = 0
        
        for step in 1:max_steps
            current_state = get_state(world, head_pos, apple_pos, body_positions)
            action, q_update! = algorithm(q_table, current_state)
            
            game_over, reward, new_apple_pos = step!(world, head_pos, 
                                                     body_positions, apple_pos, action)
            apple_pos = new_apple_pos
            
            q_reward = reward
            if game_over
                q_reward = -1.0
            end
            
            q_update!(q_reward)
            
            total_reward += reward
            steps += 1
            
            if game_over
                break
            end
        end
        
        episode_rewards[episode] = total_reward
        episode_lengths[episode] = steps
        
        if episode % 50000 == 0
            println("Episode $episode: Reward = $total_reward, Steps = $steps")
            # Save periodically during training
            save_q_table(q_table)
        end
    end
    
    # Save final Q-table
    save_q_table(q_table)
    
    return q_table, episode_rewards, episode_lengths
end


# Main function to handle training or playing
"""
Main function to control the training or loading of the Q-table and playing a game.

This function either trains the agent for a given number of episodes or loads an existing Q-table to 
play a game. After training or loading, it runs a single game using the current policy and prints 
the state of the game.

Args:
    episodes (Int, optional): The number of episodes for training. Default is 1000.
    train (Bool, optional): Whether to train a new model or load an existing one. Default is true.

Returns:
    q_table (Dict{String, Vector{Float64}}): The Q-table after training or loading.
    rewards (Vector{Float64}): The total rewards obtained during training.
    lengths (Vector{Int}): The number of steps taken during training.
"""
function main(; episodes=1000, train=true)
    if train
        println("Starting/Continuing training...")
        q_table, rewards, lengths = train_q_learning(episodes)
    else
        println("Loading existing Q-table for play...")
        q_table = load_q_table()
        rewards = []
        lengths = []
    end
    
    println("\nPlaying a game with current policy...")
    world, head_pos, body_positions, apple_pos = init_game()
    println("Initial state:")
    print_world(world)
    println("\nStarting game...")
    play_trained_game!(q_table, world, head_pos, body_positions, apple_pos)
    
    return q_table, rewards, lengths
end


# Run the entire program
"""
Run the program by parsing arguments and then either training the agent or loading an existing Q-table.

This function reads the command-line arguments to determine whether to train the agent or use an 
existing Q-table. It then calls the `main()` function to either train or play the game.

Returns:
    q_table (Dict{String, Vector{Float64}}): The Q-table after training or loading.
    rewards (Vector{Float64}): The total rewards obtained during training.
    lengths (Vector{Int}): The number of steps taken during training.
"""
function run_program()
    train, episodes = parse_arguments()
    q_table, rewards, lengths = main(episodes=episodes, train=train)
    return q_table, rewards, lengths
end


# Execute the program
"""
Execute the full Snake game program, including training or loading, and playing a game.

This section runs the entire Snake program by calling `run_program()`. It trains the agent or loads 
an existing Q-table, and then plays a single game with the learned policy. Finally, it prints the 
rewards and episode lengths.

"""
q_table, rewards, lengths = run_program()
println(rewards, lengths)

