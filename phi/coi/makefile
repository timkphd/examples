
DEV_CC_DIR = /usr/linux-k1om-4.7/bin
DEV_DIR = /opt/intel/mic
COI_DIR = $(DEV_DIR)/coi
COI_INC = -I $(COI_DIR)/include
DEV_FLAGS = $(COI_INC) -lcoi_device -rdynamic -Wl,--enable-new-dtags
HOST_FLAGS = $(COI_INC) -lcoi_host -Wl,--enable-new-dtags
DEBUG_FLAGS = -g -O0 -D_DEBUG
RELEASE_FLAGS = -DNDEBUG -O3
DEBUG_DIR = debug
RELEASE_DIR = release

HOST_CC = g++ -fopenmp
DEV_CC = $(DEV_CC_DIR)/x86_64-k1om-linux-g++

#all: $(DEBUG_DIR)/hello_world_source_host $(DEBUG_DIR)/hello_world_sink_mic \
all: \
     $(RELEASE_DIR)/hello_world_source_host $(RELEASE_DIR)/hello_world_sink_mic

release: $(RELEASE_DIR)/hello_world_source_host $(RELEASE_DIR)/hello_world_sink_mic

debug: $(DEBUG_DIR)/hello_world_source_host $(DEBUG_DIR)/hello_world_sink_mic \

$(DEBUG_DIR)/hello_world_source_host: hello_world_source.cpp
	mkdir -p $(DEBUG_DIR)
	$(HOST_CC) -L$(COI_DIR)/host-linux-debug/lib -Wl,-rpath=$(COI_DIR)/host-linux-debug/lib $(HOST_FLAGS) $(DEBUG_FLAGS) -o $@ $<

$(RELEASE_DIR)/hello_world_source_host: hello_world_source.cpp
	mkdir -p $(RELEASE_DIR)
	$(HOST_CC) -L$(COI_DIR)/host-linux-release/lib -Wl,-rpath=$(COI_DIR)/host-linux-release/lib $(HOST_FLAGS) $(RELEASE_FLAGS) -o $@ $<

$(DEBUG_DIR)/hello_world_sink_mic: hello_world_sink.cpp
	mkdir -p $(DEBUG_DIR)
	$(DEV_CC) -L$(COI_DIR)/device-linux-debug/lib $(DEV_FLAGS) $(DEBUG_FLAGS) -o $@ $<

$(RELEASE_DIR)/hello_world_sink_mic: hello_world_sink.cpp
	mkdir -p $(RELEASE_DIR)
#	$(DEV_CC) -openmp -L$(COI_DIR)/device-linux-release/lib $(DEV_FLAGS) $(RELEASE_FLAGS) -o $@ $<
	icc -mmic  -openmp -L/opt/intel/mic/coi/device-linux-release/lib -I /opt/intel/mic/coi/include -lcoi_device -rdynamic -Wl,--enable-new-dtags -DNDEBUG -O3 -o release/hello_world_sink_mic hello_world_sink.cpp -qopenmp-link=static
	cp $(RELEASE_DIR)/hello_world_sink_mic ~

clean:
	rm -rf debug
	rm -rf release
	rm -rf *.script hosts* slurm*out
