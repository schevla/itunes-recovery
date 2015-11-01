##################################################################
##################################################################

# run as 'bash <name>.sh'
# there is a difference between sh and bash in Debian

# setup to run from /media/<device>

##################################################################
##################################################################

# initialization variables
ext='M4A' # set extension
find='iTunes' # search term (MP3: engiTun, M4A: iTunes)
off=35 # offset to intial line of data in audit file
bs=4096 # block size in bits
dd_o=210 # dd offset in blocks - looks at "next" part of file - be careful not to exceed file length (overlap)
len=40 # number of blocks to extract (HUGE factor in master.sh run time)

# set dd & output directory
dddir=/media/<device>
outdir=./$ext # recommend adding trial numbers
mkdir -p $outdir

# generate found file list for check
find $dddir/itunes_library -name "*.$ext" | awk '{print substr($0,length-11,12)}' > found_$ext.txt

# last line of data
end=$((`cat audit.txt | wc -l` - $off + 1 - 3)) # modified to ignore end of audit log

# progress variables
i=1 # 1
i_i=$(($i-1))
mat=0 # 0 - explicit declaration (not necessary)
t_s=100 # differentiation for progress updates
t_old=`date +%s%M` # initial time stamp

# Main loop
echo
echo "Looking for .$ext files from audit.txt containing: \"$find\""
while [ $i -le $end ]

    do
    # set array from audit line
    arr=(`cat audit.txt | awk "NR==$(($i + $off - 1))" | tr -s "\t" " "`)

    # initialization variables
    name=${arr[0]}
    start=$((${arr[1]}/$bs+$dd_o)) # with dd offset

    # check for extension match & that it hasn't already been found
    if [[ `echo $name | tail -c +10` == $ext && ! `grep $name ./found_$ext.txt` ]]
        then

        # run dd slice command and set as temp file (silenced terminal output)
        dd if=$dddir/partition.dd of=$outdir/temp bs=$bs skip=$start count=$len &> /dev/null

        # check for find var -> rename to preserve (this is for mp3 files ripped into iTunes, for now)
        if [[ `grep $find $outdir/temp` ]] # VERY resource heavy
            then
            mv $outdir/temp $outdir/$name # create unique file for match
            mat=$(($mat+1)) # increment match progress variable
        fi
    fi

    # progress update
    t_new=`date +%s%M`
    if [[ $(($i%$t_s)) == 0 ]]
        then
        out=$((($end-$i)*($t_new-$t_old)/($i-$i_i)))
        eta=`date -d @$((($t_new+$out)/100)) +%H:%M:%S` # forecast
    fi
    echo -ne "  [ $(($i*100/$end))%  ETC: $eta ]    Files Checked: $i / $end    dd: $mat\r"

    # increment iteration variable by 1
    i=$(($i+1))

    done
echo
echo

# remove temp file
rm $outdir/temp
