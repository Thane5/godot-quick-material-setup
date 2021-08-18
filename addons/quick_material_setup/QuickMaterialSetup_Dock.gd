tool
extends Control


const SCALE_SUFFIX_ARRAY = ["_1K", "_2K", "_3K", "_4K", "_6K", "_8K", "_1k", "_2k", "_3k", "_4k", "_6k", "_8k"]

const ALBEDO_SUFFIX_ARRAY = ["color", "col", "diffuse","diff", "albedo", "base"]
const NORMAL_SUFFIX_ARRAY = ["normal", "nor", "nrm", "norm", "bump", "bmp"]
const METALLIC_SUFFIX_ARRAY = ["metallic", "metalness", "metal", "mtl"]
const ROUGHNESS_SUFFIX_ARRAY = ["roughness", "rough", "rgh", "gloss", "glossy", "glossiness"]

var currentResourcePaths

func _on_UseTemplate_Button_toggled(button_pressed):
	var templatePathArea = get_node("VBoxContainer/Options/ScrollContainer/MaterialProperties/Settings/Template Path Area")
	templatePathArea.set_visible(button_pressed)

	
func _on_Modify_pressed():


	for path in currentResourcePaths:
		
		# only use the part of the string BEFORE the last slash
		var workingDir = path.left(path.find_last("/")+1)
	
		# only use the part of the string AFTER the last slash
		var fileName = path.right(path.find_last("/")+1)
		
		# create the variable "texName" by copying fileName (because otherwise erase() would overwrite it)
		var texName = fileName 
		# then erase the file ending from it
		texName.erase(texName.find_last("."), texName.length()-texName.find_last("."))
		
		
		#	Remove stupid scale suffixes because they would mess with my channel suffix detection
		for scaleSuffix in SCALE_SUFFIX_ARRAY:
			if texName.ends_with(scaleSuffix) == true:
				texName = texName.trim_suffix(scaleSuffix)
				print("removed suffix ", scaleSuffix, " from Texture ", texName)
				break
		# Remove the even dumber _gl suffix because screw that
		if texName.ends_with("_gl") == true:
			texName = texName.trim_suffix("_gl")
			print("also removed _gl suffix from ", texName)
			
			
		
		# just an array containing all suffixes
		var suffixMaster = []
		suffixMaster.append_array(ALBEDO_SUFFIX_ARRAY)
		suffixMaster.append_array(NORMAL_SUFFIX_ARRAY)
		suffixMaster.append_array(METALLIC_SUFFIX_ARRAY)
		suffixMaster.append_array(ROUGHNESS_SUFFIX_ARRAY)
	
		var matName
		var useAsAlbedo = false # If this is true, it will skipp going through other suffixes
								# and directly use it as the albedo
		
		# If a channel suffix is found, remove it from the string and use it as matName
		# if no suffix matches, simply use the texture as albedo
		for anySuffix in suffixMaster:
			if texName.ends_with(anySuffix):
				matName = texName.trim_suffix(texName.substr(texName.find_last("_")))
				useAsAlbedo = false
				break
			else:
				matName = texName
				useAsAlbedo = true
		
		
		# this will be the path of the new material file
		var matPath = (workingDir + matName + ".tres")
		
		# first check if the file already exists, otherwise load it in
		var dummyFile =  File.new() # why do we have to create these??! 
		var currentMat # The loaded material instance
		
		if dummyFile.file_exists(matPath) == true:
			currentMat = load(matPath)
		else:
			currentMat = SpatialMaterial.new()
		
		# Either directly assign it to albedo, or assign it based on the suffix in texName
		if useAsAlbedo == true:
			currentMat.albedo_texture = load(path)
			print("no suffix found, using ", path, " as albedo")
			
		else:
			for albedoSuffix in ALBEDO_SUFFIX_ARRAY:
				if texName.ends_with(albedoSuffix):
					currentMat.albedo_texture = load(path)

			for normalSuffix in NORMAL_SUFFIX_ARRAY:
				if texName.ends_with(normalSuffix):
					currentMat.normal_enabled = true
					currentMat.normal_texture = load(path)

			for metallicSuffix in METALLIC_SUFFIX_ARRAY:
				if texName.ends_with(metallicSuffix):
					currentMat.metallic_texture = load(path)

			for roughnessSuffix in ROUGHNESS_SUFFIX_ARRAY:
				if texName.ends_with(roughnessSuffix):
					currentMat.roughness_texture = load(path)

		# finally, write the material to disk (happens for each texture but eh...
		ResourceSaver.save(str(matPath), currentMat)



