# Siloseam Characterization Design Files

## Description

Each characterization design files has three related file.
The files has been named in the following format:
* exp_[charachterization Domain]_desin.svg
* exp_[charachterization Domain]_fab.svg
* exp_[charachterization Domain]_mold.stl

SVG (Scalable Vector Graphics) images can be created and edited with any text editor, as well as with drawing software.
STL (an abbreviation of "stereolithography")are for 3d printing. 

### How to Use - Customize Experiment
***_design.svg** files present our base design which you can drag and drop into the Siloseam app and generate the mold and it's respected separator through the app. 

If you are interested to design your own experiment from scrath or modify one of the existing *_design.svg files from our process, you can drag and drop your svg file in the Siloseam app and generate the mold and separator for your design.
You can find the active link to the Siloseam app [here](https://github.com/The-Hybrid-Atelier/siloseam/blob/master/tool/README_app.md).

### How to Use - Replicate Experiment
 ***_fab.svg** files have both separator and the mold design included which has been generated through the Siloseam app and it is ready to be fabricated.
 ***_mold.stl** files the the generated molds for that specific design and it is ready to be inserted into the 3d printer application and from there you can send it to your printer. 
 
 In order to replecate our designs you can use the *_fab.svg file and *_mold.stl. There is no need to modify and recreate the molds from *_design.svg file.
 
 You can print the mold and use the separaor layer in *_fab.svg file to print the separator as well.
 For more information related to separator material and process please click here (ADD LINK)).
 On these experiments we used vynal as our main separator material.
 
 After you have the mold 3d printed and have your separator ready, you can begin the bladder fabrication process.
 To learn more about step by step bladder fabrication pricess please click here (ADD LINK).
 
 

## Experiments
* Basic -> This experiment presents a simple and basic single bladder design.
* Thickness -> This experiment measures the proper thickness of the top and bottom layer. The changing variable is the pouring layer thickness on the mold body. We have three ratios. 1:1 for each layer, 2:1 interchangeably for top and bottom layer.
* Seam Width -> This experiment measures how much seam support is needed to fabricate a strong bladder. The separator size remains constant and the seam margin is our changing variable. 
* Aspect Ratio -> This experiment covers the relationship between aspect ratio and rupture time of the bladder.
* Size -> This experiment is similar to the Seam Width but here the seam size is the constant variable and the size of the bladder itself will change. 
* Shape -> This experiment showcases the effect of different shapes on the straight and behavior of the bladder. 

## 3D Printer Setting
We printed these files using an Ultimaker 3 with ABS filament at 0.2mm layer height and a 0.4mm nozzle. 


> **Material Warning**
> Even though silicone does not stick to any material except itself, some materials can affect the curing process of the silicone. Materials such as resin, or wood can not be in direct contact with the silicone. They can cause a change of behavior on the silicone and block the curing process from happening. You can use these materials if they are coated twice with acrylic paint. 



## Testing Procedure
We designed and used this object for our testing process. Some time fabrication process can have issues such as air bubbles which can weaken the bladder and cause eruption. To make sure we have a fully functional bladder we do need to test them after the fabrication process is over.
We can insert an air tube inside the bladder and use this Rig to hold the tube in a steady position while you can inject air into the bladder from the other side of the tube. For injecting air we used an airbrush machine and we set it on 10-20 PSI.
You can find the link to the rig object design files in thingiverse here. (ADD LINK)

* You can go back to the Characterization design files in Thingerverse through [here](https://www.thingiverse.com/thing:4283808/files).
