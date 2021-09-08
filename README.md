# esc
The main external short code is "main_cell.m" which runs the Simulink/Simscape model "ESC_cell_model.slx".
The custom simscape OCV-RC components are in the "LiBatteryElements_lib.slx" file. The base cell model that uses them are also there. 
Currently the cell model used in "ESC_cell_model.slx" is unlinked from the cell model in the library file because it has the venting model that still needs debugging. 
