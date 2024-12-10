// File: Camera_Control.agc
// Created: 24-11-24
function load_Camera()
	cam.speed = 55.0       // Movement speed
	cam.sensitivity = 0.2 // Mouse sensitivity
	cam.angleX = 0.0      // Rotation around the X-axis (up/down)
	cam.angleY = 0.0      // Rotation around the Y-axis (left/right)
	cam.smoothing = 10.0   // Smoothing factor for rotation
	cam.velocityX = 0.0   // Smoothed velocity for X-axis rotation
	cam.velocityY = 0.0   // Smoothed velocity for Y-axis rotation
endfunction

type Cam
	speed as float       // Movement speed
	sensitivity as float// Mouse sensitivity
	angleX as float      // Rotation around the X-axis (up/down)
	angleY as float      // Rotation around the Y-axis (left/right)
	smoothing as float
	velocityX as float
	velocityY as float
endtype

function Camera()
	local deltaTime as float
	local mousex as integer
	local mousey as integer
	local targetDeltaX# as float
	local targetDeltaY# as float
  	// Get frame time for time-based movement
    deltaTime = GetFrameTime()

    // Capture current mouse position
    mouseX = GetRawMouseX()
    mouseY = GetRawMouseY()

    // Calculate mouse movement (target delta)
    targetDeltaX# = (mouseX - GetDeviceWidth() / 2) * cam.sensitivity // Target left/right movement
    targetDeltaY# = (mouseY - GetDeviceHeight() / 2) * cam.sensitivity // Target up/down movement

    // Smooth velocity interpolation
    cam.velocityX = cam.velocityX + (targetDeltaY# - cam.velocityX) * cam.smoothing * deltaTime
    cam.velocityY = cam.velocityY + (targetDeltaX# - cam.velocityY) * cam.smoothing * deltaTime

    // Update camera angles with smoothed velocity
    cam.angleY = cam.angleY + cam.velocityY // Rotate on the Y-axis (left/right)
    cam.angleX = cam.angleX - cam.velocityX // Rotate on the X-axis (up/down)
    cam.angleX = Clamp(cam.angleX, -89.0, 89.0) // Limit up/down rotation to avoid flipping

    // Reset mouse to center after capturing movement
    SetRawMousePosition(GetDeviceWidth() / 2, GetDeviceHeight() / 2)

    // Update camera rotation directly on the X and Y axes
    SetCameraRotation(1, -cam.angleX, cam.angleY, 0)
if GetRawKeyState(16)=1
    // Handle movement with WASD keys
    if GetRawKeyState(87) then MoveCameraLocalZ(1,  cam.speed *  deltaTime) // W key: forward
    if GetRawKeyState(83) then MoveCameraLocalZ(1, -cam.speed *  deltaTime) // S key: backward
    if GetRawKeyState(65) then MoveCameraLocalX(1, -cam.speed *  deltaTime) // A key: strafe left
    if GetRawKeyState(68) then MoveCameraLocalX(1,  cam.speed *  deltaTime) // D key: strafe right
endif
endfunction