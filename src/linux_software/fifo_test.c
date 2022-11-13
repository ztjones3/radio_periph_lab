#include <stdio.h>
#include <sys/mman.h> 
#include <fcntl.h> 
#include <unistd.h>
#define _BSD_SOURCE

#define RADIO_TUNER_FAKE_ADC_PINC_OFFSET 0
#define RADIO_TUNER_TUNER_PINC_OFFSET 1
#define RADIO_TUNER_CONTROL_REG_OFFSET 2
#define RADIO_TUNER_TIMER_REG_OFFSET 3
#define RADIO_PERIPH_ADDRESS 0x43c00000
#define FIFO_PERIPH_ADDRESS 0x43c20000
#define FIFO_COUNT_REG_OFFSET 0
#define FIFO_DATA_REG_OFFSET 1

// the below code uses a device called /dev/mem to get a pointer to a physical
// address.  We will use this pointer to read/write the custom peripheral
volatile unsigned int * get_a_pointer(unsigned int phys_addr)
{

    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    void *map_base = mmap(0, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, phys_addr);
    volatile unsigned int *radio_base = (volatile unsigned int *)map_base;
    return (radio_base);
}

void read_fifo(volatile unsigned int *periph_base){
    int words_read        = 0;
    int num_words_in_fifo = 0;
    float fifo_data       = 0.0;
    while(words_read < 480000){
        //printf("Number of words read: %d\n", words_read);
        num_words_in_fifo = *(periph_base+FIFO_COUNT_REG_OFFSET);
        if(num_words_in_fifo > 0){
            //printf("Number of samples in the FIFO: %d\n", num_words_in_fifo);
            for(int i = 0; i < num_words_in_fifo; i++){
                fifo_data = *(periph_base+FIFO_DATA_REG_OFFSET);
                //printf("Data Word %d: %f\n", (i+1), fifo_data);
            }
            words_read = words_read + num_words_in_fifo;
        }
    }
}

int main(){

    // first, get a pointer to the peripheral base address using /dev/mem and the function mmap
    volatile unsigned int *my_periph = get_a_pointer(FIFO_PERIPH_ADDRESS);

    printf("Hello, I am going to read 10 seconds of data now...\n");
    read_fifo(my_periph);
    printf("Finished!\n");
}