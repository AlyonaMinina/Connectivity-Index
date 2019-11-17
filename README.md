# Connectivity-Index
An ImageJ macro to process images for the plant vacuole connectivity assay

CI provides a quantitative estimation of connection between two areas in a plant vacuole. It is optimized for assesment of vacuolar connectivity at various developmental stages in <i>Arabidopsis thaliana </i> root cells, including very young wiggly and hard-to-image vacuoles in the cells close to quicent center.


<b>Data required for the assay</b>
FRAP series containg at least two frames: one acquired right before photobleaching and one taken right after photobleaching


Assay was optimized for FRAP acquired using Leica CLSM, but should be applicable for data imaged on other micrscopes as well
1. Make sure that each FRAP series is saved as a separate .tif file. For Leica data use macro Processing Leica CLSM project file for vacFRAP.ijm
2. Use the connectivity index.ijm macro to calculate CI for each series:
- follow the instructions provided by the macro
- select the photobleached (<b> area A</b>) and non-photobleached  (<b> area B</b>) areas within the vacuole of the same cell and select an area in a neighbouring cell  (<b> area C</b>) to be used as a reference


Connectivity index is calculated in followinf steps:
- <b> dA</b> = intensity drop in the photobleached area of the vacuole as % of this are intentisy before photobleaching
- <b> dB</b> = intensity drop in the not photobleached area of the same vacuole as % of this area intentisy before photobleaching
- <b> dC</b> = intensity drop in the vacuole of neighbouring cell as % of this area intentisy before photobleaching
- <b> Rel</b> = relative loss of fluorescence within the vacuole, comparing photobleached and non-photobleached areas (areas are in potentially connected parts of vacuole)
   <br>Rel = dA-dB
- <b> Ref</b> = reference loss of fluorescence, comapring photobleached are in one cell and non-photobleached in another (areas are in disconnected vacuoles)
   <br>Ref = dA-dC 
- <b> CI</b> = Connectivity Index
<br> CI = (Ref-Rel)/Ref

<br>CI <0  indicates that non-photobleached area lost more signal than the photobleached area => technical issues, most probably drift during scanning
<br>CI = 0 indicates that photobleached and not photobleached areas are not connected
<br>CI = 1 indicates that photobleached and not photobleached areas are fully connected and diffusion rate between them is higher than the scanning speed
<br>CI > 1 indicates that there is a technical issue, most probably drift during scanning
<br>Cut off CI = the lowest value that corresponds to connected vacuoles, should be estimated empirically for each experiment by selecting vacuolar areas in three cells. 
       
