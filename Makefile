CC_CUDA = nvcc

CUDA = cuda

all: $(CUDA)

$(CUDA): sha1_cuda.cu
	$(CC_CUDA) -o $@ $^ -Wno-deprecated-gpu-targets -lm -O3

.PHONY: clean runcuda

clean:
	rm -rf *.o $(CUDA)
