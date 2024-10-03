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
# # Test the setup
# world, head_pos, body_positions, apple_pos = init_game()
# println("Initial world state:")
# print_world(world)
#
# game_state = get_state(world, head_pos, apple_pos, body_positions)
# println("\nEnhanced game state:")
# println("Vision matrix:")
# for row in eachrow(game_state.vision)
#     println(join(row, " "))
# end
# println("Relative apple position: ", game_state.apple_relative_pos)
# println("Snake length: ", game_state.length)
#
# Add these constants for actions
const UP = 1
const RIGHT = 2
const DOWN = 3
const LEFT = 4

# Get direction vector from action
function action_to_direction(action)
    if action == UP
        return (-1, 0)
    elseif action == RIGHT
        return (0, 1)
    elseif action == DOWN
        return (1, 0)
    else  # LEFT
        return (0, -1)
    end
end

# Move snake and update game state
function step!(world, head_pos, body_positions, apple_pos, action)
    dy, dx = action_to_direction(action)
    new_head = [head_pos[1] + dy, head_pos[2] + dx]
    
    # Check collision with wall or body
    if world[new_head[1], new_head[2]] == WALL || 
       world[new_head[1], new_head[2]] == SNAKE_BODY
        return true, 0, apple_pos  # Game over
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
function play_game!(world, head_pos, body_positions, apple_pos; max_steps=100)
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
        
        sleep(0.5)  # Slow down for visibility
    end
    return total_score
end

# Test the game
function test_game()
    world, head_pos, body_positions, apple_pos = init_game()
    println("Initial state:")
    print_world(world)
    println("\nStarting game...")
    return play_game!(world, head_pos, body_positions, apple_pos)
end

# Run the test
test_game()
