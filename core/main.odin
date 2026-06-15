#+build !js

package main

import "core:fmt"
import "automata"

main :: proc() {
    tr: [3][256]int
    for &row in tr do for &cell in row do cell = -1
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

    fmt.println(automata.is_complete(test))
    fmt.println(automata.accepts(test, {'a', 'b', 'a'}))

    // NFA: accepts strings ending in "ab"
    // q0 --a--> {q0, q1}, q0 --b--> {q0}
    // q1 --b--> {q2}
    // q2 is accepting
    nfa_tr: [3][256][]int
    nfa_tr[0]['a'] = []int{0, 1}
    nfa_tr[0]['b'] = []int{0}
    nfa_tr[1]['b'] = []int{2}

    nfa_eps: [3][]int

    nfa := automata.NFA{
        states =      {"q0", "q1", "q2"},
        alphabet =    {'a', 'b'},
        transitions = nfa_tr[:],
        epsilon =     nfa_eps[:],
        initial =     0,
        accepting =   {false, false, true},
    }

    fmt.println("accepts 'aab':", automata.accepts(nfa, {'a', 'a', 'b'})) // true
    fmt.println("accepts 'aba':", automata.accepts(nfa, {'a', 'b', 'a'})) // false

    fmt.println("simulate 'aab':")
    steps := automata.simulate_nfa(nfa, {'a', 'a', 'b'})
    for step in steps {
        fmt.printf("  pos=%d  states=%v\n", step.pos, step.states)
    }
}
