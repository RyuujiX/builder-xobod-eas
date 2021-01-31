#! /bin/bash
branch="lynx-uvc"
BuilderKernel="gcc"

if [ "$BuilderKernel" != "clang" ] && [ "$BuilderKernel" != "dtc" ] && [ "$BuilderKernel" != "gcc" ] && [ "$BuilderKernel" != "storm" ] && [ "$BuilderKernel" != "mystic" ] ;then
    exit;
fi
. main.sh 'initial' 'full'

FolderUp="BrokenNucleus"
spectrumFile="ishigami.rc"
TypeBuild="Test"
TypeBuildTag="Awokawok"
getInfo ">> Building kernel . . . . <<"

CompileKernel
CompileKernel "65"
CompileKernel "68"
CompileKernel "71"
# CompileKernel "72"

FixPieWifi

CompileKernel
CompileKernel "65"
CompileKernel "68"
CompileKernel "71"
# CompileKernel "72"

tg_send_info "Semua $GetKernelName $BuilderKernel dah selesai dibuild tod :v"