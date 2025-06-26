ARCHS = arm64
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iOS18SiriRipple

iOS18SiriRipple_FILES = Tweak.xm
iOS18SiriRipple_CFLAGS = -fobjc-arc
iOS18SiriRipple_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
