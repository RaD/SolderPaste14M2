// ATtiny13A
//#define F_CPU 9600000/8  // установлено в настройках проекта

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


#define MASK_SHIFT  0x0F

register unsigned char direction asm("r3"); // направление вращения
volatile unsigned char rotate;


// обработчик прерывания Pin Change
SIGNAL(SIG_PIN_CHANGE0) {
    _delay_ms(50); // давим дребезг
    if (bit_is_set(PINB, PB4)) {
        // кнопка отпущена
        rotate = 0;
    } else {
        // кнопка нажата
        rotate = 1;
    }
}


// да-да, это точка входа в программу
int main(void) {
    unsigned char mcusr, shift;

    // сохраняем информацию об источнике сброса
    // и сразу же обнуляем регистр
    mcusr = MCUSR;
    MCUSR = 0;

    // если сброс был по кнопке, то меняем направление вращения
    if (mcusr & (1<<EXTRF)) {
        // изменяем бит на противоположное значение
        direction ^= 1;
    } else {
        // начальные значения
        rotate = 0;
        direction = 1;
        shift = 0x33;
    }

    // настройка порта, см. раздел 10.2.3 даташита
    DDRB = (0<<DDB4) | (1<<DDB3) | (1<<DDB2) | (1<<DDB1) | (1<<DDB0);
    
    // настройка прерываний
    GIMSK = (1<<PCIE);      // разрешаем прерывание Pin Change
    PCMSK = (1<<PCINT4);    // для вывода PB4
    // включаем прерывания на любое изменение
    MCUCR = (1<<ISC00);

    // разрешаем прерывания
    sei();

    // основной цикл
    while(1) {
        if (rotate) { // кнопка нажата
            if (direction) { // надо двигаться влево
                shift = (shift << 1) | (shift >> 7);
            } else { // иначе вправо
                shift = (shift >> 1) | (shift << 7);
            }
            PORTB = shift & MASK_SHIFT;
            _delay_ms(10);
        }
    }
    return 0;
}

