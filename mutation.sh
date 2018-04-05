# Author: Eric Frankel
array=()
array[0]='G'
array[1]='A'
array[2]='L'
array[3]='V'
array[4]='I'
array[5]='P'
array[6]='R'
array[7]='T'
array[8]='S'
array[9]='C'
array[10]='M'
array[11]='K'
array[12]='E'
array[13]='Q'
array[14]='D'
array[15]='N'
array[16]='W'
array[17]='Y'
array[18]='F'
array[19]='H'
declare -a myArray
echo ${array[0]}
myArray=$(<'dnm1_residues.txt') # Use the following line as follows: myArray=$(<'gene_residues.txt')
echo ${myArray[0]}
mut_log=()
for ((i = 6; i < 740; i++)); do
	holder=${myArray[0]}
	lb=$i
	ub=$(($i+8))
	x="$(echo $holder | cut -c$lb-$ub)" # Cut the residues into 9-residue strings
	for ((j = 1; j < 10; j++))
		do
		first_slice="$(echo $x | cut -$(($j-1)))" # Cut the first portion of gene residues
		second_slice="$(echo $x | cut -c$(($j+1))-10)" # Cut the second portion of gene residues
		for residue in ${array[@]};
		do
			corr_residue="$(echo $holder | cut -c$(($i+$j-1))-$(($i+$j-1)))"
			mut="$corr_residue$((4+$i+$j))$residue"
			alreadyin=false
			for mutation in "${mut_log[@]}"
			do
				if [ "$mut" == "$mutation" ];
					then
					alreadyin=true
				fi
			done
			if [ "$alreadyin" == "true" ];
				then
				continue
			else
				mut_log+=("$mut")
			fi
			nine_slice="$(echo $first_slice$residue$second_slice)" # Makes mutant residue string
			> mutant_file.txt # Clears the mutant_file
			echo $x >> mutant_file.txt; # Writes normal residue string to mutant file
			echo $nine_slice >> mutant_file.txt; # Writes mutant residue string to mutant file
			~/Desktop/foldx/foldx --command=BuildModel --pdb=3snh_Repair.pdb --mutant-file=mutant_file.txt --ionStrength=0.05 --pH=7 --water=CRYSTAL --vdwDesign=2 --pdbHydrogens=false #--numberOfRuns=100
			rm WT*
			rm 3snh_Repair_*
			rm PdbList*
			rm Dif_3snh*
			rm Raw_3snh*
			mv Average_3snh_Repair.fxout Average_3snh_Repair.txt
			TAB=$'\t'
			NLINE=$'\n'
			cp Average_3snh_Repair.txt temp.txt
			sed -i".bak" '1,9d' temp.txt
			sed -e '$s/$/'"${TAB}"''"${mut}"'/' temp.txt >> temp.txt
			sed -i".bak" '1d' temp.txt
			for line in temp.txt
			do
				echo -e '\n'
				cat $line
			done >> results.txt
			> temp.txt
			rm Average_3snh_Repair.txt
		done
		# Sanity check for correct output of the 9 slice. Comment out prior for loop
		# then run the following two lines of code.
	done
done