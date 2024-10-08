module Constantes
export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT

# Q-learning parameters
const EPSILON = 0.0000003  # Exploration rate
const ALPHA = 0.04   # Learning rate
const GAMMA = 0.825   # Discount factor

# Constants
const EMPTY = 0
const APPLE = 1
const WALL = -1
const SNAKE_BODY = 2
const SNAKE_HEAD = 3
const PADDING = 3
const GRID_SIZE = 10 + 2* PADDING # 10x10 playable area + 2 walls on each side
const VIEW_RANGE = 2

const UP = 1
const RIGHT = 2
const DOWN = 3
const LEFT = 4

end
