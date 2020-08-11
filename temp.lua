if love.keyboard.isDown('w') then
    paddle1.dy = -PADDLE_SPEED
elseif love.keyboard.isDown('s') then
    paddle1.dy = PADDLE_SPEED
else
    paddle1.dy = 0
end