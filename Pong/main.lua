local push = require 'libraries.push'
local Class = require 'libraries.class'

require 'entities.paddle'
require 'entities.ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Initialize scores
    player1Score = 0
    player2Score = 0

    -- Initialize winning player
    winningPlayer = 0

    -- Paddle positions
    player1 = Paddle(10, 30,5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Ball position
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.update(dt)
    playerOneMovement()
    playerTwoMovement()

    if gameState == 'play' then
        ballCollision()
        gameScore()
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        end
    elseif key == 'r' then
        gameState = 'start'
        love.event.quit('restart')
    end
end

function love.draw()
    push:apply("start")

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.printf("Press 'Enter' to Serve!", 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.printf("Good Luck!", 0, 20, VIRTUAL_WIDTH, 'center')
    else 
        love.graphics.printf("The Winner is Player " ..tostring(winningPlayer), 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 'R' to Restart", 0, 40, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Left Paddle
    player1:render()
    -- Right Paddle
    player2:render()

    -- Ball
    ball:render()

    displayFPS()
    
    push:apply("end")
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function playerOneMovement()
    -- Player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy  = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
end

function playerTwoMovement()
    -- Player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
end

function ballCollision()
    if ball:collides(player1) then
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + 5

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end

    if ball:collides(player2) then
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end

    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.y = VIRTUAL_HEIGHT - 4
        ball.dy = -ball.dy
    end
end

function gameScore()
    if ball.x < 0 then
        player2Score = player2Score + 1
        checkWinner()
    end

    if ball.x > VIRTUAL_WIDTH then
        player1Score = player1Score + 1
        checkWinner()
    end
end

function checkWinner()
    if player1Score == 10 then
        winningPlayer = 1
        gameState = "done"
    elseif player2Score == 10 then
        winningPlayer = 2
        gameState = "done"
    else
        ball:reset()
        gameState = 'start'
    end
end