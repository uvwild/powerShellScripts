diskpart
list volume
select volume 1  # Replace X with the source ESP volume number
assign letter=O
select volume 5  # Replace Y with the target partition volume number
assign letter=S
exit

robocopy O:\ S:\ /E /XJ /DCOPY:T /COPYALL /R:1 /W:1
