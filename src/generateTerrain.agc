
function SetupTerrainShader()
	setfolder("..")
	setfolder("media/Ev_shaders/terrain")
	Terrain.GenerateShader=loadshader("TerrainGen.vs","TerrainGen.ps")
	terrain.terrainGenImage=CreateRenderImage(1024,1024,0,1)
	terrain.terrainSprite=createsprite(0):setspritesize(Terrain.terrainSprite,1024,1024):SetSpriteShapeBox(terrain.terrainSprite,0,0,0,0,0)
	SetspriteShader(terrain.terrainSprite,Terrain.GenerateShader)
	SetSpriteVisible(terrain.terrainSprite,0)
	terrain.majorTileSize=2048
endfunction


remstart
global n1 as float
global n2 as float
global n3 as float
n1=random2(3,5)*0.1
n2=random2(220,230)*0.01
n3=random2(5,20)*0.1
seed=random(1,234567876543)
for row = 1 to numRows 
    for col = 1 to numCols 
        // Calculate offsets based on the row/column
        // Set uniforms for the shader
        	SetShaderConstantByName(terrainShaderID,"scale",0.04,0,0,0)
        	SetShaderConstantByName(terrainShaderID,"chunkSize",tileSize#,0,0,0)
		SetShaderConstantByName(terrainShaderID,"row",row,0,0,0)
		SetShaderConstantByName(terrainShaderID,"col",col,0,0,0)
		SetShaderConstantByName(terrainShaderID, "noiseParams", n1, n2-n1 ,0,seed  )
remend

function GenerateTerrain()
	

folder=OpenRawFolder("raw:" + GetReadPath()+"media/terrain/terrain")
raw$="raw:" + GetReadPath()+"media/terrain/terrain"
for i = 0 to GetRawFolderNumFiles(folder)-1
	`CreatesplatImage(major.HeightMap)
	filename$=GetRawFolderFileName(folder,i)
	if left(filename$,7)="terrain" 
		if right(filename$,3)="png"

			majorTile as majortype
			majorTile.TerrainHmapName=raw$+"/"+filename$
			majorTile.HeightMap=loadimage(raw$+"/"+filename$)
			majorTile.splatmapid =loadimage(raw$+"/"+"splat"+right(filename$,6))
			`majorTile.splatMapID=loadimage(raw$+"/"+filename$)
			//get row/col from filename
			numpng$=right(filename$,6)
			nums$=left(numpng$,2)
			col=val(left(nums$,1))
			row=val(right(nums$,1))
			terrain.major.insert(majorTile)
		endif
	endif
next

endfunction


function CreateSplatImage(imageID as integer)
	local red as integer
	local green as integer
	local blue as integer
	local imgWidth as integer
	local imgHeight as integer
	local memblockID as integer
	local memblockWidth as integer
	local memblockHeight as integer
	local textureCount as integer
	local levelRange as integer
	local y as integer
	local x as integer
	local height as integer
	local textureR as integer
	local textureg as integer
	local textureb as integer
    local textureA as integer
    local splatMap as integer
    local level as integer
   
    // Load the image and create a memblock
    imgWidth = GetImageWidth(imageID)
    imgHeight = GetImageHeight(imageID)
    memblockID = CreateMemblockFromImage(imageID)
    
    // Get memblock size
    memblockWidth = GetMemblockInt(memblockID, 0)
    memblockHeight = GetMemblockInt(memblockID, 4)

    // Define number of height levels (including level 0 which is fully transparent)
    textureCount = 5  // 5 levels: 0 = transparent, 1 = red, 2 = green, 3 = blue, 4 = alpha
    levelRange = 255 / textureCount // Divide range 0-255 across 5 levels

    // Loop through each pixel and adjust colors based on height
    for y = 0 to memblockHeight - 1
        for x = 0 to memblockWidth - 1
            // Get pixel RGB values (assuming grayscale heightmap)
            red = GetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 0)
            green = GetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 1)
            blue = GetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 2)

            // Normalize height (grayscale value) from 0 to 255
            height = (red + green + blue) / 3 // Average to get height value

            // Calculate texture level based on height
            level = Floor(height / levelRange)

            // Initialize RGBA channels
            textureR = 0
            textureG = 0
            textureB = 0
            textureA = 0

            // Assign the correct texture based on the height level, ensuring height-based blending
            if height < 51
                // Below 51: No texture (fully transparent)
                textureR = 0
                textureG = 0
                textureB = 0
                textureA = 0
            elseif height >= 51 and height < 102
                // Level 1: Apply to Red channel
                textureR = 255
                textureG = 0
                textureB = 0
                textureA = 0
            elseif height >= 102 and height < 153
                // Level 2: Apply to Green channel
                textureR = 0
                textureG = 255
                textureB = 0
                textureA = 0
            elseif height >= 153 and height < 204
                // Level 3: Apply to Blue channel
                textureR = 0
                textureG = 0
                textureB = 255
                textureA = 0
            elseif height >= 204 and height <= 255
                // Level 4: Apply to Alpha channel
                textureR = 0
                textureG = 0
                textureB = 0
                textureA = 255
            endif

            // Set RGBA values for the pixel
            SetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 0, textureR) // Red channel
            SetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 1, textureG) // Green channel
            SetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 2, textureB) // Blue channel
            SetMemblockByte(memblockID, 12 + (y * memblockWidth + x) * 4 + 3, textureA) // Alpha channel
        next
    next
     
    // Return the new image ID with the updated texture
    endfunction memblockID
    
    
function blur(memblockID, amount)
	local r as integer
	local g as integer
	local b as integer
	local a as integer
	local width as integer
	local height as integer
	local memblocksize as integer
	local tempMemblock as integer
	local y as integer
	local x as integer
	local totalR as integer
	local totalG as integer
	local totalB as integer
	local totalA as integer
	local avgR as integer
	local avgG as integer
	local avgB as integer
	local avgA as integer
	local avgColor as integer
	local value as integer
	local count as integer
	local ammount as integer
	local color as integer
	local sampleY as integer
	local sampleX as integer
	local dx as integer
	local dy as integer
	local offset as integer
	
	
	
	
    // Get memblock size, width, and height
    width = GetMemblockInt(memblockID, 0)  // Width at offset 0
    height = GetMemblockInt(memblockID, 4) // Height at offset 4
    memblockSize = GetMemblockSize(memblockID)

    // Create a temporary memblock for the horizontal pass
    tempMemblock = CreateMemblock(memblockSize)

    // Horizontal pass: blur each row
    for y = 1 to height
        for x = 1 to 	width
        	value=(y*x)-1000
        SetTextString(1,"Blurring Horizontal. Pass num("+str(value)+")")
        if x=1000 and mod(y,32)=0
		sync()
	endif
            // Initialize accumulators for color channels
            totalR = 0
            totalG = 0
            totalB = 0
            totalA = 0
            count = 0

            // Average pixels in the horizontal direction (left and right neighbors)
            for dx = -amount to amount
                sampleX = Clamp(x + dx, 1, width)
                offset = (y * width + sampleX) * 4
                color = GetMemblockInt(memblockID, offset)

                // Extract individual color channels
                r = mod(Floor(color / 16777216), 256)
                g = mod(Floor(color / 65536), 256)
                b = mod(Floor(color / 256), 256)
                a = mod(color, 256)

                // Accumulate color values
                totalR = totalR + r
                totalG = totalG + g
                totalB = totalB + b
                totalA = totalA + a
                count = count + 1
            next

            // Calculate the average color
            avgR = totalR / count
            avgG = totalG / count
            avgB = totalB / count
            avgA = totalA / count

            // Combine the averaged color channels
            avgColor = (avgR * 16777216) + (avgG * 65536) + (avgB * 256) + avgA

            // Write the horizontally blurred pixel to the temp memblock
            offset = (y * width + x) * 4
            SetMemblockInt(tempMemblock, offset, avgColor)
            
            
            
            
                        // Average pixels in the vertical direction (above and below neighbors)
            for dy = -amount to amount
                sampleY = Clamp(y + dy, 1, height)
                offset = (sampleY * width + x) * 4
                color = GetMemblockInt(tempMemblock, offset)

                // Extract individual color channels
                r = mod(Floor(color / 16777216), 256)
                g = mod(Floor(color / 65536), 256)
                b = mod(Floor(color / 256), 256)
                a = mod(color, 256)

                // Accumulate color values
                totalR = totalR + r
                totalG = totalG + g
                totalB = totalB + b
                totalA = totalA + a
                count = count + 1
            next

            // Calculate the average color
            avgR = totalR / count
            avgG = totalG / count
            avgB = totalB / count
            avgA = totalA / count

            // Combine the averaged color channels
            avgColor = (avgR * 16777216) + (avgG * 65536) + (avgB * 256) + avgA

            // Write the final blurred pixel back to the original memblock
            offset = (y * width + x) * 4
            SetMemblockInt(memblockID, offset, avgColor)
            
            
            
            
            
            
        next
    next

 





	local memblockImageId as integer
   memblockImageID = CreateImageFromMemblock(memblockID)
    
    // Delete the temporary memblock
    DeleteMemblock(memblockID)
endfunction memblockImageID

    
 
   





 	
remstart this smooths my terrain for some unknown reason saving this for later because i can alter height and smopoth but memblocks are slow	
function SmoothTerrainHeights(memblockID)
    // Get the number of vertices and number of attributes per vertex from the header
    numVertices = GetMemblockInt(memblockID, 0)       // Number of vertices
    vertexSize = GetMemblockInt(memblockID, 12)       // Size of each vertex in bytes
    vertexDataOffset = 60  // Vertex data starts at offset 60

    // Scaling factor to increase smoothing effect (amplify the changes)
    smoothingFactor = 1.5
	m=GetMemblockSize(memblockid)
    // Loop through the vertices and smooth the Y (height) values
    for i = 1 to numVertices-2
    	
        vertexOffsetA = vertexDataOffset + ((i - 1) * vertexSize) // Previous vertex
        vertexOffsetB = vertexDataOffset + (i * vertexSize)       // Current vertex
        vertexOffsetC = vertexDataOffset + ((i + 1) * vertexSize) // Next vertex
	
        // Retrieve the Y (height) values for vertices A, B, C
        	off=0
        heightA = GetMemblockFloat(memblockID, vertexOffsetA + 4+off)
        heightB = GetMemblockFloat(memblockID, vertexOffsetB + 4+off)
        heightC = GetMemblockFloat(memblockID, vertexOffsetC + 4+off)
        

        // Apply the smoothed height to Y, leave Z untouched
        `SetMemblockFloat(memblockID, vertexOffsetB +12,(heighta+heightc) )
       SetMemblockFloat(memblockID, vertexOffsetB +12,1024.0 )
    next i
endfunction
remend

