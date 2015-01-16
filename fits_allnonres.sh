#!/bin/bash

doBlinding=1

version=41
limitdirs=("fitToMgg_nonresSearch_withKinFit" "fitTo2D_nonresSearch_withKinFit")
do2DLimits=("0" "1")

#If you only want to run on a subset of directories, edit this array with the appropriate indices.
#It is recommended to only run on one of "0" or "1" at a time. There are lots of nonres samples.
runLimits=("0")

for i in `echo ${runLimits[@]}`; do

    if [ ${do2DLimits[$i]} == "0" ]; then
	fitterScript=R2GGBBFitter_mgg_addhiggs.exe
    else
	fitterScript=R2GGBBFitter_2D_addhiggs.exe
    fi

    imass=0

    sampleList=(`cat nonres_samplelist.txt`)

    for isample in `echo ${sampleList[@]}`; do

	echo "Running limits for sample $isample on ${limitdirs[$i]}"

	outputdir="radlim_${limitdirs[$i]}/${isample}"
	mkdir -p $outputdir

	if [ ${do2DLimits[$i]} == "0" ]; then
	    fitter="R2GGBBFitter_mgg_addhiggs.exe"
	else
	    fitter="R2GGBBFitter_2D_addhiggs.exe"
	fi

	./$fitter -v $version -n 4 --sigMass 0 --analysisType ${limitdirs[$i]} --nonresFile $isample >& ${outputdir}/log_radlim${imass}.txt

	mv workspaces/*.root $outputdir
	mv datacards/*.txt $outputdir

       #also colect the plots
	mv databkgoversig* $outputdir
	mv sigmodel* $outputdir
	mv higmodel* $outputdir

        ## create limits root files for each mass
	cd $outputdir
	
	if [ ${doBlinding} == 1 ]    
	then
	    combine -M Asymptotic --run blind hgg.mH125.0_8TeV.txt >> higgsCombineTest.Asymptotic.mH125.0.mR${imass}_higgs.txt
	    mv higgsCombineTest.Asymptotic.mH120.root higgsCombineTest.Asymptotic.mH125.mR${imass}_higgs.root
	    echo did with Higgs
	        
	    rm roostats*
	    cd ../..

	else
	    combine -M Asymptotic hgg.mH125.0_8TeV.txt >> higgsCombineTest.Asymptotic.mH125.0.mR${imass}_higgs.txt
	    mv higgsCombineTest.Asymptotic.mH120.root higgsCombineTest.Asymptotic.mH125.mR${imass}_higgs.root
	    echo did with Higgs
	        
	    rm roostats*
	    cd ../..

	fi
    done # sample
done #dirs


