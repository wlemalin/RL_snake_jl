using Random

# Constants
const EMPTY = 0
const WALL = -1
const APPLE = 1
const SNAKE_BODY = 2
const SNAKE_HEAD = 3
const PADDING = 3
const GRID_SIZE = 10 + 2* PADDING # 10x10 playable area + 2 walls on each side
const VIEW_RANGE = 2


# Q-learning parameters
const EPSILON = 0.0000003  # Exploration rate
const ALPHA = 0.04   # Learning rate
const GAMMA = 0.825   # Discount factor

# Define a struct for game state
struct GameState
    vision::Matrix{Int}  # The 5x5 grid around the snake's head
    apple_relative_pos::Tuple{Int, Int}  # Relative position of apple to head
    length::Int  # Current length of snake
end

# Initialize the game world
function init_world()
    # Create grid with walls
    world = fill(WALL, (GRID_SIZE, GRID_SIZE))
    
    # Create playable area
    for i in PADDING+1:GRID_SIZE-PADDING
        for j in PADDING+1:GRID_SIZE-PADDING
            world[i, j] = EMPTY
        end
    end
    
    return world
end

# Initialize snake
function init_snake()
    # Start at the center of the playable area
    head_pos = [GRID_SIZE ÷ 2, GRID_SIZE ÷ 2]
    # Snake starts horizontally, length 3
    body_positions = [
        [head_pos[1], head_pos[2] - 1],
        [head_pos[1], head_pos[2] - 2]
    ]
    
    return head_pos, body_positions
end

# Place snake in the world
function place_snake!(world, head_pos, body_positions)
    world[head_pos[1], head_pos[2]] = SNAKE_HEAD
    for pos in body_positions
        world[pos[1], pos[2]] = SNAKE_BODY
    end
end

# Place apple in the world and return its position
function place_apple!(world)
    empty_positions = [(i, j) for i in 1:GRID_SIZE, j in 1:GRID_SIZE if world[i, j] == EMPTY]
    if !isempty(empty_positions)
        apple_pos = rand(empty_positions)
        world[apple_pos[1], apple_pos[2]] = APPLE
        return apple_pos
    end
    return nothing
end

# Get the enhanced game state
function get_state(world, head_pos, apple_pos, body_positions)
    # Get vision matrix
    vision = zeros(Int, 2*VIEW_RANGE+1, 2*VIEW_RANGE+1)
    for i in -VIEW_RANGE:VIEW_RANGE
        for j in -VIEW_RANGE:VIEW_RANGE
            y, x = head_pos[1] + i, head_pos[2] + j
            vision[i+VIEW_RANGE+1, j+VIEW_RANGE+1] = world[y, x]
        end
    end
    
    # Calculate relative apple position
    apple_relative_pos = (apple_pos[2] - head_pos[2], head_pos[1] - apple_pos[1])
    
    # Create and return GameState
    return GameState(
        vision,
        apple_relative_pos,
        length(body_positions) + 1  # +1 for the head
    )
end

# Pretty print the world
function print_world(world)
    symbols = Dict(
        EMPTY => "·",
        WALL => "#",
        APPLE => "🍎",
        SNAKE_BODY => "*",
        SNAKE_HEAD => "🐸"
    )
    
    for i in 1:GRID_SIZE
        for j in 1:GRID_SIZE
            print(symbols[world[i, j]], " ")
        end
        println()
    end
end

# Initialize game
function init_game()
    world = init_world()
    head_pos, body_positions = init_snake()
    place_snake!(world, head_pos, body_positions)
    apple_pos = place_apple!(world)
    
    return world, head_pos, body_positions, apple_pos
end
#
#



# Add these constants for actions
const UP = 1
const RIGHT = 2
const DOWN = 3
const LEFT = 4

# Get direction vector from action
function action_to_direction(action)
    if action == UP
        return (0, 1)
    elseif action == RIGHT
        return (1, 0)
    elseif action == DOWN
        return (0, -1)
    else  # LEFT
        return (-1, 0)
    end
end

# Move snake and update game state
function step!(world, head_pos, body_positions, apple_pos, action)
    dy, dx = action_to_direction(action)
    new_head = [head_pos[1] + dy, head_pos[2] + dx]
    
    # Check collision with wall or body
    if world[new_head[1], new_head[2]] == WALL || 
       world[new_head[1], new_head[2]] == SNAKE_BODY
        return true, -1, apple_pos  # Game over
    end
    
    # Check if apple is eaten
    apple_eaten = (new_head[1], new_head[2]) == apple_pos
    score = apple_eaten ? 1 : 0
    
    # Update snake positions
    world[head_pos[1], head_pos[2]] = SNAKE_BODY
    pushfirst!(body_positions, copy(head_pos))
    
    if !apple_eaten
        # Remove tail if apple not eaten
        tail = pop!(body_positions)
        world[tail[1], tail[2]] = EMPTY
    end
    
    # Update head
    head_pos[1], head_pos[2] = new_head
    world[head_pos[1], head_pos[2]] = SNAKE_HEAD
    
    # Place new apple if eaten
    if apple_eaten
        apple_pos = place_apple!(world)
    end
    
    return false, score, apple_pos
end

# Random action selection
function random_action()
    return rand(1:4)
end

# Main game loop for testing
function play_game!(world, head_pos, body_positions, apple_pos; max_steps=200)
    total_score = 0
    
    for step in 1:max_steps
        # Get current state
        state = get_state(world, head_pos, apple_pos, body_positions)
        
        # Choose action
        action = random_action()
        
        # Take step
        game_over, score, new_apple_pos = step!(world, head_pos, body_positions, apple_pos, action)
        apple_pos = new_apple_pos
        total_score += score
        
        # Optional: Print game state
        println("\nStep $step, Action: $action")
        print_world(world)
        println("Score: $total_score")
        
        if game_over
            println("Game Over! Final score: $total_score")
            break
        end
        
        sleep(0.3)  # Slow down for visibility
    end
    return total_score
end



using Statistics


# Helper function to convert GameState to a string key for our Q-table
function state_to_key(state::GameState)
    # Flatten vision matrix to string and combine with apple position
    vision_str = join(state.vision)
    return "$(vision_str)|$(state.apple_relative_pos)"
end

# Initialize Q-table
function init_q_table()
    return Dict{String, Vector{Float64}}()
end

# Get Q-values for a state
function get_q_values(q_table::Dict{String, Vector{Float64}}, state::GameState)
    key = state_to_key(state)
    if !haskey(q_table, key)
        q_table[key] = zeros(4)
    end
    return q_table[key]
end

# Choose action using epsilon-greedy policy
function choose_action(q_table::Dict{String, Vector{Float64}}, state::GameState)
    if rand() < EPSILON
        return random_action()
    else
        q_values = get_q_values(q_table, state)
        return argmax(q_values)
    end
end

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

# Training function
using Serialization

# File path for saving Q-table
const Q_TABLE_FILE = "snake_q_table.jls"

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
# Modify play_game! to use Q-learning
function play_trained_game!(q_table::Dict{String, Vector{Float64}}, 
                           world, head_pos, body_positions, apple_pos; 
                           max_steps=1000)
    total_score = 0
    
    for step in 1:max_steps
        state = get_state(world, head_pos, apple_pos, body_positions)
        action = choose_action(q_table, state)
        
        game_over, score, new_apple_pos = step!(world, head_pos, 
                                                body_positions, apple_pos, action)
        apple_pos = new_apple_pos
        total_score += score
        
        println("\nStep $step, Action: $action")
        print_world(world)
        println("Score: $total_score")
        
        if game_over
            println("Game Over! Final score: $total_score")
            break
        end
        
        sleep(0.3)
    end
    return total_score
end

# Training and visualization function
function train_and_visualize(episodes::Int)
    println("Starting training...")
    q_table, rewards, lengths = train_q_learning(episodes)
    
    println("\nTraining completed!")
    println("Average reward last 100 episodes: ", 
            mean(rewards[max(1, end-99):end]))
    println("Average length last 100 episodes: ", 
            mean(lengths[max(1, end-99):end]))
    
    println("\nPlaying a game with trained policy...")
    world, head_pos, body_positions, apple_pos = init_game()
    println("Initial state:")
    print_world(world)
    println("\nStarting game...")
    play_trained_game!(q_table, world, head_pos, body_positions, apple_pos)
    
    return q_table, rewards, lengths
end

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
