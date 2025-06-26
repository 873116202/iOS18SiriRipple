ARCHS = arm64
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iOS18SiriRipple

iOS18SiriRipple_FILES = $(wildcard *.m) $(wildcard *.mm)  # 包含所有.m/.mm文件
iOS18SiriRipple_CFLAGS = -fobjc-arc
iOS18SiriRipple_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
