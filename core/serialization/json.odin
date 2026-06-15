package serialization

import automata "../automata"
import "core:encoding/json"

// --- JSON intermediate structs ---

_Type_Sniff :: struct {
    kind: string `json:"type"`,
}

_FA_Transition_JSON :: struct {
    from:   string,
    symbol: Maybe(string),
    to:     []string,
}

_FA_JSON :: struct {
    kind:        string `json:"type"`,
    states:      []string,
    alphabet:    []string,
    transitions: []_FA_Transition_JSON,
    initial:     string,
    accepting:   []string,
}

_PDA_Transition_JSON :: struct {
    from:      string,
    symbol:    Maybe(string),
    stack_top: string,
    push:      []string,
    to:        string,
}

_PDA_JSON :: struct {
    kind:           string `json:"type"`,
    states:         []string,
    alphabet:       []string,
    stack_alphabet: []string,
    transitions:    []_PDA_Transition_JSON,
    initial:        string,
    initial_stack:  string,
    accepting:      []string,
    accept_mode:    string,
}

_TM_Transition_JSON :: struct {
    from:  string,
    read:  string,
    write: string,
    dir:   string,
    to:    string,
}

_TM_JSON :: struct {
    kind:           string `json:"type"`,
    states:         []string,
    input_alphabet: []string,
    tape_alphabet:  []string,
    blank:          string,
    transitions:    []_TM_Transition_JSON,
    initial:        string,
    accepting:      []string,
}

// --- Helpers ---

_state_index :: proc(states: []string, name: string) -> int {
    for s, i in states {
        if s == name do return i
    }
    return -1
}

_alphabet_from_strings :: proc(syms: []string) -> []u8 {
    out := make([]u8, len(syms))
    for s, i in syms {
        if len(s) > 0 do out[i] = u8(s[0])
    }
    return out
}

_accepting_from_names :: proc(states, names: []string) -> []bool {
    out := make([]bool, len(states))
    for name in names {
        if i := _state_index(states, name); i != -1 do out[i] = true
    }
    return out
}

// --- Public API ---

// Returns the automaton kind ("fa", "pda", "tm") from JSON, or "" on error.
automaton_type_from_json :: proc(data: []byte) -> string {
    sniff: _Type_Sniff
    if err := json.unmarshal(data, &sniff); err != nil do return ""
    return sniff.kind
}

fa_from_json :: proc(data: []byte) -> (automata.NFA, bool) {
    raw: _FA_JSON
    if err := json.unmarshal(data, &raw); err != nil do return {}, false

    n            := len(raw.states)
    transitions  := make([][256][]int, n)
    eps_dyn      := make([][dynamic]int, n)

    for t in raw.transitions {
        from := _state_index(raw.states, t.from)
        if from == -1 do continue

        if sym, ok := t.symbol.?; ok && len(sym) > 0 {
            s   := u8(sym[0])
            tos := make([]int, len(t.to))
            for name, i in t.to do tos[i] = _state_index(raw.states, name)
            transitions[from][s] = tos
        } else {
            for name in t.to {
                if to := _state_index(raw.states, name); to != -1 {
                    append(&eps_dyn[from], to)
                }
            }
        }
    }

    epsilon := make([][]int, n)
    for dyn, i in eps_dyn do epsilon[i] = dyn[:]

    return automata.NFA{
        states      = raw.states,
        alphabet    = _alphabet_from_strings(raw.alphabet),
        transitions = transitions,
        epsilon     = epsilon,
        initial     = _state_index(raw.states, raw.initial),
        accepting   = _accepting_from_names(raw.states, raw.accepting),
    }, true
}

pda_from_json :: proc(data: []byte) -> (automata.PDA, bool) {
    raw: _PDA_JSON
    if err := json.unmarshal(data, &raw); err != nil do return {}, false

    transitions := make([]automata.PDA_Transition, len(raw.transitions))
    for t, i in raw.transitions {
        sym: Maybe(u8)
        if s, ok := t.symbol.?; ok && len(s) > 0 do sym = u8(s[0])

        push := make([]u8, len(t.push))
        for s, j in t.push {
            if len(s) > 0 do push[j] = u8(s[0])
        }

        stack_top: u8
        if len(t.stack_top) > 0 do stack_top = u8(t.stack_top[0])

        transitions[i] = automata.PDA_Transition{
            from       = _state_index(raw.states, t.from),
            to         = _state_index(raw.states, t.to),
            symbol     = sym,
            stack_top  = stack_top,
            stack_push = push,
        }
    }

    initial_stack: u8
    if len(raw.initial_stack) > 0 do initial_stack = u8(raw.initial_stack[0])

    mode: automata.PDA_Accept_Mode = .Final_State if raw.accept_mode != "empty_stack" else .Empty_Stack

    return automata.PDA{
        states         = raw.states,
        alphabet       = _alphabet_from_strings(raw.alphabet),
        stack_alphabet = _alphabet_from_strings(raw.stack_alphabet),
        transitions    = transitions,
        initial        = _state_index(raw.states, raw.initial),
        initial_stack  = initial_stack,
        accepting      = _accepting_from_names(raw.states, raw.accepting),
        accept_mode    = mode,
    }, true
}

tm_from_json :: proc(data: []byte) -> (automata.Turing_Machine, bool) {
    raw: _TM_JSON
    if err := json.unmarshal(data, &raw); err != nil do return {}, false

    transitions := make([]automata.TM_Transition, len(raw.transitions))
    for t, i in raw.transitions {
        dir: automata.Direction
        switch t.dir {
        case "L": dir = .Left
        case "R": dir = .Right
        case:     dir = .Stay
        }

        transitions[i] = automata.TM_Transition{
            from  = _state_index(raw.states, t.from),
            to    = _state_index(raw.states, t.to),
            read  = u8(t.read[0])  if len(t.read)  > 0 else 0,
            write = u8(t.write[0]) if len(t.write) > 0 else 0,
            dir   = dir,
        }
    }

    blank: u8
    if len(raw.blank) > 0 do blank = u8(raw.blank[0])

    return automata.Turing_Machine{
        states         = raw.states,
        input_alphabet = _alphabet_from_strings(raw.input_alphabet),
        tape_alphabet  = _alphabet_from_strings(raw.tape_alphabet),
        blank          = blank,
        transitions    = transitions,
        initial        = _state_index(raw.states, raw.initial),
        accepting      = _accepting_from_names(raw.states, raw.accepting),
    }, true
}