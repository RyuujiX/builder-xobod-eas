#!/usr/bin/env bash
echo "Cloning dependencies"
git clone https://github.com/RyuujiX/kernel-xobod-eas -b master source
cd source
git clone --depth=1 https://github.com/ZyCromerZ/DragonTC -b daily/10.0 clang
git clone https://github.com/sohamxda7/llvm-stable -b gcc64 --depth=1 gcc
git clone https://github.com/sohamxda7/llvm-stable -b gcc32  --depth=1 gcc32
git clone --depth=1 https://github.com/RyuujiX/AnyKernel3 -b master AnyKernel
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
COMMIT=$(git log --pretty=format:'%h' -1)
VARIANT="Raiton"
KERNEL_DIR=$(pwd)
VERSI=(""4.4.$(cat "$(pwd)/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')$(cat "$(pwd)/Makefile" | grep "EXTRAVERSION =" | sed 's/EXTRAVERSION = *//g')"")
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_HOST=CircleCI
export KBUILD_BUILD_USER="RyuujiX"

# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendSticker" \
        -d sticker="CAACAgEAAxkBAAEnKnJfZOFzBnwC3cPwiirjZdgTMBMLRAACugEAAkVfBy-aN927wS5blhsE" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• $VARIANT Kernel •</b>%0ABuild started on <code>Circle CI</code>%0AFor device <b>Asus Zenfone Max Pro M2</b> (X01BD)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#Stable"
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Asus Zenfone Max Pro M2 (X01BD)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}

# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

# Compile plox
function compile() {
    make O=out ARCH=arm64 X01BD_defconfig
    make -j$(nproc --all) O=out \
                    ARCH=arm64 \
                  	CC="$(pwd)/clang/bin/clang" \
                    CLANG_TRIPLE="aarch64-linux-gnu-"

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    sed -i "s/kernel.string=.*/kernel.string=${VARIANT}-$COMMIT by RyuujiX/g" anykernel.sh
    zip -r9 [$TANGGAL]${VERSI}-${VARIANT}.zip * -x .git *placeholder README.md
    cd ..
}

sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
