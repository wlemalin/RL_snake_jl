module HyperParameters

export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE

# RL hyperparameters
const EPSILON = 0.03  
const ALPHA = 0.04 
const GAMMA = 0.825

# Game parameters
const EMPTY = 0
const APPLE = 1
const WALL = -1
const SNAKE_BODY = 2
const SNAKE_HEAD = 3
const PADDING = 3
const GRID_SIZE = 10 + 2* PADDING 
const VIEW_RANGE = 2

# Movements
const UP = 0
const RIGHT = 1
const DOWN = 2
const LEFT = 3

# Rewards 
const APPLE_EATEN = 1
const VACANT = 0
const HURDLE = -1

end