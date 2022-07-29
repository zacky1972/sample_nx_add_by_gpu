.phony: all clean

PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so

ifeq ($(shell uname -s),Linux)
ifeq ($(NVCC),)
NVCC = $(shell which nvcc)
ifeq ($(NVCC),)
$(error Could not find nvcc. set path to nvcc)
endif
endif
ifneq ($(NVCC),)
CUDA_PATH = $(shell elixir --eval "\"$(NVCC)\" |> Path.split() |> Enum.drop(-2) |> Path.join() |> IO.puts")
CFLAGS += -DCUDA
CUFLAGS += -DCUDA -I$(CUDA_PATH)/include --compiler-options -fPIC
CULDFLAGS += -L$(CUDA_PATH)/lib64
endif
endif

ifeq ($(CROSSCOMPILE),)
ifeq ($(shell uname -s),Linux)
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
else # macOS
LDFLAGS += -undefined dynamic_lookup -dynamiclib
endif
else
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
endif

ifeq ($(ERL_EI_INCLUDE_DIR),)
ERLANG_PATH = $(shell elixir --eval ':code.root_dir |> to_string() |> IO.puts')
ifeq ($(ERLANG_PATH),)
$(error Could not find the Elixir installation. Check to see that 'elixir')
endif
ERL_EI_INCLUDE_DIR = $(ERLANG_PATH)/usr/include
ERL_EI_LIB_DIR = $(ERLANG_PATH)/usr/lib
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

NIF_SRC_DIR = nif_src
C_SRC = $(NIF_SRC_DIR)/libnif.c
C_OBJ = $(C_SRC:$(NIF_SRC_DIR)/%.c=$(BUILD)/%.o)

CUDA_SRC_DIR = $(NIF_SRC_DIR)/cuda
CU_SRC = $(CUDA_SRC_DIR)/vectorAdd.cu
CU_OBJ = $(CU_SRC:$(CUDA_SRC_DIR)/%.cu=$(BUILD)/%.o)

all: $(PRIV) $(BUILD) $(NIF)

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: $(NIF_SRC_DIR)/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

ifneq ($(NVCC),)
$(BUILD)/%.o: $(CUDA_SRC_DIR)/%.cu
	@echo " NVCC $(notdir $@)"
	$(NVCC) $(CUFLAGS) -c -o $@ $<
endif

ifneq ($(NVCC),)
$(NIF): $(C_OBJ) $(CU_OBJ)
	@echo " LD $(notdir $@)"
	$(NVCC) -o $@ $(ERL_LDFLAGS) $(CULDFLAGS) --compiler-options $(LDFLAGS) $^
else
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
endif

clean:
	$(RM) $(NIF) $(C_OBJ) $(CU_OBJ)
