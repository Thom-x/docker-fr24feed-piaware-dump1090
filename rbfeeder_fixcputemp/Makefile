CFLAGS := $(CFLAGS) -fPIC -Wall

TARGET = librbfeeder_fixcputemp

all: $(TARGET).so

$(TARGET).so: $(TARGET).o
	$(CC) $^ -shared -o $@

clean:
	rm *.so *.o
