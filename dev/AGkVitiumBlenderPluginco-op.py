import bpy
import json
import os
import subprocess
import time
import shutil

#import export_code

bl_info = {
    "name": "AGK Exporter",
    "author": "Jake C",
    "version": (1, 1),
    "blender": (2, 79, 0),
    "location": "View3D > Tool Shelf > AGK",
    "description": "Export AGK code and AGK load script",
    "category": "Development"
}

def code():
    # your code here
    print("Exporting AGK code...")

class ExportAGKLoadScriptOperator(bpy.types.Operator):
    bl_idname = "object.export_agk_load_script"
    bl_label = "Compile and Run"

    def execute(self, context):
        json_export()
        return {'FINISHED'}
    
def register_properties():
    bpy.types.Material.collision = bpy.props.BoolProperty(
        name="Collision",
        description="Enable or disable collision for the material",
        default=False
    )
    bpy.types.Material.sound = bpy.props.BoolProperty(
        name="Sound",
        description="Enable or disable sound for the material",
        default=False
    )
    bpy.types.Material.trigger = bpy.props.BoolProperty(
        name="Trigger",
        description="Enable or disable trigger for the material",
        default=False
    )
    bpy.types.Material.forcefield = bpy.props.FloatProperty(
        name="Forcefield",
        description="Adjust the forcefield value",
        default=0.0,
        min=-1.0,
        max=1.0,
        precision=4
    )
    bpy.types.Material.glass = bpy.props.FloatProperty(
        name="Glass",
        description="Adjust the glass value",
        default=0.0,
        min=-1.0,
        max=1.0,
        precision=4
    )
    bpy.types.Scene.agk_compiler_path = bpy.props.StringProperty(
        name="AGK Compiler Path",
        description="Path to the AGK compiler executable",
        default="C:\\AppGameKit Studio\\media\\compiler\\AGKCompiler64.exe",
        subtype='FILE_PATH'
    )
    bpy.types.Scene.agk_project_path = bpy.props.StringProperty(
        name="Project Path",
        description="Name of the AGK Project File",
        default="C:\\myProject.agc",
        subtype='FILE_PATH'
    )
    bpy.types.Scene.agk_export_path = bpy.props.StringProperty(
        name="Export Path",
        description="Path to the Export File",
        default="C:\\myProject.json",
        subtype='FILE_PATH'
    )

# Define the custom UI panel
class MATERIAL_PT_CustomProperties(bpy.types.Panel):
    bl_label = "Custom Material Properties"
    bl_idname = "MATERIAL_PT_custom_properties"
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = "material"

    def draw(self, context):
        layout = self.layout
        mat = context.object.active_material

        if mat:
            layout.prop(mat, "collision", text="Collision")
            layout.prop(mat, "sound", text="Sound")
            layout.prop(mat, "trigger", text="Trigger")
            layout.prop(mat, "forcefield", text="Forcefield")
            layout.prop(mat, "glass", text="Glass")

class AGKPanel(bpy.types.Panel):
    bl_idname = "OBJECT_PT_agk_panel"
    bl_label = "AGK"
    bl_space_type = "VIEW_3D"
    bl_region_type = "TOOLS"
    bl_category = "AGK"

    def draw(self, context):
        layout = self.layout
        scene = context.scene

        layout.prop(scene, "agk_compiler_path")
        layout.prop(scene, "agk_project_path")
        layout.prop(scene, "agk_export_path")

        layout.operator("object.export_agk_load_script")

def json_export():
    obb_list = []
    data=[]
    newdata=""

    # Loop through each selected object and get its rotation, position, and texture information
    scene = bpy.context.scene
    compiler_path = scene.agk_compiler_path
    project_path = scene.agk_project_path
    export_path = scene.agk_export_path
    project_filePath, project_fileName = os.path.split(project_path)
    project_fileName = os.path.splitext(project_fileName)[0]
    export_fileName = os.path.split(export_path)[1]
    
    if not os.path.exists(project_filePath):
        os.makedirs(project_filePath)

    if not os.path.exists(project_filePath):
        os.makedirs(project_filePath)
        
    objPath=os.path.join(project_filePath,"media/objects")
    if not os.path.exists(objPath):
        os.makedirs(objPath)
    texPath=os.path.join(project_filePath,"media/textures")
    if not os.path.exists(texPath):
        os.makedirs(texPath)
        
    texPath2=os.path.join(project_filePath,"media/textures/bulk")
    if not os.path.exists(texPath2):
        os.makedirs(texPath2)
        
    # Iterate over all the objects in the scene
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":  # Only process mesh objects
            obb_data = extract_obb_data(obj)
            obb_data["name"] = obj.name  # Include object name
            obb_list.append(obb_data)

        data.append("\n:Type:"+obj.type+":")
        data.append(":Name:"+obj.name+":")
        data.append("//Rotation")
        data.append(":x:"+str(obj.rotation_euler[0])+":")
        data.append(":y:"+str(obj.rotation_euler[1])+":")
        data.append(":z:"+str(obj.rotation_euler[2])+":")
        data.append("//Position")
        data.append(":x:"+str(obj.location[0])+":")
        data.append(":y:"+str(obj.location[1])+":")
        data.append(":z:"+str(obj.location[2])+":")
        if obj.type=="LAMP":
            l=obj.data.color
            data.append(":"+str(int(l[0]*255))+":"+str(int(l[1]*255))+":"+str(int(l[2]*255))+":")
            data.append(obj.data.distance)
        # Iterate over all of the current object's material slots
        # Iterate over all of the current object's material slots
       # Iterate over all the current object's material slots
        for m in obj.material_slots:
            if m.material:
                mat = m.material
                data.append("//Material Color RGB")
                
                # Write the diffuse color of the material
                diffuse = mat.diffuse_color  # This is in RGBA format
                data.append(":{:.0f}:{:.0f}:{:.0f}:".format(
                    diffuse[0] * 255,  # Red channel scaled to 0-255
                    diffuse[1] * 255,  # Green channel scaled to 0-255
                    diffuse[2] * 255   # Blue channel scaled to 0-255
                ))
                
                # Add custom shader values (Forcefield, Glass) and checkboxes (Collision, Sound, Trigger)
                collision = mat.get("collision", False)  # Default to False if not set
                sound = mat.get("sound", False)
                trigger = mat.get("trigger", False)
                forcefield = mat.get("forcefield", 0.0)
                glass = mat.get("glass", 0.0)
                specular = mat.specular_intensity  # Specular value from material
                emission = mat.emit  # Emissive value from material

                # Shader types and values
                shader = ["None", "Specular", "Emissive", "Glass", "ForceField"]
                shaderValue = [0, specular, emission, glass, forcefield]

                # Entity types and values
                ent = ["None", "Sound", "Trigger", "Collision"]
                entValue = [0, sound, trigger, collision]

                # Find the highest shader value
                maxValue = 0
                shaderIndex = 0
                for i, value in enumerate(shaderValue):
                    if value > maxValue:
                        maxValue = value
                        shaderIndex = i

                # Find the active entity type
                entIndex = 0
                for i, value in enumerate(entValue):
                    if value:  # If the value is True (non-zero for booleans)
                        entIndex = i
                        break

                # Append the highest shader to the data
                data.append(":Shader:{name}:Value:{value:.4f}:".format(name=shader[shaderIndex], value=shaderValue[shaderIndex]))

                # Append the active entity type to the data
                data.append(":Entity:{name}:Value:{value}:".format(name=ent[entIndex], value=int(entValue[entIndex])))

                # Iterate over all the current material's texture slots
                for t in mat.texture_slots:
                    # If this is an image texture, with an active image append its name to the list
                    if t and t.texture.type == 'IMAGE' and t.texture.image:
                        data.append(":Texture:" + t.texture.image.name + ":" + m.name + ":")
                        shutil.copy(t.texture.image.filePath, project_filePath + "\\media\\textures\\bulk")

      
    data.append("//END")
    data.append("//scene")
    scene=bpy.context.scene.world
    col=scene.ambient_color
    data.append(":"+str(int(col[0]*255))+":"+str(int(col[1]*255))+":"+str(int(col[2]*255))+":")
    # Convert the list of dictionaries to JSON format

    for i in data:
        newdata=newdata+str(i)+"\n"
        filepath2 = os.path.join(project_filePath, export_fileName)
    with open(filepath2, "w") as f:
        f.write(newdata)
    
    ##################EXPORT#######################################################
    # Set the filepath and filename for the FBX export
    directory = objPath+"/"

    # Loop through all objects in the scene
    for obj in bpy.context.scene.objects:

        # Select the object
        bpy.ops.object.select_all(action='DESELECT')
       
        obj.select=True
        # Set the output filepath for the FBX file
        filepath = directory + obj.name + ".fbx"
       # bpy.ops.object.active=obj
        #bpy.context.scene.objects.active=obj
        # Export the selected object to FBX
        if obj.type=="MESH":
            bpy.ops.export_scene.fbx(filepath=filepath, check_existing=False,object_types={'ARMATURE', 'CAMERA', 'LAMP', 'MESH'}, filter_glob='*.fbx', use_selection=True, global_scale=1.0, apply_unit_scale=True, 
            apply_scale_options='FBX_SCALE_NONE',
             use_mesh_modifiers_render=True, mesh_smooth_type='FACE', 
            use_mesh_edges=True,  use_custom_props=False, 
            add_leaf_bones=True, primary_bone_axis='Y', secondary_bone_axis='X', use_armature_deform_only=False, 
            armature_nodetype='NULL', bake_anim=True, bake_anim_use_all_bones=True, bake_anim_use_nla_strips=True, 
            bake_anim_use_all_actions=True, bake_anim_force_startend_keying=True, bake_anim_step=1.0, 
            bake_anim_simplify_factor=1.0, path_mode='AUTO', batch_mode='OFF', 
            use_batch_own_dir=True, axis_forward='-Z', axis_up='Y')
        #obj.deselect=True

    # Export OBB data to JSON
    obb_filepath = os.path.join(project_filePath, "obb_data.json")
    with open(obb_filepath, "w") as obb_file:
        json.dump({"obbs": obb_list}, obb_file, indent=4)

   #change this to your path the  double backslashes are required 
    param1=project_filePath
    subprocess.run([compiler_path, param1])
    
    exe2=project_filePath+"\\"+project_fileName+".exe"

    subprocess.run([exe2,""])

def extract_obb_data(obj):
    """Extract OBB data from a Blender object."""
    obb_data = {}

    # Center of the OBB
    center = obj.location
    obb_data["center"] = [center.x, center.y, center.z]

    # Half-extents (approximation based on object dimensions)
    dimensions = obj.dimensions
    obb_data["halfExtents"] = [dimensions.x / 2, dimensions.y / 2, dimensions.z / 2]

    # Rotation Matrix
    rotation_matrix = obj.matrix_world.to_3x3()
    obb_data["rotationMatrix"] = [[rotation_matrix[i][j] for j in range(3)] for i in range(3)]

    # Precomputed Inverse Rotation Matrix
    inverse_rotation_matrix = rotation_matrix.inverted()
    obb_data["inverseRotationMatrix"] = [[inverse_rotation_matrix[i][j] for j in range(3)] for i in range(3)]

    return obb_data

def register():
    bpy.utils.register_class(ExportAGKCodeOperator)
    bpy.utils.register_class(TestPlayOperator)
    bpy.utils.register_class(ExportAGKLoadScriptOperator)
    bpy.utils.register_class(AGKPanel)
    register_properties()
    bpy.utils.register_class(MATERIAL_PT_CustomProperties)

def unregister():
    bpy.utils.unregister_class(ExportAGKCodeOperator)
    bpy.utils.unregister_class(TestPlayOperator)
    bpy.utils.unregister_class(ExportAGKLoadScriptOperator)
    bpy.utils.unregister_class(AGKPanel)
    bpy.utils.unregister_class(MATERIAL_PT_CustomProperties)
    del bpy.types.Material.collision
    del bpy.types.Material.sound
    del bpy.types.Material.trigger
    del bpy.types.Material.forcefield
    del bpy.types.Material.glass

if __name__ == "__main__":
    register()
