package main

import "core:fmt"
import "automata"

main :: proc() {
    tr: [3][256]int
    tr[0]['a'] = 1
    tr[1]['b'] = 2
    tr[2]['a'] = 1
    tr[2]['b'] = 2

    test := automata.DFA{
        {"q0", "q1", "q2"},
        {'a', 'b'},
        tr[:],
        0,
        {false, false, true},
    }

    fmt.println(automata.is_complete(test)) // ?? pare sa nu mearga?
    fmt.println(automata.accepts(test, {'a', 'b', 'a'})) // asta e ok
}
