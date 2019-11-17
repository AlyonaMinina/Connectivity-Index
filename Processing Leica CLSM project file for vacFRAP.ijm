// save FRAP series as individual tif files (sic! FRAP subfolders in the project are not allowed)
run("Bio-Formats Macro Extensions");

// pcik the directory with Leica project file
dir = getDirectory("Choose directory");

// get file listing
list = getFileList(dir);
newlist = list;

// process only images
images = newArray(0);
for(w = 0; w < list.length; w++) {
	fn = dir  + list[w];
	Ext.isThisType(fn, type)
	if (type == "true") {
		images = Array.concat(images, fn);
	}
}

//save each FRAP session as an individual tiff stack
for (n = 0; n < images.length; n++) {
	Ext.setId(images[n]);
	Ext.getSeriesCount(count);
	if (count == 1) {
		// file contains only one image
		run("Bio-Formats Windowless Importer", "open=[" + images[n] + "]");
		name = getTitle();
		saveAs("tiff", name + ".tif");
		close();
	} else {
		// file contains several images; save each separately
		for (i = 1; i < count + 1; i++) {
			Ext.setSeries(i - 1);
			Ext.getSeriesName(sname);
			run("Bio-Formats Importer", "open=[" + images[n] + "] series_" + i);
			saveAs("tiff", dir + sname + ".tif");
			close();
		}
	}
}

