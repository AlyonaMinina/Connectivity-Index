// ask the user to pick the directory with individual FRAP.tif series
dir = getDirectory("Choose directory");

// ask the user for the framerate used for scanning
frame1 = getNumber("How many frames were scanned before performing photobleaching", 4);
//Gaussian blur might help to average out noise that might have a big impact whenROI is very small
Gaussian_Blur = getNumber("Gaussian Blur", 2);

// get file listing
list = getFileList(dir);

// process only tif files
imglist = newArray(0);
for(Photobleachedseries = 0; Photobleachedseries < list.length; Photobleachedseries++) {
	if(endsWith(list[Photobleachedseries], 'tif')) {
		imglist = Array.concat(imglist, list[Photobleachedseries]);
	}
}

// loop for all tif files in the folder
for(Photobleachedseries = 0; Photobleachedseries < imglist.length; Photobleachedseries++) {
	imgname = dir + imglist[Photobleachedseries];
	run("Bio-Formats Windowless Importer", "open=[" + imgname + "]");
	
// get FRAP series name	
	title = getTitle;
    dotIndex = indexOf(title, ".");
    name = substring(title, 0, dotIndex);
    dir = getInfo("image.directory");
    
// user has to decide if drift correction is required. sic! it will fuck up images with low intensities    
    waitForUser("Please scroll through your FRAP time series and decide if it requires drift correction");
    regq = getBoolean("Would you like to carry out drift correction?\n");

if (regq) {
	    driftCorrection3D();
        CIquantification();
} else {
	   CIquantification();
}
    
//Correct for drift 
    function driftCorrection3D() {
    	run("Correct 3D drift", "channel=1 only=0 lowest=1 highest=1");
    	print("\\Clear");
    	selectWindow("registered time points");
    	}
//Connectivity index allows to compare loss of fluorescence in two potenitally connected areas of a vacuole and two obviously not connected vacuoles
	function CIquantification() {
		setTool("rectangle");
		Stack.setChannel(1);
		Stack.setFrame(frame1);
		waitForUser("Please select an area to be anlyzed");
		run("Crop");
		croppedx = getWidth();
		centerx = croppedx*0.5;
		croppedy = getHeight();
		centery = croppedy*0.5;
		run("Gaussian Blur...", "sigma=Gaussian_Blur stack");
		run("royal");
		run("Set... ", "zoom=200");
		run("ROI Manager...");
		
//create selections for the areas to be anlayzed and place them in the center
		makeOval(centerx, centery, 20, 20);
		roiManager("add");
		roiManager("Select", 0);
		roiManager("Rename", "photobleached area");
		
		makeOval(centerx, centery, 20, 20);
		roiManager("add");
		roiManager("Select", 1);
		roiManager("Rename", "non-photobleached area");

		makeOval(centerx, centery, 20, 20);
		roiManager("add");
		roiManager("Select", 2);
		roiManager("Rename", "reference area");
		
		Stack.setChannel(1);
		Stack.setFrame(frame1);
		waitForUser("Select ROI", "Please position the selections to the corresponding areas");
		run("Split Channels");
		close("C2-*");	
		roiManager("Select", newArray(0,1,2));
		Stack.setFrame(frame1);
		run("Set Measurements...", "integrated redirect=None decimal=3");
		roiManager("Measure");        
		roiManager("Select", newArray(0,1,2));
		Stack.setFrame(frame1 +1);
		run("Set Measurements...", "integrated redirect=None decimal=3");
		roiManager("Measure");       
        
//Calculate intensity drop in the photobleached area of the vacuole as % of this are intentisy before photobleaching
        A1 = getResult("RawIntDen",0); // fluorescence intensity right before photobleaching
        A2 = getResult("RawIntDen",3); // fluorescence intensity right after photobleaching
        dA = 100*(A1-A2)/A1; // change in intensity, %
        //print(dA);
//Calculate intensity drop in the not photobleached area of the same vacuole as % of this area intentisy before photobleaching
        B1 = getResult("RawIntDen",1); 
        B2 = getResult("RawIntDen",4); 
        dB = 100*(B1-B2)/B1; 
        //print(dB);
//Calculate intensity drop in the vacuole of neighbouring cell as % of this area intentisy before photobleaching
        C1 = getResult("RawIntDen",2); 
        C2 = getResult("RawIntDen",5); 
        C = 100*(C1-C2)/C1; //if experiment is carried out correctly, this should be a small value. It might be negative due to small drift of the vacuole during the time that takes to photobleach and scan one frame 
        dC = abs(C); // set the vaclue as always positive
        //print(dC);
//Relative loss of fluorescence within the vacuole, comparing photobleached and non-photobleached areas (areas are in potentially connected parts of vacuole)
        Rel = dA-dB;
        //print(Rel);
//Reference loss of fluorescence, comapring photobleached are in one cell and non-photobleached in another (areas are in disconnected vacuoles)
        Ref = dA-dC;
       //print(Ref);
//Caclulate Connectivity Index
        CI = Rel/Ref;
        print(name, CI);
        selectWindow("ROI Manager");
        run("Close"); 
        selectWindow("Results");
        run("Close"); 
        close();

        }
}
selectWindow("Log");
saveAs(dir + name +" CIquantification.txt ");   
run("Close"); 