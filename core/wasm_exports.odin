#+build js

package main

import "automata"
import "serialization"
import "base:runtime"

Loaded_Automaton :: union {
    automata.NFA,
    automata.PDA,
    automata.Turing_Machine,
}

current: Loaded_Automaton

json_buf:  [64 * 1024]u8
input_buf: [1024]u8

@export
get_json_buf :: proc "c" () -> rawptr {
    return &json_buf[0]
}

@export
get_input_buf :: proc "c" () -> rawptr {
    return &input_buf[0]
}

@export
load_automaton :: proc "c" (len: i32) -> b32 {
    context = runtime.default_context()
    data := json_buf[:len]

    switch serialization.automaton_type_from_json(data) {
    case "fa":
        nfa, ok := serialization.fa_from_json(data)
        if !ok do return false
        current = nfa
    case "pda":
        pda, ok := serialization.pda_from_json(data)
        if !ok do return false
        current = pda
    case "tm":
        tm, ok := serialization.tm_from_json(data)
        if !ok do return false
        current = tm
    case:
        return false
    }
    return true
}

@export
accepts_current :: proc "c" (len: i32) -> b32 {
    context = runtime.default_context()
    input := input_buf[:len]
    switch aut in current {
    case automata.NFA:
        return b32(automata.accepts(aut, input))
    case automata.PDA:
        return false // TODO
    case automata.Turing_Machine:
        return false // TODO
    }
    return false
}