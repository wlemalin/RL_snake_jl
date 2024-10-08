include("LearningModule.jl")
include("InitialiseModule.jl")
include("Constantes.jl")
include("PlayModule.jl")

using .LearningModule
using .InitialiseModule
using ..InitialiseModule: GameState
using .Constantes
using .PlayModule
using Random
using Statistics


# Update Q-table
function update_q_table!(q_table::Dict{String, Vector{Float64}}, 
                        state::GameState, action::Int, 
                        reward::Any, next_state::GameState)
    current_key = state_to_key(state)
    next_key = state_to_key(next_state)
    
    if !haskey(q_table, current_key)
        q_table[current_key] = zeros(4)
    end
    if !haskey(q_table, next_key)
        q_table[next_key] = zeros(4)
    end
    
    current_q = q_table[current_key][action]
    next_max_q = maximum(q_table[next_key])
    
    q_table[current_key][action] = current_q + 
                                   ALPHA * (reward + GAMMA * next_max_q - current_q)
end


# Modify train_q_learning to use existing Q-table
function train_q_learning(episodes::Int; max_steps=200)
    q_table = load_q_table()
    episode_rewards = zeros(episodes)
    episode_lengths = zeros(Int, episodes)
    
    for episode in 1:episodes
        world, head_pos, body_positions, apple_pos = init_game()
        total_reward = 0
        steps = 0
        
        for step in 1:max_steps
            current_state = get_state(world, head_pos, apple_pos, body_positions)
            action = choose_action(q_table, current_state)
            
            game_over, reward, new_apple_pos = step!(world, head_pos, 
                                                     body_positions, apple_pos, action)
            apple_pos = new_apple_pos
            
            next_state = get_state(world, head_pos, apple_pos, body_positions)
            
            q_reward = reward
            if game_over
                q_reward = -1.0
            end
            
            update_q_table!(q_table, current_state, action, q_reward, next_state)
            
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
#
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

# Add command line argument handling
function parse_arguments()
    if length(ARGS) > 0
        if ARGS[1] == "train"
            episodes = length(ARGS) > 1 ? parse(Int, ARGS[2]) : 1000
            return true, episodes
        elseif ARGS[1] == "play"
            return false, 0
        end
    end
    return true, 1000  # default behavior
end

# Run the program
function run_program()
    train, episodes = parse_arguments()
    q_table, rewards, lengths = main(episodes=episodes, train=train)
    return q_table, rewards, lengths
end

# Execute
q_table, rewards, lengths = run_program()
println(rewards, lengths)
