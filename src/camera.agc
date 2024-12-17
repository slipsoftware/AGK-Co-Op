// File: Camera.agc
// Created: 24-11-24

type CameraData
	Position as Core_Vec3Data
	Angle as Core_Vec2Data
	Velocity as Core_Vec2Data
	Speed# as float			// Movement speed
	Sensitivity# as float	// Mouse sensitivity
	Smoothing# as float
endtype

global Camera as CameraData // from camera prolly shaders will access or replace
global Camera_OldMouseX# as float
global Camera_OldMouseY# as float

function Cam_Init()
	Camera.Speed#  =  10.0			// Movement speed
	Camera.Sensitivity#  =  1.0		// Mouse sensitivity
	Camera.Smoothing#  =  10.0  	// Smoothing factor for rotation
endfunction

function Cam_Debug()
	print("Camera Position X:" + str(Camera.Position.X#))
	print("Camera Position Y:" + str(Camera.Position.Y#))
	print("Camera Position Z:" + str(Camera.Position.Z#))
	print("Camera Angle X:" + str(Camera.Angle.X#))
	print("Camera Angle Y:" + str(Camera.Angle.Y#))
//~	print("Camera Angle Z:" + str(Camera.Angle.Z#))
endfunction

function Cam_Update(FrameTime#)
	local MouseX# as integer
	local MouseY# as integer
	local MouseDeltaX# as float
	local MouseDeltaY# as float
	
    // Capture current mouse position
	MouseX# = GetPointerX()
	MouseY# = GetPointerY()
    
    // Reset Old Mouse Position so Delta begins at zero
    if GetPointerPressed()
		Camera_OldMouseX# = MouseX#
		Camera_OldMouseY# = MouseY#
    endif
    
    if GetPointerState()
    	// Calculate mouse movement (target delta)
		MouseDeltaX# = MouseX# - Camera_OldMouseX# * Camera.Sensitivity#	// Target left/right movement
		MouseDeltaY# = MouseY# - Camera_OldMouseY# * Camera.Sensitivity#	// Target up/down movement	
		
		// Set Old Mouse Position to calculate Mouse Delta
		Camera_OldMouseX# = MouseX#
		Camera_OldMouseY# = MouseY#
	endif
	
    // Smooth velocity interpolation
    Camera.Velocity.X# = Camera.Velocity.X# + (MouseDeltaY# - Camera.Velocity.X#) * Camera.Smoothing# * FrameTime#
    Camera.Velocity.Y# = Camera.Velocity.Y# + (MouseDeltaX# - Camera.Velocity.Y#) * Camera.Smoothing# * FrameTime#

    // Update camera angles with smoothed velocity
    Camera.Angle.Y# = Camera.Angle.Y# + Camera.Velocity.Y# // Rotate on the Y - axis (left/right)
    Camera.Angle.X# = Camera.Angle.X# + Camera.Velocity.X# // Rotate on the X - axis (up/down)
    
    Camera.Angle.X# = Core_Clamp(Camera.Angle.X#,  - 89.0, 89.0) // Limit up/down rotation to avoid flipping

    // Update camera rotation directly on the X and Y axes
    SetCameraRotation(1,Camera.Angle.X#,Camera.Angle.Y#,0)
    
    
	if GetRawKeyState(Key_W) then MoveCameraLocalZ(1, Camera.Speed# * FrameTime#)
    if GetRawKeyState(Key_S) then MoveCameraLocalZ(1, - Camera.Speed# * FrameTime#)
    if GetRawKeyState(Key_A) then MoveCameraLocalX(1, - Camera.Speed# * FrameTime#)
    if GetRawKeyState(Key_D) then MoveCameraLocalX(1, Camera.Speed# * FrameTime#)
    if GetRawKeyState(Key_Q) then MoveCameraLocalY(1, - Camera.Speed# * FrameTime#)
    if GetRawKeyState(Key_E) then MoveCameraLocalY(1, Camera.Speed# * FrameTime#)
    
    Camera.Position.X# = GetCameraX(1)
    Camera.Position.Y# = GetCameraY(1)
    Camera.Position.Z# = GetCameraZ(1)
endfunction