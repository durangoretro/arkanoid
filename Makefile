SOURCE_DIR=.
BUILD_DIR=bin
CFG ?= ../dclib/cfg/durango16k.cfg
DCLIB ?= ../dclib/bin
DCINC ?= ../dclib/inc
RESCOMP ?= ../rescomp/target/rescomp.jar

all: arkanoid.dux

$(BUILD_DIR)/title.h: breakout.png $(BUILD_DIR)
	java -jar ${RESCOMP} -n title -m BACKGROUND -i breakout.png -o $(BUILD_DIR)/title.h
	
$(BUILD_DIR)/controls.h: controls.png $(BUILD_DIR)
	java -jar ${RESCOMP} -n controls -m BACKGROUND -i controls.png -o $(BUILD_DIR)/controls.h
	
$(BUILD_DIR)/hall.h: hall.png $(BUILD_DIR)
	java -jar ${RESCOMP} -n hall -m BACKGROUND -i hall.png -o $(BUILD_DIR)/hall.h

$(BUILD_DIR)/input.h: input.png $(BUILD_DIR)
	java -jar ${RESCOMP} -n input -m BACKGROUND -i input.png -o $(BUILD_DIR)/input.h

$(BUILD_DIR)/main.casm: $(SOURCE_DIR)/main.c $(BUILD_DIR)/title.h $(BUILD_DIR)/controls.h $(BUILD_DIR)/hall.h $(BUILD_DIR) $(BUILD_DIR)/input.h $(BUILD_DIR)
	cc65 -I $(DCINC) $(SOURCE_DIR)/main.c -t none --cpu 6502 -o $(BUILD_DIR)/main.s

$(BUILD_DIR)/main.o: $(BUILD_DIR)/main.casm $(BUILD_DIR)
	ca65 -t none $(BUILD_DIR)/main.s -o $(BUILD_DIR)/main.o


$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

	
$(BUILD_DIR)/arkanoid.bin: $(BUILD_DIR)/ $(BUILD_DIR)/main.o $(DCLIB)/psv.lib $(DCLIB)/system.lib $(DCLIB)/glyph.lib $(DCLIB)/durango.lib
	ld65 -m $(BUILD_DIR)/arkanoid.txt -C $(CFG) $(BUILD_DIR)/main.o $(DCLIB)/qgraph.lib $(DCLIB)/psv.lib $(DCLIB)/system.lib $(DCLIB)/glyph.lib $(DCLIB)/durango.lib -o $(BUILD_DIR)/arkanoid.bin	

arkanoid.dux: $(BUILD_DIR)/arkanoid.bin $(BUILD_DIR)
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t ARKANOID -d "The all times classic briks game" -i $(BUILD_DIR)/arkanoid.bin -o arkanoid.dux

clean:
	rm -Rf $(BUILD_DIR) arkanoid.dux
