##################################################################
##################################################################

# run as 'bash <name>.sh'
# there is a difference between sh and bash in Debian

# recommend running with 'taskset -c 0-3 bash batcher.sh'
# limits process to a certain number of cores to prevent crashes

# doesn't like * and missing )

# check results: find . -type f | sed 's/.*\.//' | sort | uniq -c
# recent: find . -type f -printf '%T@ %p\n' | sort -n | tail -3

# setup to run from /media/<device>

##################################################################
##################################################################


################
## Create LIB ##
################

# set directories
dddir=/media/<device>
xml=$dddir/<itunes_xml>
aud=./<scalpel_audit>
outdir=$dddir/itunes_library
mkdir -p $outdir

# set first & last line in iTunes XML
i=1 # 1
end=<last_line> # $((`cat $xml | wc -l` + 1)); recommend cut before playlists part of XML

# progress variables
i_i=$(($i-1))
mat=0 # explicit declaration (not necessary)
ski=0
t_s=100 # differentiation for progress updates
t_old=`date +%s%M` # initial time stamp

# Main loop
echo
while [ $i -le $end ]

    do
    # check line in iTunes XML
    line=`cat $xml | awk "NR==$i" | tr -d "\t"`

    if [[ `expr "$line" : '\(.......................\)'` == '<key>Name</key><string>' ]]
        then # set Track Name
        tra=`echo $line | cut -d ">" -f4 | cut -d "<" -f1` # remove XML errata
        tra=${tra//#38;/} # fixes "&" issue without removing individual characters
        t_tra=`echo $tra | tr -s "/" "_"` # replaces "/" with "_" for file operations
    elif [[ `expr "$line" : '\(.........................\)'` == '<key>Artist</key><string>' ]]
        then # set Artist
        art=`echo $line | cut -d ">" -f4 | cut -d "<" -f1` # remove XML errata
        art=${art//#38;/} # fixes "&" issue without removing individual characters
    elif [[ `expr "$line" : '\(........................\)'` == '<key>Album</key><string>' ]]
        then # set Album
        alb=`echo $line | cut -d ">" -f4 | cut -d "<" -f1` # remove XML errata
        alb=${alb//#38;/} # fixes "&" issue without removing individual characters
    elif [[ `expr "$line" : '\(........................\)'` == '<key>Size</key><integer>' ]]
        then # set Size
        siz=`echo $line | cut -d ">" -f4 | cut -d "<" -f1` # remove XML errata
    elif [[ `expr "$line" : '\(...........................\)'` == '<key>Location</key><string>' ]]
        then # create folders
        fol=`echo $line | cut -d ">" -f4 | cut -d "<" -f1 | cut -d "/" -f9- | cut -d "/" -f1-3 | tr -s "%20" " "` # remove XML and folder/space errata
        fol=${fol//#38;/} # fixes "&" issue without removing individual characters
        mkdir -p $outdir/"$fol"


        # added condition to target only .nf files - should eliminate dd overlap concern from rescalp.sh
        if [[ -f $outdir/"$fol"/"$t_tra".nf ]]
            then
            # using metadata variables, find track filename(s) within rescalped files from audit.txt - VERY resource heavy
            f_n=`grep -l -P "(?=.*$tra)(?=.*$art)(?=.*$alb)" ./*/*`
            f_n=`echo $f_n | awk '{print $1;}' | cut -d "/" -f3` # blind choose first option - removes duplicate tracks?

            # if match found - write file
            if [[ $f_n ]]
                then
                # find and set up variables for dd
                arr=(`cat $aud | grep $f_n | tr -s "\t" " "`)
                bs=4096 # block size in bits
                start=$((${arr[1]}/$bs))
                len=$((siz/$bs+1)) # length of file - rounded up

                # dd file with correct length and extension to new folder structure
                dd if=$dddir/partition.dd of=$outdir/"$fol"/"$t_tra"-$f_n bs=$bs skip=$start count=$len &> /dev/null # run dd
                rm $outdir/"$fol"/"$t_tra".nf &> /dev/null # cleanup .nf file if it exists
            
                mat=$(($mat+1)) # increment match
            else
                ski=$(($ski+1)) # increment no match
            fi
            
        elif ! ls $outdir/"$fol"/"$t_tra"* &> /dev/null # if no file exists (music file or .nf), add a placeholder
            then
            # add .nf file if metadata not found and music file doesn't exist
            touch $outdir/"$fol"/"$t_tra".nf # may overwrite in some cases
            ski=$(($ski+1)) # increment no match

        fi

    fi

    # progress update
    t_new=`date +%s%M`
    if [[ $(($i%$t_s)) == 0 ]]
        then
        out=$((($end-$i)*($t_new-$t_old)/($i-$i_i)))
        eta=`date -d @$((($t_new+$out)/100)) +%H:%M:%S` # forecast
    fi
    if [[ $mat -gt 0 ]]; then acc=$(($mat*100/($mat+$ski))); else acc=0; fi # avoid divide by zero error
    echo -ne "  [ $(($i*100/$end))%  ETC: $eta ]  Lines Checked: $i / $end  Found/Skipped: $mat / $ski  [ $acc% ]\r"

    # increment position variable by 1
    i=$(($i+1))

done
echo
echo
