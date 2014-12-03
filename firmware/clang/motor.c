// ATtiny13A
//#define F_CPU 9600000/8  // ����������� � ���������� �������

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


#define MASK_SHIFT  0x0F

register unsigned char direction asm("r3"); // ����������� ��������
volatile unsigned char rotate;


// ���������� ���������� Pin Change
SIGNAL(SIG_PIN_CHANGE0) {
    _delay_ms(50); // ����� �������
    if (bit_is_set(PINB, PB4)) {
        // ������ ��������
        rotate = 0;
    } else {
        // ������ ������
        rotate = 1;
    }
}


// ��-��, ��� ����� ����� � ���������
int main(void) {
    unsigned char mcusr, shift;

    // ��������� ���������� �� ��������� ������
    // � ����� �� �������� �������
    mcusr = MCUSR;
    MCUSR = 0;

    // ���� ����� ��� �� ������, �� ������ ����������� ��������
    if (mcusr & (1<<EXTRF)) {
        // �������� ��� �� ��������������� ��������
        direction ^= 1;
    } else {
        // ��������� ��������
        rotate = 0;
        direction = 1;
        shift = 0x33;
    }

    // ��������� �����, ��. ������ 10.2.3 ��������
    DDRB = (0<<DDB4) | (1<<DDB3) | (1<<DDB2) | (1<<DDB1) | (1<<DDB0);
    
    // ��������� ����������
    GIMSK = (1<<PCIE);      // ��������� ���������� Pin Change
    PCMSK = (1<<PCINT4);    // ��� ������ PB4
    // �������� ���������� �� ����� ���������
    MCUCR = (1<<ISC00);

    // ��������� ����������
    sei();

    // �������� ����
    while(1) {
        if (rotate) { // ������ ������
            if (direction) { // ���� ��������� �����
                shift = (shift << 1) | (shift >> 7);
            } else { // ����� ������
                shift = (shift >> 1) | (shift << 7);
            }
            PORTB = shift & MASK_SHIFT;
            _delay_ms(10);
        }
    }
    return 0;
}

