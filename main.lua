WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('minecraft.TTF', 8)
    largeFont = love.graphics.newFont('minecraft.TTF', 27)

    scoreFont = love.graphics.newFont('font.TTF', 20)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }

    startState()

    gameState = 'start'

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if ball:collides(paddle2) then
        ball.dx = -ball.dx * 1.03
        sounds['paddle_hit']:play()

        if ball.dy < 0 then
            ball.dy = -math.random(140, 200)
        else
            ball.dy = math.random(140, 200)
        end
    end

    if ball:collides(paddle1) then
        ball.dx = -ball.dx * 1.03
        sounds['paddle_hit']:play()

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end

    if ball.y <= 0 then 
        ball.dy = -ball.dy
        ball.y = 0
        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['wall_hit']:play()
    end

    paddle1:update(dt)
    paddle2:update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            player2Score = player2Score + 1  
            sounds['point_scored']:play()
            ball:reset()
            ball.dx = -100            
            servingPlayer = 2
            if player2Score == 5 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1 
            sounds['point_scored']:play()           
            ball:reset()
            ball.dx = 100
            servingPlayer = 1
            if player1Score == 5 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end

        if playerOption == 'comp' then
            if ball.x <=  VIRTUAL_WIDTH / 2 then
                if ball.dy < 0 then
                    paddle1.dy = PADDLE_SPEED * 0.82 <= math.abs(ball.dy) and -PADDLE_SPEED * math.random(0.73, 0.84) or ball.dy
                else
                    paddle1.dy = PADDLE_SPEED * 0.82 <= ball.dy and PADDLE_SPEED * math.random(0.73, 0.84) or ball.dy
                end
            else
                paddle1.dy = 0
            end
        elseif playerOption == '2Player' then
            if love.keyboard.isDown('w') then
                paddle1.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('s') then
                paddle1.dy = PADDLE_SPEED
            else
                paddle1.dy = 0
            end
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED            
        else
            paddle2.dy = 0
        end

        ball:update(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'victory' then
            gameState = 'start'
            startState()
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    elseif key == '1' then         
        if gameState == 'start' then 
            gameState = 'serve'
        end
        playerOption = 'comp'
    elseif key == '2' then        
        if gameState == 'start' then 
            gameState = 'serve'
        end
        playerOption = '2Player'
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

    ball:render()

    paddle1:render()
    paddle2:render()

    if gameState == 'start' then
        love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

        love.graphics.setFont(largeFont)
        love.graphics.printf("Welcome to Pong!", 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press 1 for comp vs player!", 0, 90, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 2 for player1 vs player2!", 0, 102, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("First to score 5 wins the match!", 0, 152, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        if player1Score ~= 0 or player2Score ~= 0 then      
            love.graphics.printf("Player " .. tostring(servingPlayer) .. " wins the round!", 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Player " .. tostring(servingPlayer) .. " will serve to " .. tostring(servingPlayer == 1 and 2 or 1), 0, 32, VIRTUAL_WIDTH, 'center')   
            enterHeight = 44
        else 
            love.graphics.printf("Player " .. tostring(servingPlayer) .. " gets to start!", 0, 20, VIRTUAL_WIDTH, 'center')
            enterHeight = 32
        end     
        love.graphics.printf("Press Enter to Serve!", 0, enterHeight, VIRTUAL_WIDTH, 'center')  
        paddle1:reset(5, VIRTUAL_HEIGHT / 2  - 10, 5, 20)
        paddle2:reset(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
        displayScore()

    elseif gameState == 'victory' then        
        love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1)

        love.graphics.setFont(largeFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. ' wins!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Restart!", 0, 70, VIRTUAL_WIDTH, 'center')
    end
    
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0 ,1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()          
    love.graphics.print("Player 1", VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 3 - 10)
    love.graphics.print("Player 2", VIRTUAL_WIDTH / 2 + 25, VIRTUAL_HEIGHT / 3 -10)

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3) 
end

function startState()
    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    enterHeight = 0

    paddle1 = Paddle(5, VIRTUAL_HEIGHT / 2  - 10, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
end