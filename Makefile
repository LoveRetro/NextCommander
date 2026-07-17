ifeq (,$(PLATFORM))
PLATFORM=$(UNION_PLATFORM)
endif

#ifeq ($(PLATFORM),miyoomini)
#CXXFLAGS := -Os -marm -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -march=armv7ve+simd
#else
CXXFLAGS := -Os
#endif

# platform dependant stuff - tg5040 and tg5050
ifneq (,$(findstring tg50,$(PLATFORM)))
SDCARD_ROOT := /mnt/SDCARD
NEXTUI_SYSTEM_PATH := $(SDCARD_ROOT)/.system

CXXFLAGS += -DPATH_DEFAULT=\"$(SDCARD_ROOT)\"
CXXFLAGS += -DPATH_DEFAULT_RIGHT=\"$(SDCARD_ROOT)\"
CXXFLAGS += -DFILE_SYSTEM=\"/dev/mmcblk1p1\"

# Keys
# Joys for Trimui Brick/Smart Pro/Smart Pro S
CXXFLAGS += -DCMDR_KEY_UP=SDLK_UP
CXXFLAGS += -DCMDR_KEY_RIGHT=SDLK_RIGHT
CXXFLAGS += -DCMDR_KEY_DOWN=SDLK_DOWN
CXXFLAGS += -DCMDR_KEY_LEFT=SDLK_LEFT
CXXFLAGS += -DCMDR_KEY_OPEN=1		# A
CXXFLAGS += -DCMDR_KEY_PARENT=0		# B
CXXFLAGS += -DCMDR_KEY_OPERATION=3	# X
CXXFLAGS += -DCMDR_KEY_SYSTEM=2		# Y
CXXFLAGS += -DCMDR_KEY_PAGEUP=4		# L1 / L2 = SDLK_TAB
CXXFLAGS += -DCMDR_KEY_PAGEDOWN=5	# R1 / R2 = SDLK_BACKSPACE
CXXFLAGS += -DCMDR_KEY_SELECT=6		# 8		# SELECT
CXXFLAGS += -DCMDR_KEY_TRANSFER=7	# 9	# START
CXXFLAGS += -DCMDR_KEY_MENU=8		# 19		# MENU (added)

# Screen
CXXFLAGS += -DAUTOSCALE=1
CXXFLAGS += -DAUTOSCALE_DPI=1

#CXXFLAGS += -DSCREEN_WIDTH=1024 #640
#CXXFLAGS += -DSCREEN_HEIGHT=768 #480
# Brick: 1024x768 @3in, 400ppi -> 400/72 = 5.55555 PPU -> we use 4 (font size 32)
# TSP(s): 1280x720 @5in, 296ppi -> 296/72 = 4.11111 PPU -> we use 3 (font size 24)
CXXFLAGS += -DPPU_X=3
CXXFLAGS += -DPPU_Y=3
CXXFLAGS += -DSCREEN_BPP=32

# platform dependant stuff - my355
else ifneq (,$(findstring my355,$(PLATFORM)))
SDCARD_ROOT := /mnt/SDCARD
NEXTUI_SYSTEM_PATH := $(SDCARD_ROOT)/.system

CXXFLAGS += -DPATH_DEFAULT=\"$(SDCARD_ROOT)\"
CXXFLAGS += -DPATH_DEFAULT_RIGHT=\"$(SDCARD_ROOT)\"
CXXFLAGS += -DFILE_SYSTEM=\"/dev/mmcblk1p1\"

# Keys
# Joys for Miyoo Flip
CXXFLAGS += -DCMDR_KEY_UP=SDLK_UP
CXXFLAGS += -DCMDR_KEY_RIGHT=SDLK_RIGHT
CXXFLAGS += -DCMDR_KEY_DOWN=SDLK_DOWN
CXXFLAGS += -DCMDR_KEY_LEFT=SDLK_LEFT
CXXFLAGS += -DCMDR_KEY_OPEN=1		# A
CXXFLAGS += -DCMDR_KEY_PARENT=0		# B
CXXFLAGS += -DCMDR_KEY_OPERATION=3	# X
CXXFLAGS += -DCMDR_KEY_SYSTEM=2		# Y
CXXFLAGS += -DCMDR_KEY_PAGEUP=4		# L1 / L2 = SDLK_TAB
CXXFLAGS += -DCMDR_KEY_PAGEDOWN=5	# R1 / R2 = SDLK_BACKSPACE
CXXFLAGS += -DCMDR_KEY_SELECT=6		# 8		# SELECT
CXXFLAGS += -DCMDR_KEY_TRANSFER=7	# 9	# START
CXXFLAGS += -DCMDR_KEY_MENU=8		# 19		# MENU (added)
CXXFLAGS += -DIGNORE_KEYDOWN=1      # miyoo inputd doubles up events
CXXFLAGS += -DIGNORE_TEXTINPUT=1    # miyoo inputd also emits phantom SDL_TEXTINPUT

# Screen
CXXFLAGS += -DAUTOSCALE=1
CXXFLAGS += -DAUTOSCALE_DPI=1

#CXXFLAGS += -DSCREEN_WIDTH=1024 #640
#CXXFLAGS += -DSCREEN_HEIGHT=768 #480
# Miyoo Flip: 640x480 @3.5in, 229ppi -> 229/72 = 3.1805 PPU -> we use 3 (font size 24)
CXXFLAGS += -DPPU_X=3
CXXFLAGS += -DPPU_Y=3
CXXFLAGS += -DSCREEN_BPP=32
endif

SDL := SDL2
CXXFLAGS += -I$(PREFIX)/include/$(SDL) -DUSE_$(SDL)

#CXXFLAGS += $$(pkg-config --cflags sdl2 SDL2_image SDL2_ttf)
#LINKFLAGS += $$(pkg-config --libs sdl2 SDL2_image SDL2_ttf)

# Font
CXXFLAGS += -DFONTS='{"$(NEXTUI_SYSTEM_PATH)/res/font1.ttf",8},{"SourceCodePro-Semibold.ttf",8},{"SourceCodePro-Regular.ttf",8}'
ifeq ($(PLATFORM),miyoomini)
CXXFLAGS += -DMIYOOMINI
endif

RESDIR := res
CXXFLAGS += -DRESDIR="\"$(RESDIR)\""

LINKFLAGS += -s
LINKFLAGS += -l$(SDL) -l$(SDL)_image -l$(SDL)_ttf
ifeq ($(PLATFORM),miyoomini)
LINKFLAGS += -lmi_sys -lmi_gfx
endif

CMD := @
SUM := @echo

OUTDIR := ./output

EXECUTABLE := $(OUTDIR)/NextCommander

OBJS :=	main.o commander.o config.o dialog.o fileLister.o fileutils.o keyboard.o panel.o resourceManager.o \
	screen.o sdl_ttf_multifont.o sdlutils.o text_edit.o utf8.o text_viewer.o image_viewer.o  window.o \
	sdl_gfx/$(SDL)_rotozoom.o
ifeq ($(PLATFORM),miyoomini)
OBJS += gfx.o
endif

DEPFILES := $(patsubst %.o,$(OUTDIR)/%.d,$(OBJS))

.PHONY: all clean

all: $(EXECUTABLE)

$(EXECUTABLE): $(addprefix $(OUTDIR)/,$(OBJS))
	$(SUM) "  LINK    $@"
	$(SUM) "  LINK    $(LINKFLAGS)"
	$(CMD)$(CXX) $(LINKFLAGS) -o $@ $^

$(OUTDIR)/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(SUM) "  CXX     $@"
	$(CMD)$(CXX) $(CXXFLAGS) -MP -MMD -MF $(@:%.o=%.d) -c $< -o $@
	@touch $@ # Force .o file to be newer than .d file.

$(OUTDIR)/%.o: src/%.c
	@mkdir -p $(@D)
	$(SUM) "  CXX     $@"
	$(CMD)$(CXX) $(CXXFLAGS) -MP -MMD -MF $(@:%.o=%.d) -c $< -o $@
	@touch $@ # Force .o file to be newer than .d file.

clean:
	$(SUM) "  RM      $(OUTDIR)"
	$(CMD)rm -rf $(OUTDIR)

# Load dependency files.
-include $(DEPFILES)

# Generate dependencies that do not exist yet.
# This is only in case some .d files have been deleted;
# in normal operation this rule is never triggered.
$(DEPFILES):
