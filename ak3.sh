date=$(date)
# Build Any-Kernel Zip Script 
KERNELBUILDOUTPUT=$(cat config.prop | grep KERNEL_BUILD_OUTPUT= | sed 's/KERNEL_BUILD_OUTPUT=//g')
AK3OUTPUT=$(cat config.prop | grep AK3_INSTALLER_ZIP_CREATOR_TOOL_OUTPUT_LOCATION= | sed 's/AK3_INSTALLER_ZIP_CREATOR_TOOL_OUTPUT_LOCATION=//g')
case $1 in

   -d)
    devicesel=$2
    ;;

  --device)
    devicesel=$2
    ;;

  --clear-cache)
    cd ak3-setup
    rm -fr Dtb Kernel
    mkdir Dtb
    mkdir Kernel
    mkdir Dtb/starlte
    mkdir Dtb/star2lte
    mkdir Dtb/crownlte
    mkdir Kernel/starlte
    mkdir Kernel/star2lte
    mkdir Kernel/crownlte
    echo "Caches Purged"
    exit 0
    ;;
    
  *)
    echo "`basename ${0}`:usage: 
    -d <device_codename>
    --device <device_codename> 
    Available Entries: starlte , star2lte , crownlte , exy9810 # Make A Single Zip For All 3 Devices
    --clear-cache # Delete Previous dtb.img And zImage" 
    exit 1
    ;;
esac
case $devicesel in

  starlte | star2lte | crownlte)
    devicename=$2
    device=$2
    ;;

  exy9810)
    skipzip=1
    if [ $3 = ] 2> /dev/null
    then
    echo "Usage: 
    --current <device_codename> 
    --finish # Make A Zip For All Devices
    
    Ex:
    ./ak3.sh -d exy9810 --current star2lte
    ./ak3.sh -d exy9810 --current starlte
    ./ak3.sh -d exy9810 --current crownlte
    ./ak3.sh -d exy9810 --finish
    "
    elif [ $3 = --finish ]
    then
    echo Making A Zip...
    else
    echo Skipping Zip 
    echo Execute ./ak3.sh -d exy9810 --finish To Zip
    fi 
    devicename=Exynos9810
    ;;

  *)
    echo -n "Value Out Of Range 
Valid Values= starlte , star2lte , crownlte , exy9810"
    exit 1
    ;;
esac
case $3 in
   --current)
     device=$4
     ;;
     
   --finish)
     skipzip=0
     ;;
esac
if [ $(ls $KERNELBUILDOUTPUT/arch/arm64/boot/ | grep dtb.img) = dtb.img ] 2> /dev/null && [ $(ls $KERNELBUILDOUTPUT/arch/arm64/boot/ | grep Image | sed 's/Image.gz//g') = Image ] 2> /dev/null
then
 if [ $3 = --finish ] 2> /dev/null
 then
 exit
 else
 cp -f $KERNELBUILDOUTPUT/arch/arm64/boot/dtb.img ak3-setup/Dtb/"$device"/dtb.img
 cp -f $KERNELBUILDOUTPUT/arch/arm64/boot/Image ak3-setup/Kernel/"$device"/zImage
 fi
 if [ $skipzip = 1 ] 2>/dev/null
 then
 exit
 else
  cd ak3-setup
   if [ $USER = rishik ] 2> /dev/null
   then
   AUTHOR="@xxrishikcooIN"
   KERNELNAME="Exy9810-KSUOC"
   DISPLAYNAME="Exy9810-KSUOC-$2"
   CREDITS="@xxmustafacooTR (Kernel Source) -
@ratheh , @dylanneve1 And @samsungexynos9810 Kernel Devs (Kernel Source)
@JeyKul"
   NOTE="Note: This Kernel Is NOT A PART OF Mustafa's xxTR KERNELS And Do Not Blame Mustafa OR Faiz For Any Issues Related To This Kernel.

NOTE : YOU SHOULD CONFIGURE CPU FREQUENCIES IN xxTR Kernel Manager APP TO AVOID ISSUES
It Is Recommended To Lock Frequencies @1794MHz
"
   else
    if [ $(cat ..config.prop | grep AUTHOR= | sed 's/AUTHOR=//d') = ] 2> /dev/null && [ $(cat ..config.prop | grep KERNELNAME= | sed 's/KERNELNAME=//d') = ] 2> /dev/null && [ $(cat ..config.prop | grep KERNELVERSION= | sed 's/KERNELVERSION=//d') = ] 2> /dev/null
    then
    echo Please Fill config.prop To Continue
    exit 1
    else
    AUTHOR=$(cat ../config.prop | grep AUTHOR= | sed 's/AUTHOR=//g')
    KERNELNAME=$(cat ../config.prop | grep KERNELNAME= | sed 's/KERNELNAME=//g')
     if [ $device = exy9810 ] 2> /dev/null
     then
     DISPLAYNAME="4.9.337-$KERNELNAME"
     else
     DISPLAYNAME=4.9.337$(cat ../arch/arm64/configs/exynos9810-"$2"_defconfig | grep CONFIG_LOCALVERSION=  | sed 's/CONFIG_LOCALVERSION=//g' | sed 's/"//g')
     fi
    KERNELVERSION=$(cat ../config.prop | grep VERSION= | sed 's/VERSION=//g')
    CREDITS=$(cat ../config.prop | grep CREDITS= | sed 's/CREDITS=//g')
    NOTE=$(cat ../config.prop | grep NOTE= | sed 's/NOTE=//g')
    fi
   fi
  echo "$KERNELNAME For $devicename
By $AUTHOR
$CREDITS

Kernel Name: $DISPLAYNAME
Version: $KERNELVERSION
Installer Zip Creation Time/Date: $date
Device: $devicename

$NOTE" > version
  zip -r Kernel_"$devicename"_"$date".zip *
  rm -f version && touch version
   if [ $CLEARCACHE = 1 ] 2> /dev/null
   then
   rm -fr Kernel Dtb
   mkdir -p Kernel/starlte Kernel/star2lte Kernel/crownlte Dtb/starlte Dtb/star2lte Dtb/crownlte
   fi
 mv -f Kernel_"$devicename"_"$date".zip $AK3OUTPUT
 exit 1
 fi
else
echo "Required Files Not Found

Specify The Path At ../config.prop

KERNEL_BUILD_OUPUT=</path/to/kernel/build/output>   
AK3_INSTALLER_ZIP_CREATOR_TOOL_OUTPUT_LOCATION=</path/for/ak3/zip/output>

And Make Sure That You Have Filled All The Important Props"
fi
