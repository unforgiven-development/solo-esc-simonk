# This Makefile is compatible with both BSD and GNU make

ASM     ?= avra
SHELL    = /bin/bash
AVRDUDE ?= avrdude
UISP    ?= uisp

STK500V2_PORT ?= /dev/ttyUSB0

AVRDUDE_MCU ?= m8


MOTOR_ADVANCE   ?= 18
TIMING_OFFSET   ?= 0
MOTOR_BRAKE     ?= 0
LOW_BRAKE       ?= 0
MOTOR_REVERSE   ?= 0
RC_PULS_REVERSE ?= 0
CHECK_HARDWARE  ?= 0
#MIN_DUTY        ?= 56	# default for 16 MHz F_CPU
#POWER_RANGE     ?= 856	# default for 16 MHz F_CPU
START_DELAY_US  ?= 0	# initial post-commutation wait during starting



DEFINES := -D TIMING_OFFSET=$(TIMING_OFFSET)
DEFINES += -D MOTOR_BRAKE=$(MOTOR_BRAKE)
DEFINES += -D LOW_BRAKE=$(LOW_BRAKE)
DEFINES += -D MOTOR_REVERSE=$(MOTOR_REVERSE)
DEFINES += -D RC_PULS_REVERSE=$(RC_PULS_REVERSE)
#DEFINES += -D START_DELAY_US=$(START_DELAY_US)
#DEFINES += -D MOTOR_ADVANCE=$(MOTOR_ADVANCE)
#DEFINES += -D CHECK_HARDWARE=$(CHECK_HARDWARE)


FLASH_HEX_FILE  := flash.hex
EEPROM_HEX_FILE := eeprom.hex


.SUFFIXES: .inc .hex


ALL_TARGETS = \
		afro.hex \
		afro2.hex \
		afro_hv.hex \
		afro_nfet.hex \
		arctictiger.hex \
		birdie70a.hex \
		bs_nfet.hex \
		bs.hex \
		bs40a.hex \
		dlu40a.hex \
		dlux.hex \
		hk200a.hex \
		hm135a.hex \
		kda.hex \
		mkblctrl1.hex \
		rb50a.hex \
		rb70a.hex \
		rct50a.hex \
		tbs.hex \
		tp.hex \
		tp_8khz.hex \
		tp_i2c.hex \
		tp_nfet.hex \
		tp70a.hex \
		tgy6a.hex \
		tgy.hex

AUX_TARGETS = diy0.hex



all: $(ALL_TARGETS)

$(ALL_TARGETS): tgy.asm boot.inc
$(AUX_TARGETS): tgy.asm boot.inc


.inc.hex:
	@test -e $*.asm || ln -s tgy.asm $*.asm
	@echo -ne "\n================================================================================\n"
	@echo -e "\033[1m$(ASM) -fI -o $@ -D $*_esc $(DEFINES) -e $*.eeprom -d $*.obj $*.asm\033[0m\n"
	@set -o pipefail; $(ASM) -fI -o $@ -D $*_esc $(DEFINES) -e $*.eeprom -d $*.obj $*.asm 2>&1 | sed '/.*PRAGMA.*directive currently ignored/d'
	@test -L $*.asm && rm -f $*.asm || true
	@echo -ne "================================================================================\n"

test: all

clean:
	-rm -f $(ALL_TARGETS) *.obj *.eep.hex *.eeprom


program_solo: all
	$(AVRDUDE) -c avrispmkII -p $(AVRDUDE_MCU) -U flash:w:bs_nfet.hex:i
	$(AVRDUDE) -c avrispmkII -p $(AVRDUDE_MCU) -U lfuse:w:0x3f:m -U hfuse:w:0xd7:m


binary_zip: $(ALL_TARGETS)
	TARGET="tgy_`date '+%Y-%m-%d'`_`git rev-parse --verify --short HEAD`.zip"; \
	git archive -9 -o "$$TARGET" HEAD && \
	zip -9 "$$TARGET" $(ALL_TARGETS) && ls -l "$$TARGET"


program_tgy_%: %.hex
	$(AVRDUDE) -c stk500v2 -b 9600 -P $(STK500V2_PORT) -u -p $(AVRDUDE_MCU) -U flash:w:$<:i

program_usbasp_%: %.hex
	$(AVRDUDE) -c usbasp -B.5 -p $(AVRDUDE_MCU) -U flash:w:$<:i

program_avrisp2_%: %.hex
	$(AVRDUDE) -c avrisp2 -p $(AVRDUDE_MCU) -U flash:w:$<:i

program_dragon_%: %.hex
	$(AVRDUDE) -c dragon_isp -p $(AVRDUDE_MCU) -P usb -U flash:w:$<:i

program_dapa_%: %.hex
	$(AVRDUDE) -c dapa -p $(AVRDUDE_MCU) -U flash:w:$<:i

program_jtagice3_isp_%: %.hex
	$(AVRDUDE) -c jtagice3_isp -p $(AVRDUDE_MCU) -P usb -U flash:w:$<:i

program_uisp_%: %.hex
	$(UISP) -dprog=dapa --erase --upload --verify -v if=$<


bootload_usbasp:
	$(AVRDUDE) -c usbasp -u -p $(AVRDUDE_MCU) -U hfuse:w:`avrdude -c usbasp -u -p m8 -U hfuse:r:-:h | sed -n '/^0x/{s/.$$/a/;p}'`:m


read: read_tgy

read_tgy:
	$(AVRDUDE) -c stk500v2 -b 9600 -P $(STK500V2_PORT) -u -p $(AVRDUDE_MCU) -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_usbasp:
	$(AVRDUDE) -c usbasp -u -p $(AVRDUDE_MCU) -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_avrisp2:
	$(AVRDUDE) -c avrisp2 -p $(AVRDUDE_MCU) -P usb -v -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_dragon:
	$(AVRDUDE) -c dragon_isp -p $(AVRDUDE_MCU) -P usb -v -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_dapa:
	$(AVRDUDE) -c dapa -p $(AVRDUDE_MCU) -v -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_jtagice3_isp:
	$(AVRDUDE) -c jtagice3_isp -p $(AVRDUDE_MCU) -P usb -v -U flash:r:$(FLASH_HEX_FILE):i -U eeprom:r:$(EEPROM_HEX_FILE):i

read_uisp:
	$(UISP) -dprog=dapa --download -v of=$(FLASH_HEX_FILE)

