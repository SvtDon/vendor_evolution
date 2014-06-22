PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/evolution/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/evolution/prebuilt/common/bin/50-evolution.sh:system/addon.d/50-evolution.sh \
    vendor/evolution/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/evolution/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# EVOLUTION-specific init file
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/etc/init.local.rc:root/init.evolution.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/lib/libjni_latinime.so:system/lib/libjni_latinime.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/etc/mkshrc:system/etc/mkshrc \
    vendor/evolution/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/evolution/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/evolution/prebuilt/common/bin/sysinit:system/bin/sysinit

# Workaround for NovaLauncher zipalign fails
PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/app/NovaLauncher.apk:system/app/NovaLauncher.apk

# Embed SuperUser
SUPERUSER_EMBEDDED := true

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    SpareParts \
    Superuser \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic \
    HoloSpiralWallpaper \
    NoiseField \
    Galaxy4 \
    LiveWallpapersPicker \
    PhaseBeam

# DSPManager
PRODUCT_PACKAGES += \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf

# Extra Optional packages
PRODUCT_PACKAGES += \
    LatinIME \
    BluetoothExt

# Extra tools
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/evolution/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/evolution/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/evolution/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

# version
RELEASE = false
EVOLUTION_VERSION_MAJOR = 1
EVOLUTION_VERSION_MINOR = 0

# release
ifeq ($(RELEASE),true)
    EVOLUTION_VERSION_STATE := OFFICIAL
    EVOLUTION_VERSION := EVOLUTION-KK-v$(EVOLUTION_VERSION_MAJOR).$(EVOLUTION_VERSION_MINOR)-$(EVOLUTION_VERSION_STATE)
else
    EVOLUTION_VERSION_STATE := $(shell date +%Y-%m-%d)
    EVOLUTION_VERSION := EVOLUTION-KK-v$(EVOLUTION_VERSION_MAJOR).$(EVOLUTION_VERSION_MINOR)-$(EVOLUTION_VERSION_STATE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.evolution.version=$(EVOLUTION_VERSION) \
    ro.evolution.buildtype=$(EVOLUTION_BUILD_TYPE)
